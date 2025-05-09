# Guide: WordPress to Vercel Webhook for Astro Project Rebuild

This guide outlines the method and strategy for creating a webhook in your WordPress dashboard to trigger a rebuild of an Astro project hosted on Vercel.

## 1. Introduction

The goal is to add functionality (e.g., a button) in the WordPress admin area. When triggered, this functionality will send an HTTP request to a specific Vercel Deploy Hook URL, instructing Vercel to redeploy your Astro project. This is useful for updating static content on your Astro site that might be sourced or influenced by changes in WordPress.

We will achieve this by:
1.  Creating a Vercel Deploy Hook.
2.  Developing a simple WordPress plugin to:
    *   Securely store and use the Vercel Deploy Hook URL.
    *   Add a button or interface in the WordPress admin dashboard.
    *   Send a POST request to the Vercel Deploy Hook when the button is clicked.

## 2. Core Concepts & Requirements

To implement this, you'll need to understand and have access to the following:

### Concepts:

*   **Webhooks:** Automated messages sent from apps when something happens. In this case, WordPress sends a message to Vercel.
*   **Vercel Deploy Hooks:** Specific URLs provided by Vercel that, when accessed (typically via a POST request), trigger a new deployment for a connected Git repository and branch.
*   **WordPress Plugin Development:** Creating custom functionality for WordPress by writing PHP code, packaged as a plugin.
*   **WordPress Admin Area Customization:** Adding custom pages, menus, or dashboard widgets to the WordPress admin interface.
*   **WordPress HTTP API:** A set of functions (like `wp_remote_post()`) that WordPress provides for making HTTP requests to external services.
*   **WordPress Nonces:** "Numbers used once" – security tokens to protect URLs and forms from misuse, preventing Cross-Site Request Forgery (CSRF) attacks.
*   **User Capabilities:** WordPress roles and permissions system to ensure only authorized users can trigger the rebuild.

### Requirements:

*   **Admin Access to WordPress:** To install plugins and potentially modify `wp-config.php`.
*   **Admin Access to your Vercel Project:** To create and manage Deploy Hooks.
*   **Astro Project Deployed on Vercel:** The target project you want to rebuild.
*   **Basic PHP Knowledge:** For writing the WordPress plugin.
*   **Understanding of `wp-config.php` (Optional but Recommended):** For securely storing the Vercel Deploy Hook URL.

## 3. Strategy & Method

Here's a step-by-step approach:

### Step 1: Obtain a Vercel Deploy Hook URL

1.  Go to your Astro project on Vercel.
2.  Navigate to **Settings** -> **Git**.
3.  Scroll down to the **Deploy Hooks** section.
4.  Create a new hook:
    *   Give it a descriptive name (e.g., `WordPress Staging Rebuild`).
    *   Specify the **Git Branch Name** you want Vercel to deploy when this hook is triggered (e.g., `main`, `develop`, or your production branch).
5.  Vercel will generate a unique URL. **Copy this URL.** This is your Deploy Hook. Keep it secure.

### Step 2: Securely Store the Deploy Hook URL in WordPress

It's crucial *not* to hardcode the Deploy Hook URL directly into your plugin's publicly accessible code.

**Recommended Method: `wp-config.php`**

1.  Open your WordPress `wp-config.php` file (located in the root of your WordPress installation).
2.  Add the following line, replacing `YOUR_VERCEL_DEPLOY_HOOK_URL` with the URL you copied:
    ```php
    define('VERCEL_DEPLOY_HOOK_URL', 'YOUR_VERCEL_DEPLOY_HOOK_URL');
    ```
    It's good practice to place this above the `/* That's all, stop editing! Happy publishing. */` line.

**Alternative: WordPress Options (More complex for initial setup)**
You could also store it in the WordPress options table via your plugin, but using `wp-config.php` is simpler for a single, fixed URL.

### Step 3: Create a Simple WordPress Plugin

This plugin will house the logic for the admin button and the webhook call.

1.  **Create the plugin directory:**
    Navigate to your WordPress installation's `wp-content/plugins/` directory.
    Create a new folder, for example: `vercel-rebuild-trigger`.

2.  **Create the main plugin file:**
    Inside `vercel-rebuild-trigger`, create a PHP file, e.g., `vercel-rebuild-trigger.php`.

3.  **Add the plugin header:**
    Open `vercel-rebuild-trigger.php` and add the following at the top:
    ```php
    <?php
    /**
     * Plugin Name:       Vercel Rebuild Trigger
     * Plugin URI:        #
     * Description:       Adds a button to the WordPress dashboard to trigger a Vercel deployment.
     * Version:           1.0.0
     * Author:            Your Name
     * Author URI:        #
     * License:           GPL v2 or later
     * License URI:       https.www.gnu.org/licenses/gpl-2.0.html
     * Text Domain:       vercel-rebuild-trigger
     */

    // If this file is called directly, abort.
    if ( ! defined( 'WPINC' ) ) {
        die;
    }

    // Define a constant for the plugin path
    define( 'VRT_PLUGIN_PATH', plugin_dir_path( __FILE__ ) );
    ```

### Step 4: Add a Button/Link in the WordPress Admin Area

We'll add a simple button to the main WordPress Dashboard.

Add the following code to your `vercel-rebuild-trigger.php` file:

```php
/**
 * Add a widget to the dashboard.
 */
