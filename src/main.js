// Import our styles
import './styles.scss';

// Initialize the app when the DOM is ready
document.addEventListener('DOMContentLoaded', () => {
  console.log('Vite + WordPress is running!');
  initializeApp();
});

/**
 * Initialize the application
 */
function initializeApp() {
  // Add a class to the body to indicate JS is loaded
  document.body.classList.add('js-loaded');
  
  // Initialize any components
  initializeRotatingCube();
}

/**
 * Initialize the rotating cube with additional interactivity
 */
function initializeRotatingCube() {
  const cube = document.querySelector('.deployment-cube');
  if (!cube) return;
  
  // Add hover effect to pause animation
  cube.addEventListener('mouseenter', () => {
    cube.style.animationPlayState = 'paused';
  });
  
  cube.addEventListener('mouseleave', () => {
    cube.style.animationPlayState = 'running';
  });
  
  // Add click effect to reverse animation
  let isReversed = false;
  cube.addEventListener('click', () => {
    isReversed = !isReversed;
    cube.style.animationDirection = isReversed ? 'reverse' : 'normal';
  });
} 