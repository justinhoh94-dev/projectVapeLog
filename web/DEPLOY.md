# Deploy VapeLog Web App - Quick Guide

Your app is ready to deploy! Choose one of these super easy options:

## Option 1: Vercel (Easiest - 2 Minutes) ⭐️

### Using GitHub (Recommended)

1. **Push your code to GitHub** (already done!)

2. **Go to** https://vercel.com
   - Click "Sign Up" (use your GitHub account)
   - Click "Import Project"
   - Select your `projectVapeLog` repository
   - Set **Root Directory** to `web`
   - Click "Deploy"

3. **Done!** You'll get a URL like:
   ```
   https://vapelog-xyz123.vercel.app
   ```

4. **Open on your phone** and add to home screen!

### Using CLI

```bash
# Install Vercel CLI
npm i -g vercel

# Login
vercel login

# Deploy (from the web/ directory)
cd /home/user/projectVapeLog/web
vercel --prod

# You'll get a URL - open it on your phone!
```

## Option 2: Netlify (Also Easy)

### Using Netlify Drop

1. **Build the app** (already done!)
   ```bash
   cd /home/user/projectVapeLog/web
   npm run build
   ```

2. **Go to** https://app.netlify.com/drop
   - Drag and drop the `/home/user/projectVapeLog/web/.next` folder
   - Get instant URL!

### Using CLI

```bash
# Install Netlify CLI
npm i -g netlify-cli

# Login
netlify login

# Deploy
cd /home/user/projectVapeLog/web
netlify deploy --prod

# Follow prompts, then get your URL!
```

## Option 3: Cloudflare Pages

1. **Go to** https://pages.cloudflare.com
2. Connect your GitHub account
3. Select the `projectVapeLog` repo
4. Set:
   - **Build command**: `npm run build`
   - **Build output directory**: `.next`
   - **Root directory**: `web`
5. Click "Save and Deploy"

## After Deployment

### Install on iPhone

1. Open the deployed URL in **Safari**
2. Tap the Share button (square with arrow up)
3. Scroll down and tap **"Add to Home Screen"**
4. Tap "Add"
5. VapeLog now appears on your home screen! 🎉

### Install on Android

1. Open the deployed URL in **Chrome**
2. Tap the three-dot menu
3. Tap **"Install app"** or **"Add to Home screen"**
4. Follow the prompts
5. VapeLog appears in your app drawer! 🎉

## Testing Locally on Phone

Want to test before deploying?

```bash
# Find your computer's local IP
# Mac/Linux: ifconfig | grep "inet "
# Windows: ipconfig

# Start the dev server
cd /home/user/projectVapeLog/web
npm run dev

# On your phone (same WiFi network), open:
http://YOUR_LOCAL_IP:3000
# Example: http://192.168.1.100:3000
```

## Camera Permissions

⚠️ **Important**: The camera scanner **requires HTTPS**
- ✅ Works on deployed sites (Vercel, Netlify, etc.)
- ✅ Works on `localhost` for development
- ❌ Does NOT work on `http://192.168.x.x` (local IP)

For local testing with camera, use:
```bash
# Use ngrok to get HTTPS tunnel
npx ngrok http 3000
# Use the https URL it provides
```

## Troubleshooting

### Build fails
```bash
cd /home/user/projectVapeLog/web
rm -rf node_modules .next
npm install
npm run build
```

### Camera not working
- Make sure you're on HTTPS (not HTTP)
- Grant camera permissions when prompted
- Use Safari on iOS, Chrome on Android
- Check browser console for errors

### Can't install to home screen
- iOS: Must use Safari browser
- Android: Use Chrome browser
- Make sure you're on HTTPS
- Try refreshing the page

## Your URLs

After deployment, you'll have:

**Web App**: `https://your-app-name.vercel.app`
**Install as App**: Just open URL and "Add to Home Screen"!

## What You Get

✅ **Full offline support** - Works without internet
✅ **Camera scanner** - ML-powered label reading
✅ **Privacy-first** - All data local to your phone
✅ **Fast** - Instant loading from home screen
✅ **Cross-platform** - Works on any phone

---

**Ready to deploy?** Pick Vercel (easiest) and deploy in 2 minutes! 🚀
