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
    echo '© ' . date('Y') . ' My WordPress Site - Updated for Deployment Test on ' . date('F j, Y H:i:s') . '- edited via github actions' ;
    echo '</div>';
}
add_action('wp_footer', 'twentytwentyfive_child_custom_footer');

/**
 * Add custom functionality below
 */ 
