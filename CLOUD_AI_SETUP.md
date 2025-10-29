# 🚀 Cloud AI Setup Guide for Mobile Users

This guide will help you set up AI-powered speech feedback on your mobile device **without installing Ollama**.

## ✨ What You'll Get

- 🎤 AI-generated speech questions
- 📊 Intelligent feedback and scoring
- 💡 Personalized improvement suggestions
- 📱 Works on iOS, Android, and Web
- 🌐 No local installation needed!

## 📋 Prerequisites

- Internet connection
- 5 minutes of your time
- A Google account (for free API key)

## 🔑 Step 1: Get Your Free Gemini API Key

### Option A: Quick Guide

1. **Visit**: https://makersuite.google.com/app/apikey
2. **Sign in** with your Google account
3. **Click** "Create API Key"
4. **Choose** "Create API key in new project" (or select existing project)
5. **Copy** the API key that appears

### Option B: Detailed Steps

1. Open your browser and go to: https://makersuite.google.com/app/apikey
2. You'll see the Google AI Studio page. Click **"Get API key"**

3. You'll be asked to sign in with Google if not already signed in

4. Click **"Create API key"** button

5. Select:
   - **"Create API key in new project"** if you're new to Google Cloud
   - Or select an existing project if you have one

6. Your API key will appear! It looks like:

   ```
   AIzaSyABcDeFgHiJkLmNoPqRsTuVwXyZ1234567
   ```

7. **Click the copy icon** to copy it to your clipboard

8. **Keep it safe!** Don't share this key publicly

## 📝 Step 2: Add API Key to Your App

### Method 1: Using .env File (Recommended)

1. Open the `.env` file in the root of your project

2. Find the line that says:

   ```env
   GEMINI_API_KEY=
   ```

3. Paste your API key after the equals sign:

   ```env
   GEMINI_API_KEY=AIzaSyABcDeFgHiJkLmNoPqRsTuVwXyZ1234567
   ```

4. **Save the file**

### Method 2: Using VS Code

1. In VS Code, press `Ctrl+P` (or `Cmd+P` on Mac)
2. Type `.env` and press Enter
3. Add your API key as shown above
4. Save with `Ctrl+S` (or `Cmd+S`)

## ▶️ Step 3: Run Your App

### Android

```bash
flutter run
```

### iOS

```bash
flutter run
```

### Web

```bash
flutter run -d chrome
```

## ✅ Step 4: Verify It's Working

Once your app launches:

1. **Look for the AI indicator** in your app (if implemented)
   - 🟢 "Cloud AI (Gemini)" = Working!
   - 🟡 "Ollama" = Using local AI (desktop only)
   - 🔴 "Fallback" = Using offline mode

2. **Try generating a question**:
   - Select a topic (e.g., "Technology")
   - Click to generate a question
   - You should get an AI-generated question!

3. **Check the console** for confirmation:
   ```
   AI Availability - Cloud: true, Ollama: false
   Using Cloud AI (Gemini) for question generation
   ```

## 🎉 You're All Set!

Your app now uses AI to:

- Generate custom speaking questions
- Analyze your speech content
- Provide detailed feedback
- Score your performance

## 💰 About the Free Tier

Google Gemini's free tier includes:

- **15 requests per minute**
- **1 million tokens per day**
- **Sufficient for**: 1000+ speeches daily
- **Cost**: Completely FREE

This is more than enough for personal use!

## 🔒 Security Tips

✅ **DO:**

- Keep your API key in `.env` file
- Add `.env` to `.gitignore` (already done)
- Never commit API keys to Git

❌ **DON'T:**

- Share your API key publicly
- Post it on GitHub, Discord, etc.
- Hardcode it in your source code

## 🐛 Troubleshooting

### Problem: "Using Fallback" even with API key

**Solution:**

1. Check that `.env` file is in the project root
2. Verify API key has no extra spaces
3. Restart the app completely
4. Check internet connection

### Problem: API key not working

**Solution:**

1. Verify the API key is correct (copy again from Google AI Studio)
2. Make sure you have internet connection
3. Check if you've exceeded free tier limits
4. Wait a few minutes and try again

### Problem: Errors in console

**Solution:**

1. Check the error message in debug console
2. Common issues:
   - `403`: API key may be invalid
   - `429`: Rate limit exceeded (wait 1 minute)
   - `Network error`: Check internet connection

### Still Not Working?

Check the debug logs:

```dart
await HybridAIService.instance.forceCheckAIAvailability();
print('Cloud AI: ${HybridAIService.instance.isCloudAIAvailable}');
print('Active: ${HybridAIService.instance.activeAIService}');
```

## 📊 Monitoring Your Usage

Want to see how many API calls you're making?

1. Visit: https://console.cloud.google.com/apis/dashboard
2. Sign in with the same Google account
3. Select your project
4. View API usage statistics

## 🔄 Switching Between AI Services

The app automatically prioritizes:

1. **Cloud AI (Gemini)** - If API key is set and online
2. **Ollama** - If running locally (desktop developers)
3. **Fallback** - If offline or no AI available

No configuration needed - it just works!

## 🆘 Need Help?

- 📖 [Full AI Integration README](./lib/src/ai-integration/README.md)
- 🌐 [Google Gemini API Docs](https://ai.google.dev/docs)
- 🔑 [Get API Key](https://makersuite.google.com/app/apikey)
- 💬 Open an issue on GitHub

## 🎓 What's Next?

Now that you have AI set up:

1. ✅ Practice your public speaking
2. ✅ Get AI-powered feedback
3. ✅ Improve based on suggestions
4. ✅ Track your progress over time
5. 🚀 Become a confident speaker!

Happy speaking! 🎤✨
