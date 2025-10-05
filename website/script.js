// Rain sound generation using Web Audio API
let audioContext;
let rainNoiseNode;
let gainNode;
let isAudioInitialized = false;
let isSoundEnabled = false;
let isLightningEnabled = false;
let isThunderEnabled = false;

// Handle audio playback
document.addEventListener('DOMContentLoaded', function() {
    // Additional rain drops for more realistic effect
    createRainDrops();
    
    // Show controls immediately
    showControls();
    
    // Initialize scroll animations for subsections
    initScrollAnimations();
    
    // Initialize audio on user interaction (required by browsers)
    let audioStarted = false;
    function startAudio() {
        if (!audioStarted) {
            initRainSound();
            createThunderAudio(); // Pre-create thunder
            audioStarted = true;
            // Remove the initial click listeners
            document.removeEventListener('click', startAudio);
            document.removeEventListener('touchstart', startAudio);
            document.removeEventListener('keypress', startAudio);
        }
    }
    
    document.addEventListener('click', startAudio);
    document.addEventListener('touchstart', startAudio);
    document.addEventListener('keypress', startAudio);
    
    // Add click listener for lightning
    document.addEventListener('click', triggerLightning);
});

function createRainDrops() {
    const rain = document.querySelector('.rain');
    
    // Create additional rain streaks dynamically
    for (let i = 0; i < 100; i++) {
        const drop = document.createElement('div');
        drop.className = 'raindrop';
        drop.style.left = Math.random() * 100 + '%';
        drop.style.animationDelay = Math.random() * 2 + 's';
        drop.style.animationDuration = (Math.random() * 0.5 + 0.5) + 's';
        rain.appendChild(drop);
    }
}

// Generate rain sound using Web Audio API (modern approach)
function initRainSound() {
    try {
        if (isAudioInitialized) return;
        
        // Create audio context
        audioContext = new (window.AudioContext || window.webkitAudioContext)();
        
        // Create a long looping pink noise buffer
        const bufferSize = audioContext.sampleRate * 4; // 4 seconds
        const noiseBuffer = audioContext.createBuffer(1, bufferSize, audioContext.sampleRate);
        const data = noiseBuffer.getChannelData(0);
        
        // Generate pink noise
        let b0 = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0;
        for (let i = 0; i < bufferSize; i++) {
            const white = Math.random() * 2 - 1;
            b0 = 0.99886 * b0 + white * 0.0555179;
            b1 = 0.99332 * b1 + white * 0.0750759;
            b2 = 0.96900 * b2 + white * 0.1538520;
            b3 = 0.86650 * b3 + white * 0.3104856;
            b4 = 0.55000 * b4 + white * 0.5329522;
            b5 = -0.7616 * b5 - white * 0.0168980;
            data[i] = (b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362) * 0.11;
            b6 = white * 0.115926;
        }
        
        // Create looping buffer source
        rainNoiseNode = audioContext.createBufferSource();
        rainNoiseNode.buffer = noiseBuffer;
        rainNoiseNode.loop = true;
        
        // Add low-pass filter for more realistic rain sound
        const filter = audioContext.createBiquadFilter();
        filter.type = 'lowpass';
        filter.frequency.value = 1800;
        filter.Q.value = 1;
        
        // Add gain control
        gainNode = audioContext.createGain();
        gainNode.gain.value = 0.4; // Adjust volume (0.0 to 1.0)
        
        // Connect: source -> filter -> gain -> output
        rainNoiseNode.connect(filter);
        filter.connect(gainNode);
        gainNode.connect(audioContext.destination);
        
        // Start the rain sound
        rainNoiseNode.start(0);
        
        isAudioInitialized = true;
        
        console.log('Rain sound started successfully!');
    } catch (error) {
        console.error('Error starting rain sound:', error);
    }
}

// Toggle sound on/off
function toggleSound() {
    if (!isAudioInitialized) {
        // Try to initialize on first click
        document.body.click();
        setTimeout(() => toggleSound(), 100);
        return;
    }
    
    isSoundEnabled = !isSoundEnabled;
    gainNode.gain.value = isSoundEnabled ? 0.4 : 0;
    
    // Update button
    const soundBtn = document.getElementById('sound-toggle');
    if (soundBtn) {
        soundBtn.textContent = isSoundEnabled ? '🔊 Rain On' : '🔇 Rain Off';
        soundBtn.style.opacity = isSoundEnabled ? '1' : '0.6';
    }
}

// Toggle thunder on/off
function toggleThunder() {
    isThunderEnabled = !isThunderEnabled;
    
    // Update button
    const thunderBtn = document.getElementById('thunder-toggle');
    if (thunderBtn) {
        thunderBtn.textContent = isThunderEnabled ? '🔊 Thunder On' : '🔇 Thunder Off';
        thunderBtn.style.opacity = isThunderEnabled ? '1' : '0.6';
    }
}

// Toggle lightning on/off
function toggleLightning() {
    isLightningEnabled = !isLightningEnabled;
    
    // Update button
    const lightningBtn = document.getElementById('lightning-toggle');
    if (lightningBtn) {
        lightningBtn.textContent = isLightningEnabled ? '⚡ Lightning On' : '⚡ Lightning Off';
        lightningBtn.style.opacity = isLightningEnabled ? '1' : '0.6';
    }
}

