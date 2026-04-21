import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const filePath = path.resolve(__dirname, 'Menu.jsx');
console.log('Reading file:', filePath);

try {
  let content = fs.readFileSync(filePath, 'utf8');
  const lines = content.split('\n');
  
  console.log('File loaded, total lines:', lines.length);
  
  // Find the index of the useSearchParams line
  let insertIndex = -1;
  for (let i = 0; i < lines.length; i++) {
    if (lines[i].includes('const [searchParams] = useSearchParams()')) {
      insertIndex = i + 1;
      console.log('Found useSearchParams at line', i + 1);
      break;
    }
  }
  
  if (insertIndex > 0) {
    const newUseEffect = `
  // Handle itemId from query parameter (from MostWanted click)
  useEffect(() => {
    const itemId = searchParams.get('itemId');
    if (itemId && menuData.length > 0) {
      // Find the item in menuData
      let targetItem = null;
      let targetCategoryId = null;
      
      for (const category of menuData) {
        const foundProduct = category.products.find(p => String(p.item_id) === String(itemId));
        if (foundProduct) {
          targetItem = foundProduct;
          targetCategoryId = category.category_id;
          break;
        }
      }
      
      if (targetItem && targetCategoryId) {
        // Scroll to the category first
        setTimeout(() => {
          scrollToCategory(targetCategoryId);
          // Then open the modal after a short delay
          setTimeout(() => {
            openItemModal(targetItem);
            // Clear the query parameter
            window.history.replaceState({}, document.title, window.location.pathname);
          }, 500);
        }, 100);
      }
    }
  }, [menuData, searchParams]);`;
    
    lines.splice(insertIndex, 0, newUseEffect);
    const newContent = lines.join('\n');
    
    fs.writeFileSync(filePath, newContent, 'utf8');
    console.log('Successfully added useEffect hook');
    console.log('File modified:', filePath);
  } else {
    console.log('Could not find useSearchParams line');
  }
} catch (error) {
  console.error('Error:', error.message);
}