function vrt_add_dashboard_widget() {
    wp_add_dashboard_widget(
        'vercel_rebuild_widget',         // Widget slug.
        'Vercel Project Rebuild',        // Title.
        'vrt_render_dashboard_widget'    // Display function.
    );
}
add_action( 'wp_dashboard_setup', 'vrt_add_dashboard_widget' );

/**
 * Create the function to output the contents of our Dashboard Widget.
 */
function vrt_render_dashboard_widget() {
    // Check if the VERCEL_DEPLOY_HOOK_URL is defined
    if ( !defined('VERCEL_DEPLOY_HOOK_URL') || empty(VERCEL_DEPLOY_HOOK_URL) ) {
        echo '<p>Error: VERCEL_DEPLOY_HOOK_URL is not defined in wp-config.php or is empty. Please configure it.</p>';
        return;
    }

    // Create a nonce for security
    $nonce = wp_create_nonce('vercel_rebuild_nonce');
    ?>
    <p>Click the button below to trigger a rebuild of your Astro project on Vercel.</p>
    <form method="post" action="<?php echo esc_url( admin_url( 'admin-post.php' ) ); ?>">
        <input type="hidden" name="action" value="trigger_vercel_rebuild">
        <input type="hidden" name="_wpnonce" value="<?php echo esc_attr( $nonce ); ?>">
        <?php submit_button( 'Rebuild Vercel Project', 'primary', 'submit_vercel_rebuild' ); ?>
    </form>
    <?php
    // Display feedback messages
    if ( isset( $_GET['vrt_message'] ) ) {
        $message_type = isset( $_GET['vrt_message_type'] ) && $_GET['vrt_message_type'] === 'error' ? 'error' : 'updated';
        echo '<div id="message" class="' . esc_attr( $message_type ) . ' notice is-dismissible"><p>' . esc_html( urldecode( $_GET['vrt_message'] ) ) . '</p></div>';
    }
}
```

### Step 5: Handle the Button Click (Trigger the Webhook)

This part involves creating an action that `admin-post.php` will call.

Add the following code to your `vercel-rebuild-trigger.php` file:

```php
/**
 * Handle the Vercel rebuild trigger action.
 */
