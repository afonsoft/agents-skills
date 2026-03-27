# Frontend Architecture

This document contains patterns, best practices, and implementation guides for modern frontend architecture, component design, and performance optimization.

## Overview

Comprehensive guide for building scalable, maintainable frontend applications with focus on component architecture, state management, and performance optimization.

## Quick Reference

| Pattern | Use Case | Framework | Complexity |
|---------|----------|-----------|------------|
| **Component-First** | Reusable UI elements | React, Vue, Angular | Medium |
| **State Management** | Complex application state | Redux, Zustand, Pinia | High |
| **Micro-Frontends** | Large teams, independent deployments | Module Federation | High |
| **Server Components** | Performance, SEO | Next.js, Remix | Medium |
| **Progressive Web App** | Offline capabilities, native feel | Any framework | Medium |

## Component Architecture Patterns

### Pattern 1: Atomic Design

- **When to use**: Design systems, consistent UI, team collaboration
- **Implementation**: Atoms → Molecules → Organisms → Templates → Pages
- **Code Example**:
```typescript
// Atoms: Basic building blocks
interface ButtonProps {
  variant: 'primary' | 'secondary' | 'danger';
  size: 'sm' | 'md' | 'lg';
  children: React.ReactNode;
  onClick?: () => void;
  disabled?: boolean;
}

const Button: React.FC<ButtonProps> = ({ 
  variant, 
  size, 
  children, 
  onClick, 
  disabled = false 
}) => {
  const baseClasses = 'font-medium rounded-lg transition-colors focus:outline-none focus:ring-2';
  
  const variantClasses = {
    primary: 'bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500',
    secondary: 'bg-gray-200 text-gray-900 hover:bg-gray-300 focus:ring-gray-500',
    danger: 'bg-red-600 text-white hover:bg-red-700 focus:ring-red-500'
  };
  
  const sizeClasses = {
    sm: 'px-3 py-1.5 text-sm',
    md: 'px-4 py-2 text-base',
    lg: 'px-6 py-3 text-lg'
  };
  
  return (
    <button
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${
        disabled ? 'opacity-50 cursor-not-allowed' : ''
      }`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};

// Molecules: Combination of atoms
interface SearchInputProps {
  placeholder?: string;
  onSearch: (query: string) => void;
  loading?: boolean;
}

const SearchInput: React.FC<SearchInputProps> = ({ 
  placeholder = 'Search...', 
  onSearch, 
  loading = false 
}) => {
  const [query, setQuery] = useState('');
  const debouncedQuery = useDebounce(query, 300);
  
  useEffect(() => {
    if (debouncedQuery) {
      onSearch(debouncedQuery);
    }
  }, [debouncedQuery, onSearch]);
  
  return (
    <div className="relative">
      <input
        type="text"
        placeholder={placeholder}
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        className="w-full px-4 py-2 pr-10 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500"
      />
      <div className="absolute right-2 top-2.5">
        {loading ? (
          <div className="animate-spin h-5 w-5 border-2 border-blue-600 border-t-transparent rounded-full" />
        ) : (
          <svg className="h-5 w-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
        )}
      </div>
    </div>
  );
};

// Organisms: Complex components
interface UserListProps {
  users: User[];
  onUserSelect: (user: User) => void;
  loading?: boolean;
}

const UserList: React.FC<UserListProps> = ({ users, onUserSelect, loading = false }) => {
  return (
    <div className="bg-white rounded-lg shadow-md">
      <div className="p-4 border-b border-gray-200">
        <SearchInput onSearch={(query) => console.log('Search:', query)} />
      </div>
      
      <div className="divide-y divide-gray-200">
        {loading ? (
          <div className="p-8 text-center">
            <div className="animate-spin h-8 w-8 border-2 border-blue-600 border-t-transparent rounded-full mx-auto" />
          </div>
        ) : users.length === 0 ? (
          <div className="p-8 text-center text-gray-500">
            No users found
          </div>
        ) : (
          users.map((user) => (
            <UserListItem 
              key={user.id} 
              user={user} 
              onSelect={() => onUserSelect(user)} 
            />
          ))
        )}
      </div>
    </div>
  );
};

// Templates: Layout structure
interface UserManagementTemplateProps {
  children: React.ReactNode;
  sidebar?: React.ReactNode;
}

const UserManagementTemplate: React.FC<UserManagementTemplateProps> = ({ 
  children, 
  sidebar 
}) => {
  return (
    <div className="min-h-screen bg-gray-50">
      <Header />
      <div className="flex">
        {sidebar && <aside className="w-64 bg-white shadow-md">{sidebar}</aside>}
        <main className="flex-1 p-6">{children}</main>
      </div>
    </div>
  );
};

