## Enabling GitHub Pages

1. Go to your repository → Settings → Pages
2. Under "Source", select: Deploy from a branch
3. Branch: `main`, Folder: `/docs`
4. Click Save
5. Your site will be live at https://ampslabs.github.io/smart-refresher/


### Important
- Open the docs URL with a trailing slash (`.../smart-refresher/`) so relative asset links resolve correctly on GitHub Pages.
- A `404.html` fallback is included to redirect unknown routes back to `index.html`.