function vrt_handle_trigger_rebuild() {
    // 1. Verify Nonce
    if ( ! isset( $_POST['_wpnonce'] ) || ! wp_verify_nonce( $_POST['_wpnonce'], 'vercel_rebuild_nonce' ) ) {
        wp_redirect( add_query_arg( array(
            'vrt_message' => urlencode('Security check failed.'),
            'vrt_message_type' => 'error'
        ), admin_url('index.php') ) );
        exit;
    }

    // 2. Check User Capabilities
    if ( ! current_user_can( 'manage_options' ) ) { // Or a more specific capability
        wp_redirect( add_query_arg( array(
            'vrt_message' => urlencode('You do not have permission to perform this action.'),
            'vrt_message_type' => 'error'
        ), admin_url('index.php') ) );
        exit;
    }

    // 3. Check if VERCEL_DEPLOY_HOOK_URL is defined and not empty
    if ( !defined('VERCEL_DEPLOY_HOOK_URL') || empty(VERCEL_DEPLOY_HOOK_URL) ) {
        wp_redirect( add_query_arg( array(
            'vrt_message' => urlencode('Vercel Deploy Hook URL is not configured.'),
            'vrt_message_type' => 'error'
        ), admin_url('index.php') ) );
        exit;
    }
    $hook_url = VERCEL_DEPLOY_HOOK_URL;

    // 4. Make the HTTP POST request to Vercel
    $args = array(
        'method'    => 'POST',
        'timeout'   => 45, // seconds
        'redirection' => 5,
        'httpversion' => '1.0',
        'blocking'    => true, // Set to false for non-blocking if you don't need immediate feedback or care about the response.
        'headers'     => array(),
        'body'        => null, // Vercel deploy hooks typically don't require a body for a simple rebuild.
        'cookies'     => array()
    );

    $response = wp_remote_post( $hook_url, $args );

    // 5. Provide Feedback
    $redirect_url = admin_url('index.php'); // Redirect back to the dashboard

    if ( is_wp_error( $response ) ) {
        $error_message = $response->get_error_message();
        $message = 'Error triggering Vercel rebuild: ' . $error_message;
        $message_type = 'error';
    } else {
        $status_code = wp_remote_retrieve_response_code( $response );
        if ( $status_code >= 200 && $status_code < 300 ) {
            // Vercel often returns 201 (Created) or 200 (OK) if the hook is accepted.
            // The actual build happens asynchronously.
            $message = 'Vercel rebuild successfully triggered! Check Vercel for deployment status.';
            $message_type = 'success';
        } else {
            $message = 'Vercel rebuild trigger failed. Vercel responded with status code: ' . $status_code;
            $message_type = 'error';
            // You might want to log wp_remote_retrieve_body($response) for more details from Vercel
        }
    }

    wp_redirect( add_query_arg( array(
        'vrt_message' => urlencode($message),
        'vrt_message_type' => $message_type
    ), $redirect_url ) );
    exit;
}
// Hook for logged-in users
add_action( 'admin_post_trigger_vercel_rebuild', 'vrt_handle_trigger_rebuild' );
```

### Step 6: Activate and Test

1.  Go to **Plugins** in your WordPress admin area.
2.  Find "Vercel Rebuild Trigger" and click **Activate**.
3.  Go to your **Dashboard**. You should see a new widget titled "Vercel Project Rebuild".
4.  Click the "Rebuild Vercel Project" button.
5.  Check your Vercel project's deployments page to see if a new build has started.
6.  You should also see a success or error message on your WordPress dashboard.

## 4. (Future) Passing Data with the Webhook

The current Vercel Deploy Hooks are primarily for triggering a rebuild of a specific branch. They don't typically process a request body in a way that directly injects data into the Astro build process without further Vercel-side configuration (e.g., using Vercel Serverless Functions that the hook might trigger, which then fetch data).

If your goal is to send data *from* WordPress (like post content) *to* your Astro project to be used *during* the Astro build process:

1.  **WordPress JSON API:** Your WordPress site already has a REST API (`/wp-json/`). Your Astro project can fetch data from this API during its build (`getStaticPaths`, `fetch` in component scripts, etc.). The webhook would simply tell Vercel to rebuild, and Astro, as part of its build, would fetch the latest data.
2.  **Custom Data in Deploy Hook (Advanced):** Some CI/CD systems allow passing environment variables or minimal data via webhooks. For Vercel, this is less common for simple deploy hooks. You'd likely need a more complex setup, perhaps involving a Vercel Serverless Function as an intermediary that the deploy hook calls, which then fetches data from WordPress based on some parameters (if any) passed to the hook.

For the initial setup, the webhook acts as a simple "rebuild now" signal. The Astro project itself remains responsible for fetching any WordPress data it needs via the WP REST API during its build.

## 5. Security Considerations

*   **Nonce Verification:** Done (`wp_verify_nonce`). This is crucial.
*   **User Capability Checks:** Done (`current_user_can`). Ensure only authorized users can trigger rebuilds.
*   **Secure Hook URL Storage:** Done (via `wp-config.php`). Prevents the URL from being exposed.
*   **HTTPS:** Ensure your WordPress site and Vercel are using HTTPS.
*   **Rate Limiting (Advanced):** For very active sites, you might consider adding custom rate limiting to prevent accidental or malicious rapid triggering, though Vercel likely has its own limits on deploy hook invocations.

## 6. Troubleshooting

*   **Check `wp-config.php`:** Ensure `VERCEL_DEPLOY_HOOK_URL` is correctly defined and has the right URL.
*   **WordPress Error Log:** Enable `WP_DEBUG` and `WP_DEBUG_LOG` in `wp-config.php` to check for PHP errors.
*   **Vercel Deployment Logs:** Check the "Deployments" tab in your Vercel project for any build errors or information about the hook invocation.
*   **Browser Developer Tools:** Check the network tab when you click the button to see the request being made to `admin-post.php` and any redirects.
*   **Plugin Conflicts:** Temporarily disable other plugins to see if there's a conflict.

---

This guide provides a comprehensive approach. You can now proceed to implement this plugin.
Remember to replace placeholder names like "Your Name" and URIs in the plugin header.
The next step for us would be to actually implement this plugin based on the above structure. 