// Pages: Complete views
const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedUser, setSelectedUser] = useState<User | null>(null);
  
  useEffect(() => {
    fetchUsers().then((data) => {
      setUsers(data);
      setLoading(false);
    });
  }, []);
  
  const sidebar = (
    <div className="p-4">
      <h3 className="font-semibold text-gray-900 mb-4">Quick Actions</h3>
      <Button variant="primary" className="w-full mb-2">
        Add User
      </Button>
      <Button variant="secondary" className="w-full">
        Export Users
      </Button>
    </div>
  );
  
  return (
    <UserManagementTemplate sidebar={sidebar}>
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900">User Management</h1>
        <p className="text-gray-600">Manage system users and permissions</p>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <UserList 
            users={users} 
            loading={loading}
            onUserSelect={setSelectedUser} 
          />
        </div>
        
        <div>
          {selectedUser && (
            <UserDetails user={selectedUser} />
          )}
        </div>
      </div>
    </UserManagementTemplate>
  );
};
```

- **Pros**: Consistency, reusability, maintainability
- **Cons**: Initial complexity, over-engineering risk

### Pattern 2: Compound Components

- **When to use**: Flexible component APIs, related components
- **Implementation**: Parent component with context for child communication
- **Code Example**:
```typescript
// Compound Component Pattern
import React, { createContext, useContext, useState } from 'react';

interface TabsContextType {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const TabsContext = createContext<TabsContextType | undefined>(undefined);

interface TabsProps {
  children: React.ReactNode;
  defaultTab?: string;
}

const Tabs: React.FC<TabsProps> = ({ children, defaultTab }) => {
  const [activeTab, setActiveTab] = useState(defaultTab || '');
  
  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className="tabs">{children}</div>
    </TabsContext.Provider>
  );
};

const useTabs = () => {
  const context = useContext(TabsContext);
  if (!context) {
    throw new Error('Tabs components must be used within a Tabs provider');
  }
  return context;
};

interface TabListProps {
  children: React.ReactNode;
}

const TabList: React.FC<TabListProps> = ({ children }) => {
  return (
    <div className="flex space-x-1 border-b border-gray-200 mb-4">
      {children}
    </div>
  );
};

interface TabProps {
  children: React.ReactNode;
  value: string;
}

const Tab: React.FC<TabProps> = ({ children, value }) => {
  const { activeTab, setActiveTab } = useTabs();
  const isActive = activeTab === value;
  
  return (
    <button
      className={`px-4 py-2 font-medium text-sm border-b-2 transition-colors ${
        isActive
          ? 'border-blue-500 text-blue-600'
          : 'border-transparent text-gray-500 hover:text-gray-700'
      }`}
      onClick={() => setActiveTab(value)}
    >
      {children}
    </button>
  );
};

interface TabPanelsProps {
  children: React.ReactNode;
}

const TabPanels: React.FC<TabPanelsProps> = ({ children }) => {
  return <div className="tab-panels">{children}</div>;
};

interface TabPanelProps {
  children: React.ReactNode;
  value: string;
}

const TabPanel: React.FC<TabPanelProps> = ({ children, value }) => {
  const { activeTab } = useTabs();
  
  if (activeTab !== value) {
    return null;
  }
  
  return <div className="tab-panel">{children}</div>;
};

// Usage
const UserProfile: React.FC = () => {
  return (
    <Tabs defaultTab="profile">
      <TabList>
        <Tab value="profile">Profile</Tab>
        <Tab value="settings">Settings</Tab>
        <Tab value="security">Security</Tab>
      </TabList>
      
      <TabPanels>
        <TabPanel value="profile">
          <ProfileForm />
        </TabPanel>
        <TabPanel value="settings">
          <SettingsForm />
        </TabPanel>
        <TabPanel value="security">
          <SecurityForm />
        </TabPanel>
      </TabPanels>
    </Tabs>
  );
};

// Compound Component with more complex state
interface AccordionContextType {
  openItems: Set<string>;
  toggleItem: (value: string) => void;
  allowMultiple?: boolean;
}

const AccordionContext = createContext<AccordionContextType | undefined>(undefined);

interface AccordionProps {
  children: React.ReactNode;
  allowMultiple?: boolean;
  defaultOpen?: string[];
}

const Accordion: React.FC<AccordionProps> = ({ 
  children, 
  allowMultiple = false, 
  defaultOpen = [] 
}) => {
  const [openItems, setOpenItems] = useState<Set<string>>(new Set(defaultOpen));
  
  const toggleItem = (value: string) => {
    setOpenItems(prev => {
      const newSet = new Set(prev);
      
      if (newSet.has(value)) {
        newSet.delete(value);
      } else if (allowMultiple) {
        newSet.add(value);
      } else {
        // Single mode: close all others and open this one
        newSet.clear();
        newSet.add(value);
      }
      
      return newSet;
    });
  };
  
  return (
    <AccordionContext.Provider value={{ openItems, toggleItem, allowMultiple }}>
      <div className="accordion">{children}</div>
    </AccordionContext.Provider>
  );
};