// Trigger lightning bolt on click
function triggerLightning(e) {
    // Don't trigger if clicking on control buttons
    if (e.target.closest('.controls')) {
        console.log('Clicked on controls, ignoring');
        return;
    }
    
    if (!isLightningEnabled) {
        console.log('Lightning disabled');
        return;
    }
    
    const lightning = document.querySelector('.lightning');
    if (lightning) {
        // Remove and re-add class to restart animation
        lightning.style.animation = 'none';
        // Force reflow
        lightning.offsetHeight;
        lightning.style.animation = 'lightningFlash 0.4s ease-out';
        
        // Play thunder if enabled
        if (isThunderEnabled) {
            playThunderSound();
        }
        
        // Reset after animation
        setTimeout(() => {
            lightning.style.animation = '';
        }, 400);
    } else {
        console.log('Lightning element not found!');
    }
}

// Create thunder sound using actual MP3 file
let thunderAudio = null;

function createThunderAudio() {
    if (thunderAudio) return;
    
    try {
        console.log('Loading thunder audio from MP3...');
        
        // Use the MP3 file from the workspace
        thunderAudio = new Audio('loud-thunder-sound.mp3');
        thunderAudio.volume = 1.0;
        thunderAudio.preload = 'auto';
        
        // Wait for it to be ready
        thunderAudio.addEventListener('canplaythrough', function() {
            console.log('Thunder audio ready to play');
        }, { once: true });
        
        thunderAudio.addEventListener('error', function(e) {
            console.error('Error loading thunder audio:', e);
        });
        
    } catch (error) {
        console.error('Error creating thunder audio:', error);
    }
}

// Play thunder sound
function playThunderSound() {
    if (!thunderAudio) {
        createThunderAudio();
        setTimeout(() => {
            if (thunderAudio) {
                thunderAudio.currentTime = 0;
                thunderAudio.play().catch(e => console.error('Error playing thunder:', e));
            }
        }, 500);
        return;
    }
    
    try {
        thunderAudio.currentTime = 0;
        thunderAudio.volume = 1.0;
        thunderAudio.play().catch(error => {
            console.error('Error playing thunder:', error);
        });
    } catch (error) {
        console.error('Exception in playThunderSound:', error);
    }
}

// Show control buttons
function showControls() {
    const controls = document.createElement('div');
    controls.className = 'controls';
    controls.innerHTML = `
        <button id="sound-toggle" class="control-btn">🔇 Rain Off</button>
        <button id="thunder-toggle" class="control-btn">🔇 Thunder Off</button>
        <button id="lightning-toggle" class="control-btn">⚡ Lightning Off</button>
    `;
    
    controls.style.cssText = `
        position: fixed;
        top: 90px;
        right: 20px;
        display: flex;
        flex-direction: column;
        gap: 10px;
        z-index: 1001;
    `;
    
    document.body.appendChild(controls);
    
    // Add styles for buttons
    const style = document.createElement('style');
    style.textContent = `
        .control-btn {
            background: rgba(20, 30, 50, 0.9);
            color: rgba(200, 220, 255, 0.95);
            border: 2px solid rgba(100, 150, 200, 0.4);
            padding: 10px 20px;
            border-radius: 8px;
            font-size: 14px;
            font-weight: bold;
            cursor: pointer;
            box-shadow: 0 2px 10px rgba(0,0,0,0.3);
            transition: all 0.3s ease;
            text-shadow: 0 0 10px rgba(100, 150, 255, 0.5);
            backdrop-filter: blur(10px);
            opacity: 0.6;
        }
        .control-btn:hover {
            background: rgba(50, 70, 120, 0.9);
            border-color: rgba(150, 180, 255, 0.6);
            transform: translateY(-2px);
            box-shadow: 0 4px 15px rgba(0,0,0,0.4);
            text-shadow: 0 0 20px rgba(150, 200, 255, 0.8);
        }
        .control-btn:active {
            transform: translateY(0);
        }
    `;
    document.head.appendChild(style);
    
    // Add event listeners
    document.getElementById('sound-toggle').addEventListener('click', toggleSound);
    document.getElementById('thunder-toggle').addEventListener('click', toggleThunder);
    document.getElementById('lightning-toggle').addEventListener('click', toggleLightning);
}


// Initialize scroll animations for section-jobs
function initScrollAnimations() {
    const subsections = document.querySelectorAll('.section-jobs');
    
    // Create an Intersection Observer
    const observerOptions = {
        root: null, // viewport
        rootMargin: '0px',
        threshold: 0.2 // Trigger when 20% of element is visible
    };
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                // Element is now visible
                const subsection = entry.target;
                const animationType = subsection.getAttribute('data-animation');
                
                // Add animate-in class (currently no animation, but ready for future)
                subsection.classList.add('animate-in');
                
                console.log(`Subsection visible: ${subsection.querySelector('h2').textContent}, animation: ${animationType}`);
                
                // Optional: Stop observing after animation triggers once
                // observer.unobserve(subsection);
            }
        });
    }, observerOptions);
    
    // Observe all subsections
    subsections.forEach(subsection => {
        observer.observe(subsection);
    });
    
    console.log(`Initialized scroll animations for ${subsections.length} subsections`);
}

