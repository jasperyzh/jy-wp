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
}
add_action('wp_enqueue_scripts', 'twentytwentyfive_child_enqueue_styles');

/**
 * Add custom footer text
 */
function twentytwentyfive_child_custom_footer() {
    echo '<div class="custom-footer-text" style="text-align: center; padding: 1rem 0; font-size: 0.8rem; background-color: #f5f5f5; margin-top: 2rem;">';
    echo '© ' . date('Y') . ' My WordPress Site - Updated for Deployment Test on ' . date('F j, Y H:i:s');
    echo '<br>Deployed via GitHub Actions CI/CD Pipeline';
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