const useAccordion = () => {
  const context = useContext(AccordionContext);
  if (!context) {
    throw new Error('Accordion components must be used within an Accordion provider');
  }
  return context;
};

interface AccordionItemProps {
  children: React.ReactNode;
  value: string;
}

const AccordionItem: React.FC<AccordionItemProps> = ({ children, value }) => {
  const { openItems } = useAccordion();
  const isOpen = openItems.has(value);
  
  return (
    <div className={`accordion-item ${isOpen ? 'open' : 'closed'}`}>
      {React.Children.map(children, child => 
        React.isValidElement(child) 
          ? React.cloneElement(child as any, { value, isOpen })
          : child
      )}
    </div>
  );
};

interface AccordionHeaderProps {
  children: React.ReactNode;
  value?: string;
  isOpen?: boolean;
}

const AccordionHeader: React.FC<AccordionHeaderProps> = ({ 
  children, 
  value, 
  isOpen 
}) => {
  const { toggleItem } = useAccordion();
  
  return (
    <button
      className="w-full px-4 py-3 text-left font-medium bg-gray-50 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-blue-500 flex justify-between items-center"
      onClick={() => value && toggleItem(value)}
    >
      {children}
      <svg
        className={`w-5 h-5 transform transition-transform ${isOpen ? 'rotate-180' : ''}`}
        fill="none"
        stroke="currentColor"
        viewBox="0 0 24 24"
      >
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
      </svg>
    </button>
  );
};

interface AccordionPanelProps {
  children: React.ReactNode;
  value?: string;
  isOpen?: boolean;
}

const AccordionPanel: React.FC<AccordionPanelProps> = ({ children, isOpen }) => {
  return (
    <div
      className={`overflow-hidden transition-all duration-200 ${
        isOpen ? 'max-h-96' : 'max-h-0'
      }`}
    >
      <div className="p-4 bg-white">{children}</div>
    </div>
  );
};
```

- **Pros**: Flexible API, composability, clean component structure
- **Cons**: Learning curve, context complexity

## State Management Patterns

### Pattern 3: Modern State Management with Zustand

- **When to use**: Medium complexity state, minimal boilerplate
- **Implementation**: Zustand stores with TypeScript
- **Code Example**:
```typescript
// Zustand Store Setup
import { create } from 'zustand';
import { devtools, persist } from 'zustand/middleware';

// Types
interface User {
  id: string;
  name: string;
  email: string;
  avatar?: string;
}

interface AuthState {
  user: User | null;
  token: string | null;
  isAuthenticated: boolean;
  loading: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

// Auth Store
export const useAuthStore = create<AuthState>()(
  devtools(
    persist(
      (set, get) => ({
        user: null,
        token: null,
        isAuthenticated: false,
        loading: false,
        
        login: async (email: string, password: string) => {
          set({ loading: true });
          
          try {
            const response = await fetch('/api/auth/login', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ email, password })
            });
            
            if (!response.ok) {
              throw new Error('Login failed');
            }
            
            const { user, token } = await response.json();
            
            set({
              user,
              token,
              isAuthenticated: true,
              loading: false
            });
          } catch (error) {
            set({ loading: false });
            throw error;
          }
        },
        
        logout: () => {
          set({
            user: null,
            token: null,
            isAuthenticated: false
          });
        },
        
        refreshToken: async () => {
          const { token } = get();
          if (!token) return;
          
          try {
            const response = await fetch('/api/auth/refresh', {
              method: 'POST',
              headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
              }
            });
            
            if (!response.ok) {
              get().logout();
              return;
            }
            
            const { token: newToken } = await response.json();
            set({ token: newToken });
          } catch (error) {
            get().logout();
          }
        }
      }),
      {
        name: 'auth-storage',
        partialize: (state) => ({
          user: state.user,
          token: state.token,
          isAuthenticated: state.isAuthenticated
        })
      }
    ),
    { name: 'auth-store' }
  )
);

// Product Store
interface Product {
  id: string;
  name: string;
  price: number;
  category: string;
  description: string;
  images: string[];
  inStock: boolean;
}

interface ProductState {
  products: Product[];
  categories: string[];
  filters: {
    category: string;
    priceRange: [number, number];
    search: string;
  };
  loading: boolean;
  error: string | null;
  
  // Actions
  fetchProducts: () => Promise<void>;
  setFilters: (filters: Partial<ProductState['filters']>) => void;
  clearFilters: () => void;
  getProductById: (id: string) => Product | undefined;
}

