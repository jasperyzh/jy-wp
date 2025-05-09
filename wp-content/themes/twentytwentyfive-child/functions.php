<?php
/**
 * Twenty Twenty-Five Child Theme functions and definitions
 */

// Enqueue parent theme and child theme styles
function twentytwentyfive_child_enqueue_styles() {
    wp_enqueue_style('twentytwentyfive-style', get_template_directory_uri() . '/style.css');
    wp_enqueue_style('twentytwentyfive-child-style',
        get_stylesheet_directory_uri() . '/style.css',
        array('twentytwentyfive-style'),
        wp_get_theme()->get('Version')
    );

    // Enqueue Vite assets - will switch automatically between dev and production
    twentytwentyfive_child_enqueue_vite_assets();
}
add_action('wp_enqueue_scripts', 'twentytwentyfive_child_enqueue_styles');

/**
 * Enqueue Vite assets in development or production mode
 */
function twentytwentyfive_child_enqueue_vite_assets() {
    // Define constants for Vite development
    define('VITE_DEV_SERVER', 'http://localhost:3001');
    define('VITE_DEV_MODE', file_exists(get_stylesheet_directory() . '/.vite-dev-server'));

    if (VITE_DEV_MODE) {
        // Development mode - use Vite's dev server
        wp_enqueue_script('vite-client', VITE_DEV_SERVER . '/@vite/client', array(), null, true);
        wp_enqueue_script('vite-main-js', VITE_DEV_SERVER . '/src/main.js', array(), null, true);

        // Add type="module" to Vite dev server scripts
        add_filter('script_loader_tag', 'twentytwentyfive_child_vite_module_scripts', 10, 3);
    } else {
        // Production mode - use built assets
        $manifest_path = get_stylesheet_directory() . '/assets/dist/manifest.json';
        
        if (file_exists($manifest_path)) {
            $manifest = json_decode(file_get_contents($manifest_path), true);
            
            // Enqueue main JS
            if (isset($manifest['src/main.js'])) {
                $main_js = $manifest['src/main.js']['file'];
                wp_enqueue_script(
                    'twentytwentyfive-child-js',
                    get_stylesheet_directory_uri() . '/assets/dist/' . $main_js,
                    array(),
                    filemtime(get_stylesheet_directory() . '/assets/dist/' . $main_js),
                    true
                );
            }
            
            // Enqueue CSS
            if (isset($manifest['src/styles.scss'])) {
                $main_css = $manifest['src/styles.scss']['file'];
                if (strpos($main_css, '.css') !== false) {
                    wp_enqueue_style(
                        'twentytwentyfive-child-vite-css',
                        get_stylesheet_directory_uri() . '/assets/dist/' . $main_css,
                        array(),
                        filemtime(get_stylesheet_directory() . '/assets/dist/' . $main_css)
                    );
                }
            }
        }
    }
}

/**
 * Adds type="module" to script tags for Vite dev server assets.
 */
function twentytwentyfive_child_vite_module_scripts($tag, $handle, $src) {
    // Scripts to be treated as modules
    $module_scripts = array('vite-client', 'vite-main-js');

    if (in_array($handle, $module_scripts)) {
        // Ensure the src is from our Vite dev server
        if (strpos($src, VITE_DEV_SERVER) === 0) {
            return '<script type="module" src="' . esc_url($src) . '" id="' . esc_attr($handle) . '-js"></script>';
        }
    }
    return $tag;
}

/**
 * Add custom footer text
 */
function twentytwentyfive_child_custom_footer() {
    echo '<div class="custom-footer-text" style="text-align: center; padding: 1rem 0; font-size: 0.8rem; background-color: #f5f5f5; margin-top: 2rem;">';
    echo '© ' . date('Y') . ' My WordPress Site - Updated for Deployment Test on ' . date('F j, Y H:i:s');
    echo '<br>Deployed via GitHub Actions CI/CD Pipeline';
    echo '<div class="deployment-cube-container">';
    echo '<div class="deployment-cube">';
    echo '<span>Deployed Cube</span>';
    echo '<div class="cube-face front"></div>';
    echo '<div class="cube-face back"></div>';
    echo '<div class="cube-face right"></div>';
    echo '<div class="cube-face left"></div>';
    echo '<div class="cube-face top"></div>';
    echo '<div class="cube-face bottom"></div>';
    echo '</div>';
    echo '</div>';
    
    echo '</div>';
}
add_action('wp_footer', 'twentytwentyfive_child_custom_footer');

/**
 * Add custom functionality below
 */

/**
 * Customize the login page
 */
function twentytwentyfive_child_custom_login() {
    // Add custom styles to the WordPress login page
    echo '<style type="text/css">
        #login h1 a { 
            background-image: none;
            height: auto;
            width: auto;
            text-indent: 0;
        }
        #login h1 a:before {
            content: "My WordPress Site";
            font-size: 24px;
            font-weight: bold;
            color: #444;
        }
        #login {
            padding: 5% 0 0;
        }
        .login form {
            border-radius: 10px;
            box-shadow: 0 4px 10px rgba(0,0,0,0.1);
        }
        .wp-core-ui .button-primary {
            background: #4CAF50;
            border-color: #4CAF50;
        }
        .wp-core-ui .button-primary:hover {
            background: #45a049;
            border-color: #45a049;
        }
        .login form:after {
            content: "Deployed via GitHub Actions";
            display: block;
            text-align: center;
            margin-top: 20px;
            color: #666;
            font-size: 12px;
        }
    </style>';
}
add_action('login_head', 'twentytwentyfive_child_custom_login'); 