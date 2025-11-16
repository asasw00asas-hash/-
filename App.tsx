import React, { useState } from 'react';
import { PromptDetails, PromptData } from './types';
import { generateFunnyLine, generatePronunciationPrompt } from './services/geminiService';
import InputForm from './components/InputForm';
import OutputDisplay from './components/OutputDisplay';
import { LogoIcon } from './components/icons/LogoIcon';

const App: React.FC = () => {
  const [formData, setFormData] = useState<PromptDetails>({
    age: '24',
    gender: 'ولد',
    category: 'كوميدي',
    situation: '',
    tone: '',
  });

  const [generatedPrompt, setGeneratedPrompt] = useState<string>('');
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const [error, setError] = useState<string | null>(null);

  const handleGenerateClick = async () => {
    setIsLoading(true);
    setError(null);
    setGeneratedPrompt('');
    try {
      // Step 1: Generate the funny Egyptian line for a child
      const funnyLine = await generateFunnyLine(formData);
      
      // Step 2: Combine form data with the new line
      const fullPromptData: PromptData = {
        ...formData,
        line: funnyLine,
      };

      // Step 3: Generate the final professional English prompt
      const result = await generatePronunciationPrompt(fullPromptData);
      setGeneratedPrompt(result);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An unknown error occurred.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-slate-900 text-slate-200 font-sans flex flex-col p-4 md:p-6" dir="rtl">
      <header className="flex items-center justify-center mb-6 text-center">
        <LogoIcon className="w-10 h-10 md:w-12 md:h-12 text-cyan-400 ml-3" />
        <h1 className="text-3xl md:text-4xl font-bold bg-gradient-to-r from-cyan-400 to-indigo-500 text-transparent bg-clip-text">
          مولّد برومبت النطق
        </h1>
      </header>
      
      <main className="flex-grow grid grid-cols-1 lg:grid-cols-2 gap-6">
        <InputForm 
          formData={formData} 
          setFormData={setFormData}
          onGenerate={handleGenerateClick}
          isLoading={isLoading}
        />
        <OutputDisplay
          prompt={generatedPrompt}
          isLoading={isLoading}
          error={error}
        />
      </main>

      <footer className="text-center mt-8 text-slate-500 text-sm">
        <p>Powered by Gemini API. Made for creators.</p>
      </footer>
    </div>
  );
};

export default App;