export const useProductStore = create<ProductState>()(
  devtools(
    (set, get) => ({
      products: [],
      categories: [],
      filters: {
        category: '',
        priceRange: [0, 1000],
        search: ''
      },
      loading: false,
      error: null,
      
      fetchProducts: async () => {
        set({ loading: true, error: null });
        
        try {
          const { filters } = get();
          const params = new URLSearchParams();
          
          if (filters.category) params.append('category', filters.category);
          if (filters.search) params.append('search', filters.search);
          params.append('minPrice', filters.priceRange[0].toString());
          params.append('maxPrice', filters.priceRange[1].toString());
          
          const response = await fetch(`/api/products?${params}`);
          
          if (!response.ok) {
            throw new Error('Failed to fetch products');
          }
          
          const { products, categories } = await response.json();
          
          set({
            products,
            categories,
            loading: false
          });
        } catch (error) {
          set({
            error: error instanceof Error ? error.message : 'Unknown error',
            loading: false
          });
        }
      },
      
      setFilters: (newFilters) => {
        set((state) => ({
          filters: { ...state.filters, ...newFilters }
        }));
      },
      
      clearFilters: () => {
        set({
          filters: {
            category: '',
            priceRange: [0, 1000],
            search: ''
          }
        });
      },
      
      getProductById: (id: string) => {
        const { products } = get();
        return products.find(product => product.id === id);
      }
    }),
    { name: 'product-store' }
  )
);

// Cart Store
interface CartItem {
  product: Product;
  quantity: number;
}

interface CartState {
  items: CartItem[];
  total: number;
  itemCount: number;
  
  // Actions
  addItem: (product: Product, quantity?: number) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
}

export const useCartStore = create<CartState>()(
  devtools(
    persist(
      (set, get) => ({
        items: [],
        total: 0,
        itemCount: 0,
        
        addItem: (product: Product, quantity = 1) => {
          set((state) => {
            const existingItem = state.items.find(
              item => item.product.id === product.id
            );
            
            let newItems: CartItem[];
            
            if (existingItem) {
              newItems = state.items.map(item =>
                item.product.id === product.id
                  ? { ...item, quantity: item.quantity + quantity }
                  : item
              );
            } else {
              newItems = [...state.items, { product, quantity }];
            }
            
            const total = newItems.reduce(
              (sum, item) => sum + item.product.price * item.quantity,
              0
            );
            
            const itemCount = newItems.reduce(
              (sum, item) => sum + item.quantity,
              0
            );
            
            return {
              items: newItems,
              total,
              itemCount
            };
          });
        },
        
        removeItem: (productId: string) => {
          set((state) => {
            const newItems = state.items.filter(
              item => item.product.id !== productId
            );
            
            const total = newItems.reduce(
              (sum, item) => sum + item.product.price * item.quantity,
              0
            );
            
            const itemCount = newItems.reduce(
              (sum, item) => sum + item.quantity,
              0
            );
            
            return {
              items: newItems,
              total,
              itemCount
            };
          });
        },
        
        updateQuantity: (productId: string, quantity: number) => {
          if (quantity <= 0) {
            get().removeItem(productId);
            return;
          }
          
          set((state) => {
            const newItems = state.items.map(item =>
              item.product.id === productId
                ? { ...item, quantity }
                : item
            );
            
            const total = newItems.reduce(
              (sum, item) => sum + item.product.price * item.quantity,
              0
            );
            
            const itemCount = newItems.reduce(
              (sum, item) => sum + item.quantity,
              0
            );
            
            return {
              items: newItems,
              total,
              itemCount
            };
          });
        },
        
        clearCart: () => {
          set({
            items: [],
            total: 0,
            itemCount: 0
          });
        }
      }),
      {
        name: 'cart-storage'
      }
    ),
    { name: 'cart-store' }
  )
);

// Hook for combining stores
export const useAppData = () => {
  const auth = useAuthStore();
  const products = useProductStore();
  const cart = useCartStore();
  
  return {
    auth,
    products,
    cart
  };
};
```

- **Pros**: Minimal boilerplate, TypeScript support, performance
- **Cons**: Learning curve, less structure than Redux

## Performance Optimization Patterns

### Pattern 4: Code Splitting and Lazy Loading

- **When to use**: Large applications, initial load optimization
- **Implementation**: Dynamic imports, React.lazy, Suspense
- **Code Example**:
```typescript
// Route-based code splitting
import React, { Suspense, lazy } from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { LoadingSpinner, ErrorBoundary } from '../components';

// Lazy load components
const Dashboard = lazy(() => import('../pages/Dashboard'));
const Users = lazy(() => import('../pages/Users'));
const Products = lazy(() => import('../pages/Products'));
const Settings = lazy(() => import('../pages/Settings'));
const Profile = lazy(() => import('../pages/Profile'));

const AppRoutes: React.FC = () => {
  return (
    <ErrorBoundary>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          <Route path="/" element={<Navigate to="/dashboard" replace />} />
          <Route path="/dashboard" element={<Dashboard />} />
          <Route path="/users/*" element={<Users />} />
          <Route path="/products/*" element={<Products />} />
          <Route path="/settings/*" element={<Settings />} />
          <Route path="/profile" element={<Profile />} />
        </Routes>
      </Suspense>
    </ErrorBoundary>
  );
};

