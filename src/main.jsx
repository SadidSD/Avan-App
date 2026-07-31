import React, { useState, useEffect } from 'react';
import ReactDOM from 'react-dom/client';
import './styles/app.css';
import { 
  Home, Quote, Sparkles, Moon, User, Sun, RefreshCw, Heart, 
  Play, Pause, ChevronRight, Bell, Volume2, Mic, BookOpen, Layers, 
  Settings, Award, Flame, Sliders, X, ArrowLeft
} from 'lucide-react';

const AVANApp = () => {
  const [screen, setScreen] = useState('onboarding'); // onboarding, survey, loading, main
  const [onboardingSlide, setOnboardingSlide] = useState(0);
  const [activeTab, setActiveTab] = useState('home'); // home, affirmations, meditation, sleep, profile
  
  // Onboarding Data
  const slides = [
    {
      image: '/assets/images/onboarding_girl_profile.jpg',
      icon: '✨',
      title: 'Your space to\nbecome your best self',
      subtitle: 'Daily affirmations, guided meditations and restful sleep stories for a calmer, happier you.'
    },
    {
      image: '/assets/images/onboarding_archway_sun.jpg',
      icon: '🌿',
      title: 'Affirm your mind',
      subtitle: 'Positive words shape your reality. Start your day with empowering affirmations.'
    },
    {
      image: '/assets/images/onboarding_moon_clouds.jpg',
      icon: '🌙',
      title: 'Relax. Reflect. Restore.',
      subtitle: 'Guided meditations and sleep stories help you relax, let go of stress and sleep better.'
    }
  ];

  // Survey State
  const [surveyStep, setSurveyStep] = useState(0);
  const [answers, setAnswers] = useState({
    goal: 'Boost Confidence',
    challenge: 'Overthinking & Self-Doubt',
    vision: 'Calm & Confident Mind',
    commitment: '10 Min/Day'
  });

  // Audio Player State
  const [isPlaying, setIsPlaying] = useState(false);
  const [playerOpen, setPlayerOpen] = useState(false);
  const [currentAffirmationIndex, setCurrentAffirmationIndex] = useState(0);
  const [isPremium, setIsPremium] = useState(true);

  const affirmations = [
    "I am worthy of all the good in my life.",
    "I am becoming the best version of myself.",
    "I am filled with calm, confidence, and quiet strength.",
    "My mind is peaceful, focused, and resilient.",
    "Every day in every way, I am growing stronger."
  ];

  // Render Onboarding Screen
  if (screen === 'onboarding') {
    const slide = slides[onboardingSlide];
    return (
      <div className="app-container" style={{ padding: '24px', justifyContent: 'space-between' }}>
        <div style={{ textAlign: 'right' }}>
          <button 
            onClick={() => setScreen('survey')}
            style={{ background: 'none', border: 'none', color: '#C9B6A8', fontWeight: '500', cursor: 'pointer' }}
          >
            Skip
          </button>
        </div>

        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', textAlign: 'center' }}>
          <div style={{ width: '100%', height: '280px', borderRadius: '32px', overflow: 'hidden', marginBottom: '32px', boxShadow: '0 8px 24px rgba(90, 75, 68, 0.08)' }}>
            <img src={slide.image} alt="Artwork" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </div>

          {onboardingSlide === 0 ? (
            <h1 className="font-heading" style={{ fontSize: '26px', letterSpacing: '4px', marginBottom: '12px' }}>AVAN</h1>
          ) : (
            <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#F3EDE8', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '16px', fontSize: '18px' }}>
              {slide.icon}
            </div>
          )}

          <h2 className="font-heading" style={{ fontSize: '24px', fontWeight: '700', marginBottom: '12px', whiteSpace: 'pre-line' }}>
            {slide.title}
          </h2>
          <p style={{ fontSize: '14px', color: '#7C706A', lineHeight: '1.5', maxWidth: '320px' }}>
            {slide.subtitle}
          </p>
        </div>

        <div>
          <div style={{ display: 'flex', justifyContent: 'center', gap: '6px', marginBottom: '32px' }}>
            {slides.map((_, i) => (
              <div 
                key={i} 
                style={{ 
                  width: onboardingSlide === i ? '20px' : '6px', 
                  height: '6px', 
                  borderRadius: '3px', 
                  backgroundColor: onboardingSlide === i ? '#5A4B44' : '#E8DFD9',
                  transition: 'all 0.3s ease'
                }} 
              />
            ))}
          </div>

          <button 
            className="btn-dark"
            onClick={() => {
              if (onboardingSlide < slides.length - 1) {
                setOnboardingSlide(onboardingSlide + 1);
              } else {
                setScreen('survey');
              }
            }}
          >
            {onboardingSlide === slides.length - 1 ? 'Get Started' : 'Next'} &gt;
          </button>
        </div>
      </div>
    );
  }

  // Render Survey Screen
  if (screen === 'survey') {
    const surveyQuestions = [
      { title: 'What is your primary goal?', options: ['Boost Confidence', 'Reduce Stress & Anxiety', 'Deep Focus & Productivity', 'Restful Sleep', 'Build Wealth', 'Stronger Relationships'] },
      { title: 'What is your biggest challenge?', options: ['Overthinking & Self-Doubt', 'Lack of Focus & Procrastination', 'High Stress & Burnout', 'Poor Sleep & Night Anxiety'] },
      { title: 'What vision do you have for yourself?', options: ['Calm & Confident Mind', 'Daily Peak Performance', 'Unstoppable Motivation & Joy'] },
      { title: 'How much time can you commit daily?', options: ['5 Min/Day', '10 Min/Day', '15 Min/Day', '20+ Min/Day'] }
    ];
    const q = surveyQuestions[surveyStep];

    return (
      <div className="app-container" style={{ padding: '24px', justifyContent: 'space-between' }}>
        <div>
          <div style={{ fontSize: '13px', color: '#7C706A', marginBottom: '12px' }}>Step {surveyStep + 1} of 4</div>
          <div style={{ height: '6px', width: '100%', background: '#E8DFD9', borderRadius: '3px', marginBottom: '32px' }}>
            <div style={{ height: '100%', width: `${((surveyStep + 1) / 4) * 100}%`, background: '#3D322C', borderRadius: '3px', transition: 'width 0.3s ease' }} />
          </div>
          <h2 className="font-heading" style={{ fontSize: '24px', fontWeight: '700', marginBottom: '24px' }}>{q.title}</h2>

          <div style={{ display: 'flex', flexDirection: 'column', gap: '12px' }}>
            {q.options.map(opt => (
              <div 
                key={opt}
                className="custom-card"
                onClick={() => {
                  const key = ['goal', 'challenge', 'vision', 'commitment'][surveyStep];
                  setAnswers({ ...answers, [key]: opt });
                }}
                style={{ 
                  cursor: 'pointer',
                  backgroundColor: Object.values(answers).includes(opt) ? '#F3EDE8' : '#FFFFFF',
                  borderColor: Object.values(answers).includes(opt) ? '#5A4B44' : '#EFE7E2'
                }}
              >
                {opt}
              </div>
            ))}
          </div>
        </div>

        <button 
          className="btn-dark"
          onClick={() => {
            if (surveyStep < 3) {
              setSurveyStep(surveyStep + 1);
            } else {
              setScreen('loading');
            }
          }}
        >
          {surveyStep === 3 ? 'Personalize Journey' : 'Continue'} &gt;
        </button>
      </div>
    );
  }

  // Render Loading Screen
  if (screen === 'loading') {
    setTimeout(() => setScreen('main'), 2500);
    return (
      <div className="app-container" style={{ padding: '32px', justifyContent: 'center', alignItems: 'center', textAlign: 'center' }}>
        <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: '#F3EDE8', display: 'flex', alignItems: 'center', justifyContent: 'center', marginBottom: '24px' }}>
          <Sparkles size={36} color="#5A4B44" />
        </div>
        <h2 className="font-heading" style={{ fontSize: '22px', fontWeight: '700', marginBottom: '8px' }}>Personalizing Your Experience...</h2>
        <p style={{ fontSize: '14px', color: '#7C706A' }}>Crafting your custom mindset & affirmation audio path</p>
      </div>
    );
  }

  // Main Application Tabs
  return (
    <div className="app-container" style={{ paddingBottom: '90px' }}>
      {/* HOME TAB */}
      {activeTab === 'home' && (
        <div style={{ padding: '20px' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '24px' }}>
            <div>
              <h2 className="font-heading" style={{ fontSize: '22px', fontWeight: '700' }}>Good morning, Alex ☼</h2>
              <p style={{ fontSize: '13px', color: '#7C706A' }}>Take a deep breath and start your day.</p>
            </div>
            <div style={{ width: '40px', height: '40px', borderRadius: '50%', background: '#FFFFFF', border: '1px solid #EFE7E2', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Bell size={20} color="#5A4B44" />
            </div>
          </div>

          {/* Today's Affirmation */}
          <div className="custom-card" style={{ backgroundColor: '#F3EDE8', marginBottom: '24px' }}>
            <div style={{ fontSize: '11px', fontWeight: '600', color: '#7C706A', letterSpacing: '0.5px', marginBottom: '12px' }}>TODAY'S AFFIRMATION</div>
            <h3 className="font-heading" style={{ fontSize: '22px', fontWeight: '700', lineHeight: '1.3', marginBottom: '20px' }}>
              "{affirmations[currentAffirmationIndex]}"
            </h3>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
              <button 
                onClick={() => setCurrentAffirmationIndex((currentAffirmationIndex + 1) % affirmations.length)}
                style={{ background: '#FFFFFF', border: '1px solid #EFE7E2', padding: '8px 16px', borderRadius: '20px', fontSize: '13px', cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <RefreshCw size={14} /> Refresh
              </button>
              <Sparkles size={24} color="#C9B6A8" />
            </div>
          </div>

          {/* Start Your Day */}
          <h3 className="font-heading" style={{ fontSize: '18px', fontWeight: '700', marginBottom: '12px' }}>Start Your Day</h3>
          <div className="custom-card" style={{ marginBottom: '12px', display: 'flex', alignItems: 'center', gap: '16px', cursor: 'pointer' }} onClick={() => setIsPlaying(!isPlaying)}>
            <div style={{ padding: '12px', background: '#E8DFD9', borderRadius: '16px' }}><Sparkles size={20} color="#5A4B44" /></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: '700', fontSize: '15px' }}>Morning Meditation</div>
              <div style={{ fontSize: '12px', color: '#7C706A' }}>10 min • Focus</div>
            </div>
            <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: '#3D322C', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FFF' }}>
              {isPlaying ? <Pause size={18} /> : <Play size={18} />}
            </div>
          </div>

          <div className="custom-card" style={{ marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ padding: '12px', background: '#F3EDE8', borderRadius: '16px' }}><BookOpen size={20} color="#5A4B44" /></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: '700', fontSize: '15px' }}>Daily Journal</div>
              <div style={{ fontSize: '12px', color: '#7C706A' }}>Write your thoughts and reflect.</div>
            </div>
            <ChevronRight size={18} color="#C9B6A8" />
          </div>

          {/* Night Journey */}
          <h3 className="font-heading" style={{ fontSize: '18px', fontWeight: '700', marginBottom: '12px' }}>Night Journey</h3>
          <div className="custom-card" style={{ marginBottom: '24px', display: 'flex', alignItems: 'center', gap: '16px' }}>
            <div style={{ padding: '12px', background: '#E8DFD9', borderRadius: '16px' }}><Moon size={20} color="#5A4B44" /></div>
            <div style={{ flex: 1 }}>
              <div style={{ fontWeight: '700', fontSize: '15px' }}>Prepare for Restful Sleep</div>
              <div style={{ fontSize: '12px', color: '#7C706A' }}>15 min • Sleep</div>
            </div>
            <div style={{ width: '36px', height: '36px', borderRadius: '50%', background: '#3D322C', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FFF' }}>
              <Play size={18} />
            </div>
          </div>

          {/* Progress */}
          <div className="custom-card">
            <div style={{ display: 'flex', justifyContent: 'space-around', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Flame size={26} color="#D4A373" />
                <div>
                  <div style={{ fontWeight: '700', fontSize: '16px' }}>12</div>
                  <div style={{ fontSize: '11px', color: '#7C706A' }}>Day Streak</div>
                </div>
              </div>
              <div style={{ width: '1px', background: '#EFE7E2' }} />
              <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
                <Award size={26} color="#8A9A86" />
                <div>
                  <div style={{ fontWeight: '700', fontSize: '16px' }}>85%</div>
                  <div style={{ fontSize: '11px', color: '#7C706A' }}>Weekly Goal</div>
                </div>
              </div>
            </div>
            <div style={{ height: '6px', background: '#E8DFD9', borderRadius: '3px' }}>
              <div style={{ width: '85%', height: '100%', background: '#3D322C', borderRadius: '3px' }} />
            </div>
          </div>
        </div>
      )}

      {/* AFFIRMATIONS TAB */}
      {activeTab === 'affirmations' && (
        <div style={{ padding: '20px', height: 'calc(100vh - 120px)', display: 'flex', flexDirection: 'column' }}>
          <h2 className="font-heading" style={{ fontSize: '20px', fontWeight: '700', textAlign: 'center', marginBottom: '16px' }}>Affirmations</h2>
          <div style={{ display: 'flex', justifyContent: 'center', gap: '8px', marginBottom: '20px' }}>
            <span className="chip-pill active">Today</span>
            <span className="chip-pill">Favorites</span>
            <span className="chip-pill">All</span>
          </div>

          <div className="custom-card" style={{ flex: 1, backgroundColor: '#F3EDE8', display: 'flex', flexDirection: 'column', justifyContent: 'space-between', padding: '28px' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between' }}>
              <Heart size={22} color="#5A4B44" />
              <Sparkles size={22} color="#C9B6A8" />
            </div>
            <div style={{ textAlign: 'center' }}>
              <h2 className="font-heading" style={{ fontSize: '26px', fontWeight: '700', lineHeight: '1.4' }}>
                "{affirmations[currentAffirmationIndex]}"
              </h2>
            </div>
            <div style={{ display: 'flex', justifyContent: 'space-around', alignItems: 'center' }}>
              <button onClick={() => setCurrentAffirmationIndex((currentAffirmationIndex + 1) % affirmations.length)} style={{ background: '#FFF', border: 'none', padding: '12px', borderRadius: '50%', cursor: 'pointer' }}><RefreshCw size={20} /></button>
              <button style={{ background: '#3D322C', border: 'none', padding: '16px', borderRadius: '50%', color: '#FFF', cursor: 'pointer' }}><Heart size={24} /></button>
              <button onClick={() => setCurrentAffirmationIndex((currentAffirmationIndex + 1) % affirmations.length)} style={{ background: '#FFF', border: 'none', padding: '12px', borderRadius: '50%', cursor: 'pointer' }}><ChevronRight size={20} /></button>
            </div>
          </div>
        </div>
      )}

      {/* MEDITATION TAB */}
      {activeTab === 'meditation' && (
        <div style={{ padding: '20px' }}>
          <h2 className="font-heading" style={{ fontSize: '20px', fontWeight: '700', textAlign: 'center', marginBottom: '20px' }}>Meditation</h2>
          <div className="custom-card" style={{ padding: '0', overflow: 'hidden', marginBottom: '24px' }}>
            <img src="/assets/images/featured_meditation.jpg" style={{ width: '100%', height: '160px', objectFit: 'cover' }} />
            <div style={{ padding: '16px' }}>
              <div style={{ fontWeight: '700', fontSize: '16px' }}>Find Inner Peace</div>
              <div style={{ fontSize: '13px', color: '#7C706A' }}>10 min • Guided</div>
            </div>
          </div>
        </div>
      )}

      {/* SLEEP TAB */}
      {activeTab === 'sleep' && (
        <div style={{ padding: '20px' }}>
          <h2 className="font-heading" style={{ fontSize: '20px', fontWeight: '700', textAlign: 'center', marginBottom: '20px' }}>Sleep</h2>
          <div className="custom-card" style={{ backgroundColor: '#F3EDE8', padding: '24px' }}>
            <h3 className="font-heading" style={{ fontSize: '22px', fontWeight: '700', marginBottom: '8px' }}>Tonight, let's sleep better</h3>
            <p style={{ fontSize: '13px', color: '#7C706A' }}>Relax your mind and wake up refreshed.</p>
          </div>
        </div>
      )}

      {/* PROFILE TAB */}
      {activeTab === 'profile' && (
        <div style={{ padding: '20px' }}>
          <div style={{ textAlign: 'center', marginBottom: '24px' }}>
            <div style={{ width: '80px', height: '80px', borderRadius: '50%', background: '#F3EDE8', margin: '0 auto 12px', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <User size={40} color="#5A4B44" />
            </div>
            <h2 className="font-heading" style={{ fontSize: '20px', fontWeight: '700' }}>Alex</h2>
            <p style={{ fontSize: '13px', color: '#7C706A' }}>alex@email.com</p>
          </div>
        </div>
      )}

      {/* PERSISTENT PLAYER BAR */}
      <div className="player-bar" onClick={() => setPlayerOpen(true)}>
        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <div style={{ width: '40px', height: '40px', borderRadius: '20px', background: '#E8DFD9', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
            <Sparkles size={20} color="#5A4B44" />
          </div>
          <div>
            <div style={{ fontSize: '13px', fontWeight: '700' }}>Morning Meditation</div>
            <div style={{ fontSize: '11px', color: '#7C706A' }}>{affirmations[currentAffirmationIndex].slice(0, 30)}...</div>
          </div>
        </div>
        <button onClick={(e) => { e.stopPropagation(); setIsPlaying(!isPlaying); }} style={{ background: 'none', border: 'none', cursor: 'pointer' }}>
          {isPlaying ? <Pause size={28} color="#3D322C" /> : <Play size={28} color="#3D322C" />}
        </button>
      </div>

      {/* FULL PLAYER MODAL */}
      {playerOpen && (
        <div style={{ position: 'fixed', inset: 0, background: '#F8F4F1', zIndex: 200, padding: '24px', display: 'flex', flexDirection: 'column', justifyContent: 'space-between' }}>
          <div style={{ display: 'flex', justifyContent: 'space-between' }}>
            <button onClick={() => setPlayerOpen(false)} style={{ background: 'none', border: 'none' }}><ArrowLeft size={24} /></button>
            <Heart size={24} />
          </div>

          <div style={{ width: '220px', height: '220px', borderRadius: '50%', background: '#F3EDE8', margin: '0 auto', border: '2px solid #EFE7E2', overflow: 'hidden' }}>
            <img src="/assets/images/featured_meditation.jpg" style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
          </div>

          <div style={{ textAlign: 'center' }}>
            <h2 className="font-heading" style={{ fontSize: '24px', fontWeight: '700' }}>Morning Meditation</h2>
            <p style={{ fontSize: '14px', color: '#7C706A' }}>10:00</p>
          </div>

          <div style={{ display: 'flex', justifyContent: 'center', gap: '24px', alignItems: 'center' }}>
            <button onClick={() => setIsPlaying(!isPlaying)} style={{ width: '64px', height: '64px', borderRadius: '50%', background: '#3D322C', border: 'none', color: '#FFF', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              {isPlaying ? <Pause size={32} /> : <Play size={32} />}
            </button>
          </div>
        </div>
      )}

      {/* BOTTOM NAVIGATION */}
      <div className="bottom-nav">
        <button className={`nav-item ${activeTab === 'home' ? 'active' : ''}`} onClick={() => setActiveTab('home')}>
          <Home size={20} /> Home
        </button>
        <button className={`nav-item ${activeTab === 'affirmations' ? 'active' : ''}`} onClick={() => setActiveTab('affirmations')}>
          <Quote size={20} /> Affirmations
        </button>
        <button className={`nav-item ${activeTab === 'meditation' ? 'active' : ''}`} onClick={() => setActiveTab('meditation')}>
          <Sparkles size={20} /> Meditation
        </button>
        <button className={`nav-item ${activeTab === 'sleep' ? 'active' : ''}`} onClick={() => setActiveTab('sleep')}>
          <Moon size={20} /> Sleep
        </button>
        <button className={`nav-item ${activeTab === 'profile' ? 'active' : ''}`} onClick={() => setActiveTab('profile')}>
          <User size={20} /> Profile
        </button>
      </div>
    </div>
  );
};

ReactDOM.createRoot(document.getElementById('root')).render(<AVANApp />);
