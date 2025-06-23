# Web App Footer Component

This component creates a responsive footer for your web application with:
- Company name and copyright
- Useful navigation links section
- Legal links section (Terms & Conditions, Privacy Policy, Cookies Policy)

The footer uses a three-column layout on medium and larger screens, collapsing to a single column on mobile devices.

## React Component Code

```jsx
import React from 'react';

const Footer = () => {
  // Replace with your actual company name
  const companyName = "Your Company Name";
  
  // Current year for copyright
  const currentYear = new Date().getFullYear();
  
  // Useful links - customize these as needed
  const usefulLinks = [
    { name: "Home", url: "/" },
    { name: "About Us", url: "/about" },
    { name: "Services", url: "/services" },
    { name: "Contact", url: "/contact" },
    { name: "FAQ", url: "/faq" }
  ];
  
  // Legal links
  const legalLinks = [
    { name: "Terms & Conditions", url: "/terms" },
    { name: "Privacy Policy", url: "/privacy" },
    { name: "Cookies Policy", url: "/cookies" }
  ];

  return (
    <footer className="bg-primary-900 text-white py-8 mt-auto">
      <div className="container mx-auto px-4">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Company Info */}
          <div>
            <h3 className="text-xl font-semibold mb-4">
              {companyName}
            </h3>
            <p className="text-primary-200 mb-2">
              Your trusted partner in [your industry].
            </p>
            <p className="text-primary-200">
              © {currentYear} {companyName}. All rights reserved.
            </p>
          </div>
          
          {/* Useful Links */}
          <div>
            <h3 className="text-xl font-semibold mb-4">Useful Links</h3>
            <ul>
              {usefulLinks.map((link) => (
                <li key={link.name} className="mb-2">
                  <a 
                    href={link.url} 
                    className="text-primary-200 hover:text-white transition duration-200"
                  >
                    {link.name}
                  </a>
                </li>
              ))}
            </ul>
          </div>
          
          {/* Legal Links */}
          <div>
            <h3 className="text-xl font-semibold mb-4">Legal</h3>
            <ul>
              {legalLinks.map((link) => (
                <li key={link.name} className="mb-2">
                  <a 
                    href={link.url} 
                    className="text-primary-200 hover:text-white transition duration-200"
                  >
                    {link.name}
                  </a>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
```

## Customization Options

### Colors
- The footer uses Tailwind CSS classes with a primary color theme
- Replace `bg-primary-900` with your brand's dark color
- Replace `text-primary-200` with your brand's light accent color

### Content
- Update the `companyName` variable with your actual company name
- Modify the "Your trusted partner in [your industry]" tagline
- Customize the `usefulLinks` array with your site's navigation structure
- Ensure the `legalLinks` URLs point to your actual legal pages

### Layout
- The footer uses a responsive grid layout (3 columns on desktop, 1 column on mobile)
- Adjust the `grid-cols-1 md:grid-cols-3` classes if you need a different column structure
- Modify spacing with the `py-8`, `mb-4`, `mb-2` classes as needed

## Implementation Notes

1. This component requires Tailwind CSS for styling
2. The `mt-auto` class ensures the footer stays at the bottom of the page when used with a flex layout
3. The component automatically updates the copyright year
4. All links include hover effects for better user experience