// Component-based code splitting
const HeavyComponent = lazy(() => 
  import('../components/HeavyComponent').then(module => ({
    default: module.HeavyComponent
  }))
);

// Conditional loading based on user permissions
const AdminPanel = lazy(() => 
  import('../pages/AdminPanel').then(module => ({
    default: module.AdminPanel
  }))
);

const ConditionalAdminPanel: React.FC<{ isAdmin: boolean }> = ({ isAdmin }) => {
  if (!isAdmin) return null;
  
  return (
    <Suspense fallback={<LoadingSpinner />}>
      <AdminPanel />
    </Suspense>
  );
};

// Preloading strategy
const usePreloadRoute = (routePath: string) => {
  useEffect(() => {
    const preloadComponent = async () => {
      try {
        switch (routePath) {
          case '/users':
            await import('../pages/Users');
            break;
          case '/products':
            await import('../pages/Products');
            break;
          case '/settings':
            await import('../pages/Settings');
            break;
        }
      } catch (error) {
        console.warn(`Failed to preload ${routePath}:`, error);
      }
    };
    
    // Preload after initial render
    const timer = setTimeout(preloadComponent, 2000);
    
    return () => clearTimeout(timer);
  }, [routePath]);
};

// Intersection Observer for lazy loading
const LazyImage: React.FC<{
  src: string;
  alt: string;
  placeholder?: string;
  className?: string;
}> = ({ src, alt, placeholder = '/placeholder.jpg', className }) => {
  const [imageSrc, setImageSrc] = useState(placeholder);
  const [imageRef, inView] = useInView({
    triggerOnce: true,
    threshold: 0.1
  });
  
  useEffect(() => {
    if (inView && src !== imageSrc) {
      const img = new Image();
      img.onload = () => setImageSrc(src);
      img.src = src;
    }
  }, [inView, src, imageSrc]);
  
  return (
    <img
      ref={imageRef}
      src={imageSrc}
      alt={alt}
      className={className}
      loading="lazy"
    />
  );
};

// Bundle analysis and optimization
const webpackBundleAnalyzer = () => {
  if (process.env.NODE_ENV === 'development') {
    const BundleAnalyzerPlugin = require('webpack-bundle-analyzer').BundleAnalyzerPlugin;
    
    return new BundleAnalyzerPlugin({
      analyzerMode: 'server',
      openAnalyzer: false,
      analyzerPort: 8888
    });
  }
  
  return null;
};

// Dynamic imports with error handling
const dynamicImport = async <T,>(
  importFn: () => Promise<T>,
  retries = 3,
  delay = 1000
): Promise<T> => {
  try {
    return await importFn();
  } catch (error) {
    if (retries > 0) {
      await new Promise(resolve => setTimeout(resolve, delay));
      return dynamicImport(importFn, retries - 1, delay * 2);
    }
    throw error;
  }
};

// Usage with retry
const loadComponent = () => {
  return dynamicImport(() => import('../components/HeavyComponent'));
};
```

- **Pros**: Reduced bundle size, faster initial load, better UX
- **Cons**: Complexity, loading states management

### Pattern 5: Virtual Scrolling

- **When to use**: Large lists, performance optimization
- **Implementation**: Custom virtual scroll or library integration
- **Code Example**:
```typescript
// Virtual Scrolling Implementation
import React, { useState, useEffect, useRef, useMemo } from 'react';

interface VirtualScrollProps<T> {
  items: T[];
  itemHeight: number;
  containerHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  overscan?: number;
}

function VirtualScroll<T>({
  items,
  itemHeight,
  containerHeight,
  renderItem,
  overscan = 5
}: VirtualScrollProps<T>) {
  const [scrollTop, setScrollTop] = useState(0);
  const containerRef = useRef<HTMLDivElement>(null);
  
  const visibleRange = useMemo(() => {
    const startIndex = Math.max(0, Math.floor(scrollTop / itemHeight) - overscan);
    const endIndex = Math.min(
      items.length - 1,
      Math.ceil((scrollTop + containerHeight) / itemHeight) + overscan
    );
    
    return { startIndex, endIndex };
  }, [scrollTop, itemHeight, containerHeight, overscan, items.length]);
  
  const visibleItems = useMemo(() => {
    return items.slice(visibleRange.startIndex, visibleRange.endIndex + 1);
  }, [items, visibleRange]);
  
  const totalHeight = items.length * itemHeight;
  
  const handleScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  }, []);
  
  return (
    <div
      ref={containerRef}
      style={{ height: containerHeight, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        <div
          style={{
            position: 'absolute',
            top: visibleRange.startIndex * itemHeight,
            left: 0,
            right: 0
          }}
        >
          {visibleItems.map((item, index) => (
            <div
              key={visibleRange.startIndex + index}
              style={{ height: itemHeight }}
            >
              {renderItem(item, visibleRange.startIndex + index)}
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

// Usage with large dataset
const LargeUserList: React.FC = () => {
  const [users] = useState(() => 
    Array.from({ length: 10000 }, (_, i) => ({
      id: i + 1,
      name: `User ${i + 1}`,
      email: `user${i + 1}@example.com`,
      avatar: `https://i.pravatar.cc/150?img=${i + 1}`
    }))
  );
  
  const renderUser = (user: any, index: number) => (
    <div
      key={user.id}
      className="flex items-center p-4 border-b border-gray-200 hover:bg-gray-50"
    >
      <img
        src={user.avatar}
        alt={user.name}
        className="w-10 h-10 rounded-full mr-4"
      />
      <div>
        <div className="font-medium text-gray-900">{user.name}</div>
        <div className="text-sm text-gray-500">{user.email}</div>
      </div>
    </div>
  );
  
  return (
    <div className="h-96 border border-gray-300 rounded-lg">
      <VirtualScroll
        items={users}
        itemHeight={80}
        containerHeight={384}
        renderItem={renderUser}
      />
    </div>
  );
};

// Advanced virtual scroll with variable item heights
interface VariableVirtualScrollProps<T> {
  items: T[];
  estimatedItemHeight: number;
  containerHeight: number;
  renderItem: (item: T, index: number) => React.ReactNode;
  getItemHeight?: (item: T, index: number) => number;
}

function VariableVirtualScroll<T>({
  items,
  estimatedItemHeight,
  containerHeight,
  renderItem,
  getItemHeight = () => estimatedItemHeight
}: VariableVirtualScrollProps<T>) {
  const [scrollTop, setScrollTop] = useState(0);
  const [itemHeights, setItemHeights] = useState<number[]>([]);
  const containerRef = useRef<HTMLDivElement>(null);
  
  const itemPositions = useMemo(() => {
    const positions = [0];
    let totalHeight = 0;
    
    for (let i = 0; i < items.length; i++) {
      const height = itemHeights[i] || estimatedItemHeight;
      totalHeight += height;
      positions.push(totalHeight);
    }
    
    return positions;
  }, [items.length, itemHeights, estimatedItemHeight]);
  
  const visibleRange = useMemo(() => {
    const startIndex = itemPositions.findIndex(
      (pos, index) => 
        index < itemPositions.length - 1 && 
        pos <= scrollTop && 
        itemPositions[index + 1] > scrollTop
    );
    
    const adjustedStartIndex = Math.max(0, startIndex - 1);
    
    let endIndex = adjustedStartIndex;
    let accumulatedHeight = 0;
    
    for (let i = adjustedStartIndex; i < items.length; i++) {
      if (accumulatedHeight >= containerHeight) break;
      accumulatedHeight += itemHeights[i] || estimatedItemHeight;
      endIndex = i;
    }
    
    return { startIndex: adjustedStartIndex, endIndex };
  }, [scrollTop, itemPositions, containerHeight, items.length, itemHeights, estimatedItemHeight]);
  
  const totalHeight = itemPositions[itemPositions.length - 1];
  
  const handleScroll = useCallback((e: React.UIEvent<HTMLDivElement>) => {
    setScrollTop(e.currentTarget.scrollTop);
  }, []);
  
  const updateItemHeight = useCallback((index: number, height: number) => {
    setItemHeights(prev => {
      if (prev[index] === height) return prev;
      const newHeights = [...prev];
      newHeights[index] = height;
      return newHeights;
    });
  }, []);
  
  return (
    <div
      ref={containerRef}
      style={{ height: containerHeight, overflow: 'auto' }}
      onScroll={handleScroll}
    >
      <div style={{ height: totalHeight, position: 'relative' }}>
        {items.slice(visibleRange.startIndex, visibleRange.endIndex + 1).map((item, index) => {
          const actualIndex = visibleRange.startIndex + index;
          const top = itemPositions[actualIndex];
          
          return (
            <MeasureItem
              key={actualIndex}
              index={actualIndex}
              top={top}
              onHeightChange={updateItemHeight}
            >
              {renderItem(item, actualIndex)}
            </MeasureItem>
          );
        })}
      </div>
    </div>
  );
}

// Component to measure item height
interface MeasureItemProps {
  index: number;
  top: number;
  onHeightChange: (index: number, height: number) => void;
  children: React.ReactNode;
}

const MeasureItem: React.FC<MeasureItemProps> = ({
  index,
  top,
  onHeightChange,
  children
}) => {
  const ref = useRef<HTMLDivElement>(null);
  
  useEffect(() => {
    if (ref.current) {
      const height = ref.current.offsetHeight;
      onHeightChange(index, height);
    }
  }, [index, onHeightChange]);
  
  return (
    <div
      ref={ref}
      style={{
        position: 'absolute',
        top,
        left: 0,
        right: 0
      }}
    >
      {children}
    </div>
  );
};
```

- **Pros**: Performance with large datasets, memory efficiency
- **Cons**: Implementation complexity, dynamic height challenges

## Progressive Web App Patterns

### Pattern 6: Service Worker Implementation

- **When to use**: Offline functionality, performance optimization
- **Implementation**: Service worker for caching and background sync
- **Code Example**:
```typescript
// Service Worker Registration
export const registerServiceWorker = () => {
  if ('serviceWorker' in navigator) {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/sw.js')
        .then((registration) => {
          console.log('SW registered: ', registration);
          
          // Check for updates
          registration.addEventListener('updatefound', () => {
            const newWorker = registration.installing;
            if (newWorker) {
              newWorker.addEventListener('statechange', () => {
                if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                  // New content is available
                  if (confirm('New content available. Reload?')) {
                    window.location.reload();
                  }
                }
              });
            }
          });
        })
        .catch((registrationError) => {
          console.log('SW registration failed: ', registrationError);
        });
    });
  }
};

// Service Worker (sw.js)
const CACHE_NAME = 'app-v1';
const STATIC_CACHE = 'static-v1';
const DYNAMIC_CACHE = 'dynamic-v1';

const STATIC_ASSETS = [
  '/',
  '/index.html',
  '/manifest.json',
  '/offline.html',
  // CSS, JS, images...
];

// Install event
self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE)
      .then((cache) => {
        console.log('Caching static assets');
        return cache.addAll(STATIC_ASSETS);
      })
  );
});

// Activate event
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== STATIC_CACHE && cacheName !== DYNAMIC_CACHE) {
            console.log('Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    })
  );
});

// Fetch event
self.addEventListener('fetch', (event) => {
  const { request } = event;
  const url = new URL(request.url);
  
  // Cache-first for static assets
  if (STATIC_ASSETS.includes(url.pathname)) {
    event.respondWith(
      caches.match(request)
        .then((response) => {
          return response || fetch(request);
        })
    );
    return;
  }
  
  // Network-first for API calls
  if (url.pathname.startsWith('/api/')) {
    event.respondWith(
      fetch(request)
        .then((response) => {
          // Cache successful responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(DYNAMIC_CACHE)
              .then((cache) => {
                cache.put(request, responseClone);
              });
          }
          return response;
        })
        .catch(() => {
          // Try cache on network failure
          return caches.match(request);
        })
    );
    return;
  }
  
  // Stale-while-revalidate for other requests
  event.respondWith(
    caches.match(request)
      .then((cachedResponse) => {
        const fetchPromise = fetch(request)
          .then((networkResponse) => {
            // Cache the fresh response
            caches.open(DYNAMIC_CACHE)
              .then((cache) => {
                cache.put(request, networkResponse.clone());
              });
            return networkResponse;
          })
          .catch(() => {
            // Return cached version if network fails
            return cachedResponse;
          });
        
        return cachedResponse || fetchPromise;
      })
  );
});

// Background sync
self.addEventListener('sync', (event) => {
  if (event.tag === 'background-sync') {
    event.waitUntil(doBackgroundSync());
  }
});

async function doBackgroundSync() {
  // Get stored actions from IndexedDB
  const actions = await getStoredActions();
  
  for (const action of actions) {
    try {
      await fetch('/api/sync', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(action)
      });
      
      // Remove successful action from storage
      await removeStoredAction(action.id);
    } catch (error) {
      console.error('Sync failed for action:', action, error);
    }
  }
}

// Push notifications
self.addEventListener('push', (event) => {
  const options = {
    body: event.data.text(),
    icon: '/icon-192x192.png',
    badge: '/badge-72x72.png',
    vibrate: [100, 50, 100],
    data: {
      dateOfArrival: Date.now(),
      primaryKey: 1
    },
    actions: [
      {
        action: 'explore',
        title: 'Explore',
        icon: '/images/checkmark.png'
      },
      {
        action: 'close',
        title: 'Close',
        icon: '/images/xmark.png'
      }
    ]
  };
  
  event.waitUntil(
    self.registration.showNotification('Push Notification', options)
  );
});

// Notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  
  if (event.action === 'explore') {
    event.waitUntil(
      clients.openWindow('/explore')
    );
  } else if (event.action === 'close') {
    // Just close the notification
  } else {
    // Default action - open app
    event.waitUntil(
      clients.matchAll().then((clientList) => {
        for (const client of clientList) {
          if (client.url === '/' && 'focus' in client) {
            return client.focus();
          }
        }
        if (clients.openWindow) {
          return clients.openWindow('/');
        }
      })
    );
  }
});

// React Hook for PWA features
export const usePWA = () => {
  const [isOnline, setIsOnline] = useState(navigator.onLine);
  const [installPrompt, setInstallPrompt] = useState<any>(null);
  
  useEffect(() => {
    const handleOnline = () => setIsOnline(true);
    const handleOffline = () => setIsOnline(false);
    
    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    
    // Listen for install prompt
    window.addEventListener('beforeinstallprompt', (e) => {
      e.preventDefault();
      setInstallPrompt(e);
    });
    
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, []);
  
  const installApp = async () => {
    if (!installPrompt) return false;
    
    try {
      const result = await installPrompt.prompt();
      const { outcome } = result;
      
      if (outcome === 'accepted') {
        setInstallPrompt(null);
        return true;
      }
      
      return false;
    } catch (error) {
      console.error('Install failed:', error);
      return false;
    }
  };
  
  const canInstall = !!installPrompt;
  
  return {
    isOnline,
    canInstall,
    installApp
  };
};

// Background sync manager
export class BackgroundSyncManager {
  private db: IDBDatabase | null = null;
  
  async init() {
    return new Promise<void>((resolve, reject) => {
      const request = indexedDB.open('background-sync', 1);
      
      request.onerror = () => reject(request.error);
      request.onsuccess = () => {
        this.db = request.result;
        resolve();
      };
      
      request.onupgradeneeded = () => {
        const db = request.result;
        if (!db.objectStoreNames.contains('actions')) {
          const store = db.createObjectStore('actions', { keyPath: 'id' });
          store.createIndex('timestamp', 'timestamp', { unique: false });
        }
      };
    });
  }
  
  async storeAction(action: any) {
    if (!this.db) await this.init();
    
    const transaction = this.db!.transaction(['actions'], 'readwrite');
    const store = transaction.objectStore('actions');
    
    action.id = Date.now().toString();
    action.timestamp = Date.now();
    
    return store.add(action);
  }
  
  async getStoredActions(): Promise<any[]> {
    if (!this.db) await this.init();
    
    const transaction = this.db!.transaction(['actions'], 'readonly');
    const store = transaction.objectStore('actions');
    
    return new Promise((resolve, reject) => {
      const request = store.getAll();
      request.onsuccess = () => resolve(request.result);
      request.onerror = () => reject(request.error);
    });
  }
  
  async removeStoredAction(id: string) {
    if (!this.db) await this.init();
    
    const transaction = this.db!.transaction(['actions'], 'readwrite');
    const store = transaction.objectStore('actions');
    
    return store.delete(id);
  }
}
```

- **Pros**: Offline functionality, improved performance, native-like experience
- **Cons**: Complexity, cache management challenges

## Best Practices

### Component Design
1. **Single Responsibility**: Each component has one clear purpose
2. **Composition over Inheritance**: Prefer composition patterns
3. **Props Interface**: Clear, typed props with defaults
4. **State Management**: Local state for UI, global state for data
5. **Error Boundaries**: Handle errors gracefully

### Performance Optimization
1. **Code Splitting**: Split bundles by route and feature
2. **Lazy Loading**: Load components and images on demand
3. **Memoization**: Use React.memo, useMemo, useCallback appropriately
4. **Virtual Scrolling**: For large lists and tables
5. **Bundle Analysis**: Regularly analyze and optimize bundle size

### Accessibility
1. **Semantic HTML**: Use proper HTML elements
2. **ARIA Labels**: Provide accessible labels and descriptions
3. **Keyboard Navigation**: Ensure keyboard accessibility
4. **Focus Management**: Manage focus properly
5. **Screen Reader Support**: Test with screen readers

## Common Pitfalls

### Architecture Pitfalls
- **Over-engineering**: Complex patterns for simple problems
- **Prop Drilling**: Excessive prop passing
- **God Components**: Components doing too much
- **Inconsistent State**: Mixed state management approaches

### Performance Pitfalls
- **Unnecessary Re-renders**: Poor memoization usage
- **Large Bundles**: No code splitting
- **Memory Leaks**: Uncleaned up effects and listeners
- **Inefficient Lists**: No virtualization for large datasets

## Tools & Resources

### Frameworks
- **React**: Component-based UI library
- **Vue**: Progressive framework
- **Angular**: Full-featured framework
- **Svelte**: Compile-time framework

### State Management
- **Zustand**: Minimal state management
- **Redux**: Predictable state container
- **MobX**: Reactive state management
- **Jotai**: Atomic state management

### Build Tools
- **Vite**: Fast build tool
- **Webpack**: Module bundler
- **Rollup**: Library bundler
- **Parcel**: Zero-config bundler

### Testing
- **Jest**: Testing framework
- **React Testing Library**: Component testing
- **Cypress**: E2E testing
- **Storybook**: Component development

This guide provides comprehensive frontend architecture patterns and should be adapted to specific project requirements and team capabilities.
