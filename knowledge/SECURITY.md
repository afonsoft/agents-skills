# Security Playbook

This document contains security patterns, best practices, and implementation guides for application security, vulnerability prevention, and compliance.

## Overview

Comprehensive guide for implementing security measures across web applications, APIs, databases, and infrastructure with focus on defense-in-depth strategies.

## Quick Reference

| Security Area | Key Measures | Tools | Complexity |
|---------------|--------------|-------|------------|
| **Authentication** | MFA, OAuth 2.0, JWT | Auth0, Firebase Auth | Medium |
| **Authorization** | RBAC, ABAC, Principle of Least Privilege | Casbin, OPA | High |
| **Data Protection** | Encryption, Tokenization | HashiCorp Vault | High |
| **API Security** | Rate Limiting, Input Validation | OWASP ZAP, Burp Suite | Medium |
| **Infrastructure** | Network Segmentation, Hardening | Terraform, Ansible | High |

## Authentication & Authorization Patterns

### Pattern 1: Multi-Factor Authentication (MFA)

- **When to use**: All user authentication, sensitive operations
- **Implementation**: Time-based OTP, SMS, Biometrics, Hardware keys
- **Code Example**:
```typescript
// MFA Implementation with TOTP
import speakeasy from 'speakeasy';
import qrcode from 'qrcode';
import crypto from 'crypto';

interface MFASetup {
  secret: string;
  qrCode: string;
  backupCodes: string[];
}

class MFAService {
  // Generate MFA secret for user
  generateMFASecret(userEmail: string): MFASetup {
    const secret = speakeasy.generateSecret({
      name: `MyApp (${userEmail})`,
      issuer: 'MyApp',
      length: 32
    });
    
    // Generate QR code
    const qrCodeUrl = qrcode.toDataURL(secret.otpauth_url!);
    
    // Generate backup codes
    const backupCodes = this.generateBackupCodes();
    
    return {
      secret: secret.base32!,
      qrCode: await qrCodeUrl,
      backupCodes
    };
  }
  
  // Verify TOTP token
  verifyToken(secret: string, token: string): boolean {
    return speakeasy.totp.verify({
      secret,
      encoding: 'base32',
      token,
      window: 2 // Allow 2 windows before/after for clock drift
    });
  }
  
  // Generate backup codes
  private generateBackupCodes(): string[] {
    const codes: string[] = [];
    for (let i = 0; i < 10; i++) {
      codes.push(crypto.randomBytes(4).toString('hex').toUpperCase());
    }
    return codes;
  }
  
  // Verify backup code
  async verifyBackupCode(userId: string, code: string): Promise<boolean> {
    const userBackupCodes = await this.getUserBackupCodes(userId);
    const codeIndex = userBackupCodes.findIndex(c => c === code && !c.used);
    
    if (codeIndex !== -1) {
      // Mark code as used
      await this.markBackupCodeUsed(userId, codeIndex);
      return true;
    }
    
    return false;
  }
}

// Authentication Service with MFA
interface AuthResult {
  success: boolean;
  requiresMFA?: boolean;
  token?: string;
  error?: string;
}

class AuthenticationService {
  constructor(
    private userService: UserService,
    private mfaService: MFAService,
    private jwtService: JWTService
  ) {}
  
  async authenticate(email: string, password: string): Promise<AuthResult> {
    // Validate credentials
    const user = await this.userService.findByEmail(email);
    if (!user || !await this.verifyPassword(password, user.passwordHash)) {
      return { success: false, error: 'Invalid credentials' };
    }
    
    // Check if MFA is enabled
    if (user.mfaEnabled) {
      return { success: false, requiresMFA: true, error: 'MFA required' };
    }
    
    // Generate JWT token
    const token = this.jwtService.generateToken({
      userId: user.id,
      email: user.email,
      role: user.role
    });
    
    return { success: true, token };
  }
  
  async authenticateWithMFA(
    email: string, 
    password: string, 
    mfaToken: string
  ): Promise<AuthResult> {
    // First validate password
    const user = await this.userService.findByEmail(email);
    if (!user || !await this.verifyPassword(password, user.passwordHash)) {
      return { success: false, error: 'Invalid credentials' };
    }
    
    // Verify MFA token
    if (!this.mfaService.verifyToken(user.mfaSecret!, mfaToken)) {
      return { success: false, error: 'Invalid MFA token' };
    }
    
    // Generate JWT token
    const token = this.jwtService.generateToken({
      userId: user.id,
      email: user.email,
      role: user.role,
      mfaVerified: true
    });
    
    return { success: true, token };
  }
  
  private async verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
  }
}

// Express.js Middleware for MFA verification
const requireMFA = (req: Request, res: Response, next: NextFunction) => {
  const token = req.headers.authorization?.replace('Bearer ', '');
  
  if (!token) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET!) as any;
    
    if (!decoded.mfaVerified && decoded.userId) {
      const user = await userService.findById(decoded.userId);
      if (user?.mfaEnabled) {
        return res.status(403).json({ 
          error: 'MFA verification required',
          requiresMFA: true
        });
      }
    }
    
    req.user = decoded;
    next();
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }
};
```

- **Pros**: Enhanced security, protection against credential theft
- **Cons**: User experience complexity, backup management

### Pattern 2: Role-Based Access Control (RBAC)

- **When to use**: Multi-user applications, permission management
- **Implementation**: Hierarchical roles, permission inheritance
- **Code Example**:
```typescript
// RBAC Implementation
interface Permission {
  id: string;
  name: string;
  resource: string;
  action: string;
  description: string;
}

interface Role {
  id: string;
  name: string;
  description: string;
  permissions: Permission[];
  parent?: string; // For role hierarchy
}

interface User {
  id: string;
  email: string;
  roles: Role[];
  customPermissions?: Permission[];
}

class RBACService {
  private roles: Map<string, Role> = new Map();
  private userRoles: Map<string, string[]> = new Map();
  
  constructor() {
    this.initializeDefaultRoles();
  }
  
  private initializeDefaultRoles() {
    // Define permissions
    const permissions = [
      { id: 'user.read', name: 'Read Users', resource: 'user', action: 'read' },
      { id: 'user.write', name: 'Write Users', resource: 'user', action: 'write' },
      { id: 'user.delete', name: 'Delete Users', resource: 'user', action: 'delete' },
      { id: 'product.read', name: 'Read Products', resource: 'product', action: 'read' },
      { id: 'product.write', name: 'Write Products', resource: 'product', action: 'write' },
      { id: 'product.delete', name: 'Delete Products', resource: 'product', action: 'delete' },
      { id: 'order.read', name: 'Read Orders', resource: 'order', action: 'read' },
      { id: 'order.write', name: 'Write Orders', resource: 'order', action: 'write' },
      { id: 'order.delete', name: 'Delete Orders', resource: 'order', action: 'delete' },
      { id: 'system.admin', name: 'System Administration', resource: 'system', action: 'admin' }
    ];
    
    // Define roles
    const roles: Role[] = [
      {
        id: 'viewer',
        name: 'Viewer',
        description: 'Can read most resources',
        permissions: permissions.filter(p => 
          p.action === 'read' && p.resource !== 'system'
        )
      },
      {
        id: 'editor',
        name: 'Editor',
        description: 'Can read and write most resources',
        permissions: permissions.filter(p => 
          (p.action === 'read' || p.action === 'write') && 
          p.resource !== 'system' &&
          !(p.resource === 'user' && p.action === 'write')
        ),
        parent: 'viewer'
      },
      {
        id: 'manager',
        name: 'Manager',
        description: 'Can manage users and orders',
        permissions: permissions.filter(p => 
          p.resource !== 'system' && p.resource !== 'product.delete'
        ),
        parent: 'editor'
      },
      {
        id: 'admin',
        name: 'Administrator',
        description: 'Full system access',
        permissions: permissions,
        parent: 'manager'
      }
    ];
    
    roles.forEach(role => this.roles.set(role.id, role));
  }
  
  // Assign roles to user
  assignRole(userId: string, roleId: string) {
    if (!this.userRoles.has(userId)) {
      this.userRoles.set(userId, []);
    }
    
    const userRoleList = this.userRoles.get(userId)!;
    if (!userRoleList.includes(roleId)) {
      userRoleList.push(roleId);
    }
  }
  
  // Get all permissions for a user (including inherited)
  getUserPermissions(userId: string): Permission[] {
    const userRoleIds = this.userRoles.get(userId) || [];
    const allPermissions = new Set<Permission>();
    
    for (const roleId of userRoleIds) {
      const role = this.roles.get(roleId);
      if (role) {
        // Add role permissions
        role.permissions.forEach(p => allPermissions.add(p));
        
        // Add inherited permissions
        let currentRole = role;
        while (currentRole.parent) {
          const parentRole = this.roles.get(currentRole.parent);
          if (parentRole) {
            parentRole.permissions.forEach(p => allPermissions.add(p));
            currentRole = parentRole;
          } else {
            break;
          }
        }
      }
    }
    
    return Array.from(allPermissions);
  }
  
  // Check if user has specific permission
  hasPermission(userId: string, resource: string, action: string): boolean {
    const permissions = this.getUserPermissions(userId);
    return permissions.some(p => 
      p.resource === resource && p.action === action
    );
  }
  
  // Check if user has any permission on resource
  hasResourceAccess(userId: string, resource: string): boolean {
    const permissions = this.getUserPermissions(userId);
    return permissions.some(p => p.resource === resource);
  }
}

// Express.js middleware for RBAC
const requirePermission = (resource: string, action: string) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const userId = req.user?.id;
    
    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }
    
    if (!rbacService.hasPermission(userId, resource, action)) {
      return res.status(403).json({ 
        error: 'Insufficient permissions',
        required: `${resource}.${action}`
      });
    }
    
    next();
  };
};

// Usage in routes
app.get('/api/users', 
  authenticate, 
  requirePermission('user', 'read'), 
  userController.getUsers
);

app.post('/api/users', 
  authenticate, 
  requirePermission('user', 'write'), 
  userController.createUser
);

app.delete('/api/users/:id', 
  authenticate, 
  requirePermission('user', 'delete'), 
  userController.deleteUser
);

// Attribute-Based Access Control (ABAC) extension
interface Policy {
  id: string;
  name: string;
  conditions: PolicyCondition[];
  effect: 'allow' | 'deny';
  priority: number;
}

interface PolicyCondition {
  attribute: string;
  operator: 'eq' | 'ne' | 'gt' | 'lt' | 'in' | 'contains';
  value: any;
}

class ABACService {
  private policies: Policy[] = [];
  
  addPolicy(policy: Policy) {
    this.policies.push(policy);
    this.policies.sort((a, b) => b.priority - a.priority);
  }
  
  evaluate(attributes: Record<string, any>): boolean {
    for (const policy of this.policies) {
      if (this.evaluateConditions(policy.conditions, attributes)) {
        return policy.effect === 'allow';
      }
    }
    
    return false; // Default deny
  }
  
  private evaluateConditions(conditions: PolicyCondition[], attributes: Record<string, any>): boolean {
    return conditions.every(condition => {
      const attributeValue = attributes[condition.attribute];
      
      switch (condition.operator) {
        case 'eq':
          return attributeValue === condition.value;
        case 'ne':
          return attributeValue !== condition.value;
        case 'gt':
          return attributeValue > condition.value;
        case 'lt':
          return attributeValue < condition.value;
        case 'in':
          return Array.isArray(condition.value) && condition.value.includes(attributeValue);
        case 'contains':
          return typeof attributeValue === 'string' && attributeValue.includes(condition.value);
        default:
          return false;
      }
    });
  }
}

// Example ABAC policies
const abacService = new ABACService();

// Policy: Only users can access their own data
abacService.addPolicy({
  id: 'own-data-access',
  name: 'Users can access their own data',
  conditions: [
    { attribute: 'user.role', operator: 'eq', value: 'user' },
    { attribute: 'resource.owner', operator: 'eq', value: 'user.id' }
  ],
  effect: 'allow',
  priority: 100
});

// Policy: Managers can access data in their department
abacService.addPolicy({
  id: 'department-access',
  name: 'Managers can access department data',
  conditions: [
    { attribute: 'user.role', operator: 'eq', value: 'manager' },
    { attribute: 'resource.department', operator: 'eq', value: 'user.department' }
  ],
  effect: 'allow',
  priority: 90
});

// Policy: Admins can access everything
abacService.addPolicy({
  id: 'admin-access',
  name: 'Admins have full access',
  conditions: [
    { attribute: 'user.role', operator: 'eq', value: 'admin' }
  ],
  effect: 'allow',
  priority: 1000
});
```

- **Pros**: Granular access control, scalable permission management
- **Cons**: Complexity, performance overhead

## Data Protection Patterns

### Pattern 3: Encryption at Rest and in Transit

- **When to use**: Sensitive data storage, secure communication
- **Implementation**: AES-256, TLS 1.3, key management
- **Code Example**:
```typescript
// Encryption Service
import crypto from 'crypto';
import { createCipheriv, createDecipheriv, randomBytes } from 'crypto';

interface EncryptionResult {
  encrypted: string;
  iv: string;
  tag: string;
}

class EncryptionService {
  private readonly algorithm = 'aes-256-gcm';
  private readonly keyLength = 32; // 256 bits
  
  constructor(private masterKey: string) {
    // Ensure key is correct length
    if (this.masterKey.length !== this.keyLength) {
      throw new Error('Master key must be 32 characters long');
    }
  }
  
  // Encrypt sensitive data
  encrypt(plaintext: string): EncryptionResult {
    const iv = randomBytes(16); // Initialization vector
    const cipher = createCipheriv(this.algorithm, this.masterKey, iv);
    
    let encrypted = cipher.update(plaintext, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const tag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      tag: tag.toString('hex')
    };
  }
  
  // Decrypt sensitive data
  decrypt(encryptedData: EncryptionResult): string {
    const decipher = createDecipheriv(
      this.algorithm, 
      this.masterKey, 
      Buffer.from(encryptedData.iv, 'hex')
    );
    
    decipher.setAuthTag(Buffer.from(encryptedData.tag, 'hex'));
    
    let decrypted = decipher.update(encryptedData.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
  
  // Hash passwords securely
  hashPassword(password: string): Promise<string> {
    return new Promise((resolve, reject) => {
      const salt = randomBytes(16).toString('hex');
      
      crypto.pbkdf2(password, salt, 100000, 64, 'sha512', (err, derivedKey) => {
        if (err) reject(err);
        else resolve(`${salt}:${derivedKey.toString('hex')}`);
      });
    });
  }
  
  // Verify password hash
  async verifyPassword(password: string, hash: string): Promise<boolean> {
    const [salt, originalHash] = hash.split(':');
    
    return new Promise((resolve, reject) => {
      crypto.pbkdf2(password, salt, 100000, 64, 'sha512', (err, derivedKey) => {
        if (err) reject(err);
        else resolve(derivedKey.toString('hex') === originalHash);
      });
    });
  }
}

// Key Management Service
interface KeyMetadata {
  keyId: string;
  version: number;
  algorithm: string;
  created: Date;
  status: 'active' | 'deprecated' | 'revoked';
}

class KeyManagementService {
  private keys: Map<string, { key: string; metadata: KeyMetadata }> = new Map();
  private currentKeyId: string = '';
  
  constructor() {
    this.generateInitialKey();
  }
  
  private generateInitialKey() {
    const keyId = crypto.randomUUID();
    const key = randomBytes(32).toString('hex');
    
    const metadata: KeyMetadata = {
      keyId,
      version: 1,
      algorithm: 'aes-256-gcm',
      created: new Date(),
      status: 'active'
    };
    
    this.keys.set(keyId, { key, metadata });
    this.currentKeyId = keyId;
  }
  
  // Generate new key version
  rotateKey(): string {
    const keyId = crypto.randomUUID();
    const key = randomBytes(32).toString('hex');
    
    // Depredate old key
    const oldKey = this.keys.get(this.currentKeyId);
    if (oldKey) {
      oldKey.metadata.status = 'deprecated';
    }
    
    const metadata: KeyMetadata = {
      keyId,
      version: oldKey ? oldKey.metadata.version + 1 : 1,
      algorithm: 'aes-256-gcm',
      created: new Date(),
      status: 'active'
    };
    
    this.keys.set(keyId, { key, metadata });
    this.currentKeyId = keyId;
    
    return keyId;
  }
  
  // Get current active key
  getCurrentKey(): { key: string; metadata: KeyMetadata } {
    const currentKey = this.keys.get(this.currentKeyId);
    if (!currentKey) {
      throw new Error('No active key found');
    }
    
    return currentKey;
  }
  
  // Get key by ID for decryption
  getKey(keyId: string): { key: string; metadata: KeyMetadata } {
    const key = this.keys.get(keyId);
    if (!key) {
      throw new Error(`Key ${keyId} not found`);
    }
    
    return key;
  }
}

// Secure Data Storage
class SecureDataService {
  constructor(
    private encryptionService: EncryptionService,
    private keyManagement: KeyManagementService
  ) {}
  
  // Store encrypted data with key metadata
  async storeSecureData(data: any, tableName: string): Promise<string> {
    const currentKey = this.keyManagement.getCurrentKey();
    const jsonString = JSON.stringify(data);
    const encrypted = this.encryptionService.encrypt(jsonString);
    
    const record = {
      id: crypto.randomUUID(),
      encrypted_data: encrypted.encrypted,
      iv: encrypted.iv,
      tag: encrypted.tag,
      key_id: currentKey.metadata.keyId,
      key_version: currentKey.metadata.version,
      created_at: new Date()
    };
    
    // Store in database
    await this.db(tableName).insert(record);
    
    return record.id;
  }
  
  // Retrieve and decrypt data
  async getSecureData(recordId: string, tableName: string): Promise<any> {
    const record = await this.db(tableName).where('id', recordId).first();
    
    if (!record) {
      throw new Error('Record not found');
    }
    
    // Get the key that was used for encryption
    const encryptionKey = this.keyManagement.getKey(record.key_id);
    const encryptionService = new EncryptionService(encryptionKey.key);
    
    const encryptedData = {
      encrypted: record.encrypted_data,
      iv: record.iv,
      tag: record.tag
    };
    
    const decryptedJson = encryptionService.decrypt(encryptedData);
    return JSON.parse(decryptedJson);
  }
}

// TLS Configuration for Express.js
import https from 'https';
import fs from 'fs';

const tlsOptions = {
  key: fs.readFileSync('./path/to/private.key'),
  cert: fs.readFileSync('./path/to/certificate.crt'),
  ca: fs.readFileSync('./path/to/ca_bundle.crt'),
  
  // Secure TLS configuration
  minVersion: 'TLSv1.2',
  ciphers: [
    'ECDHE-ECDSA-AES256-GCM-SHA384',
    'ECDHE-RSA-AES256-GCM-SHA384',
    'ECDHE-ECDSA-CHACHA20-POLY1305',
    'ECDHE-RSA-CHACHA20-POLY1305',
    'ECDHE-ECDSA-AES128-GCM-SHA256',
    'ECDHE-RSA-AES128-GCM-SHA256'
  ].join(':'),
  honorCipherOrder: true,
  
  // HSTS
  hsts: {
    maxAge: 31536000, // 1 year
    includeSubDomains: true,
    preload: true
  }
};

// Create HTTPS server
const secureServer = https.createServer(tlsOptions, app);

// Security headers middleware
const securityHeaders = (req: Request, res: Response, next: NextFunction) => {
  // Prevent clickjacking
  res.setHeader('X-Frame-Options', 'DENY');
  
  // Prevent MIME type sniffing
  res.setHeader('X-Content-Type-Options', 'nosniff');
  
  // XSS Protection
  res.setHeader('X-XSS-Protection', '1; mode=block');
  
  // Strict Transport Security
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains; preload');
  
  // Content Security Policy
  res.setHeader('Content-Security-Policy', 
    "default-src 'self'; " +
    "script-src 'self' 'unsafe-inline' https://trusted.cdn.com; " +
    "style-src 'self' 'unsafe-inline' https://trusted.cdn.com; " +
    "img-src 'self' data: https:; " +
    "font-src 'self' https://trusted.cdn.com; " +
    "connect-src 'self' https://api.example.com; " +
    "frame-ancestors 'none';"
  );
  
  // Referrer Policy
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  
  // Permissions Policy
  res.setHeader('Permissions-Policy', 
    'geolocation=(), ' +
    'microphone=(), ' +
    'camera=(), ' +
    'payment=(), ' +
    'usb=(), ' +
    'magnetometer=(), ' +
    'gyroscope=(), ' +
    'accelerometer=()'
  );
  
  next();
};
```

- **Pros**: Data confidentiality, compliance requirements, breach protection
- **Cons**: Performance overhead, key management complexity

## API Security Patterns

### Pattern 4: API Rate Limiting and Throttling

- **When to use**: Public APIs, DDoS protection, resource management
- **Implementation**: Token bucket, sliding window, distributed limiting
- **Code Example**:
```typescript
// Rate Limiting Implementation
interface RateLimitConfig {
  windowMs: number; // Time window in milliseconds
  maxRequests: number; // Max requests per window
  message?: string;
  skipSuccessfulRequests?: boolean;
  skipFailedRequests?: boolean;
}

interface RateLimitEntry {
  count: number;
  resetTime: number;
  lastRequest: number;
}

class RateLimiter {
  private store: Map<string, RateLimitEntry> = new Map();
  
  constructor(private config: RateLimitConfig) {}
  
  // Check if request is allowed
  isAllowed(key: string): { allowed: boolean; remaining: number; resetTime: number } {
    const now = Date.now();
    const entry = this.store.get(key);
    
    if (!entry) {
      // First request from this key
      const newEntry: RateLimitEntry = {
        count: 1,
        resetTime: now + this.config.windowMs,
        lastRequest: now
      };
      
      this.store.set(key, newEntry);
      
      return {
        allowed: true,
        remaining: this.config.maxRequests - 1,
        resetTime: newEntry.resetTime
      };
    }
    
    // Check if window has expired
    if (now > entry.resetTime) {
      entry.count = 1;
      entry.resetTime = now + this.config.windowMs;
      entry.lastRequest = now;
      
      return {
        allowed: true,
        remaining: this.config.maxRequests - 1,
        resetTime: entry.resetTime
      };
    }
    
    // Check if limit exceeded
    if (entry.count >= this.config.maxRequests) {
      return {
        allowed: false,
        remaining: 0,
        resetTime: entry.resetTime
      };
    }
    
    // Increment count
    entry.count++;
    entry.lastRequest = now;
    
    return {
      allowed: true,
      remaining: this.config.maxRequests - entry.count,
      resetTime: entry.resetTime
    };
  }
  
  // Clean up expired entries
  cleanup(): void {
    const now = Date.now();
    
    for (const [key, entry] of this.store.entries()) {
      if (now > entry.resetTime) {
        this.store.delete(key);
      }
    }
  }
}

// Express.js middleware for rate limiting
const createRateLimitMiddleware = (config: RateLimitConfig) => {
  const limiter = new RateLimiter(config);
  
  // Clean up expired entries every minute
  setInterval(() => limiter.cleanup(), 60000);
  
  return (req: Request, res: Response, next: NextFunction) => {
    // Get client identifier (IP, user ID, API key, etc.)
    const key = getClientKey(req);
    
    const result = limiter.isAllowed(key);
    
    // Set rate limit headers
    res.set({
      'X-RateLimit-Limit': config.maxRequests.toString(),
      'X-RateLimit-Remaining': result.remaining.toString(),
      'X-RateLimit-Reset': new Date(result.resetTime).toISOString()
    });
    
    if (!result.allowed) {
      const retryAfter = Math.ceil((result.resetTime - Date.now()) / 1000);
      res.set('Retry-After', retryAfter.toString());
      
      return res.status(429).json({
        error: 'Too Many Requests',
        message: config.message || 'Rate limit exceeded',
        retryAfter
      });
    }
    
    next();
  };
};

// Different rate limiting strategies
const getClientKey = (req: Request): string => {
  // Priority: API Key > User ID > IP Address
  if (req.headers['x-api-key']) {
    return `api-key:${req.headers['x-api-key']}`;
  }
  
  if (req.user?.id) {
    return `user:${req.user.id}`;
  }
  
  return `ip:${req.ip}`;
};

// Sliding Window Rate Limiter
class SlidingWindowRateLimiter {
  private store: Map<string, number[]> = new Map();
  
  constructor(private config: RateLimitConfig) {}
  
  isAllowed(key: string): { allowed: boolean; remaining: number } {
    const now = Date.now();
    const windowStart = now - this.config.windowMs;
    
    let requests = this.store.get(key) || [];
    
    // Remove expired requests
    requests = requests.filter(timestamp => timestamp > windowStart);
    
    // Check if limit exceeded
    if (requests.length >= this.config.maxRequests) {
      return {
        allowed: false,
        remaining: 0
      };
    }
    
    // Add current request
    requests.push(now);
    this.store.set(key, requests);
    
    return {
      allowed: true,
      remaining: this.config.maxRequests - requests.length
    };
  }
}

// Token Bucket Rate Limiter
class TokenBucketRateLimiter {
  private store: Map<string, { tokens: number; lastRefill: number }> = new Map();
  
  constructor(
    private config: RateLimitConfig,
    private refillRate: number = config.maxRequests / (config.windowMs / 1000)
  ) {}
  
  isAllowed(key: string): { allowed: boolean; remaining: number } {
    const now = Date.now();
    let bucket = this.store.get(key);
    
    if (!bucket) {
      bucket = { tokens: this.config.maxRequests, lastRefill: now };
      this.store.set(key, bucket);
    }
    
    // Refill tokens based on time elapsed
    const timeElapsed = (now - bucket.lastRefill) / 1000;
    const tokensToAdd = Math.floor(timeElapsed * this.refillRate);
    
    bucket.tokens = Math.min(
      this.config.maxRequests,
      bucket.tokens + tokensToAdd
    );
    bucket.lastRefill = now;
    
    // Check if token available
    if (bucket.tokens < 1) {
      return {
        allowed: false,
        remaining: 0
      };
    }
    
    // Consume token
    bucket.tokens--;
    
    return {
      allowed: true,
      remaining: Math.floor(bucket.tokens)
    };
  }
}

// Usage examples
const apiRateLimit = createRateLimitMiddleware({
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: 100,
  message: 'Too many requests from this IP'
});

const authRateLimit = createRateLimitMiddleware({
  windowMs: 15 * 60 * 1000, // 15 minutes
  maxRequests: 5,
  message: 'Too many authentication attempts'
});

const uploadRateLimit = createRateLimitMiddleware({
  windowMs: 60 * 60 * 1000, // 1 hour
  maxRequests: 10,
  message: 'Upload limit exceeded'
});

// Apply to routes
app.use('/api/', apiRateLimit);
app.post('/api/auth/login', authRateLimit, authController.login);
app.post('/api/upload', uploadRateLimit, uploadController.upload);
```

- **Pros**: DDoS protection, resource management, fair usage
- **Cons**: User experience impact, complexity in distributed systems

### Pattern 5: Input Validation and Sanitization

- **When to use**: All user inputs, API endpoints, file uploads
- **Implementation**: Whitelisting, validation libraries, sanitization
- **Code Example**:
```typescript
// Input Validation Service
import Joi from 'joi';
import DOMPurify from 'isomorphic-dompurify';
import validator from 'validator';

interface ValidationRule {
  schema: Joi.Schema;
  sanitize?: boolean;
}

class ValidationService {
  private validationRules: Map<string, ValidationRule> = new Map();
  
  constructor() {
    this.initializeValidationRules();
  }
  
  private initializeValidationRules() {
    // User registration validation
    this.validationRules.set('userRegistration', {
      schema: Joi.object({
        email: Joi.string().email().required(),
        password: Joi.string()
          .min(8)
          .pattern(new RegExp('^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]'))
          .required()
          .messages({
            'string.pattern.base': 'Password must contain at least one uppercase letter, one lowercase letter, one number, and one special character'
          }),
        firstName: Joi.string().min(2).max(50).required(),
        lastName: Joi.string().min(2).max(50).required(),
        phone: Joi.string().pattern(/^\+?[\d\s\-\(\)]+$/).optional(),
        dateOfBirth: Joi.date().max('now').optional(),
        acceptTerms: Joi.boolean().valid(true).required()
      }),
      sanitize: true
    });
    
    // Product creation validation
    this.validationRules.set('productCreation', {
      schema: Joi.object({
        name: Joi.string().min(3).max(200).required(),
        description: Joi.string().min(10).max(2000).required(),
        price: Joi.number().positive().precision(2).required(),
        category: Joi.string().valid('electronics', 'clothing', 'books', 'home').required(),
        sku: Joi.string().alphanum().min(6).max(20).required(),
        inStock: Joi.boolean().default(true),
        images: Joi.array().items(
          Joi.string().uri()
        ).max(10).optional(),
        tags: Joi.array().items(
          Joi.string().min(2).max(30)
        ).max(20).optional()
      }),
      sanitize: true
    });
    
    // Search query validation
    this.validationRules.set('searchQuery', {
      schema: Joi.object({
        query: Joi.string().min(1).max(100).required(),
        category: Joi.string().optional(),
        minPrice: Joi.number().min(0).optional(),
        maxPrice: Joi.number().positive().optional(),
        sortBy: Joi.string().valid('name', 'price', 'rating', 'date').default('name'),
        sortOrder: Joi.string().valid('asc', 'desc').default('asc'),
        page: Joi.number().integer().min(1).default(1),
        limit: Joi.number().integer().min(1).max(100).default(20)
      }),
      sanitize: false
    });
  }
  
  // Validate input against schema
  validate(ruleName: string, data: any): { isValid: boolean; errors?: string[]; sanitizedData?: any } {
    const rule = this.validationRules.get(ruleName);
    
    if (!rule) {
      throw new Error(`Validation rule '${ruleName}' not found`);
    }
    
    // Sanitize data if required
    let dataToValidate = data;
    if (rule.sanitize) {
      dataToValidate = this.sanitizeData(data);
    }
    
    const { error, value } = rule.schema.validate(dataToValidate, {
      abortEarly: false,
      stripUnknown: true
    });
    
    if (error) {
      return {
        isValid: false,
        errors: error.details.map(detail => detail.message)
      };
    }
    
    return {
      isValid: true,
      sanitizedData: value
    };
  }
  
  // Sanitize data to prevent XSS
  private sanitizeData(data: any): any {
    if (typeof data === 'string') {
      return DOMPurify.sanitize(data);
    }
    
    if (Array.isArray(data)) {
      return data.map(item => this.sanitizeData(item));
    }
    
    if (typeof data === 'object' && data !== null) {
      const sanitized: any = {};
      for (const [key, value] of Object.entries(data)) {
        sanitized[key] = this.sanitizeData(value);
      }
      return sanitized;
    }
    
    return data;
  }
  
  // Validate and sanitize file uploads
  validateFile(file: Express.Multer.File, allowedTypes: string[], maxSize: number): { isValid: boolean; error?: string } {
    // Check file size
    if (file.size > maxSize) {
      return {
        isValid: false,
        error: `File size exceeds maximum allowed size of ${maxSize} bytes`
      };
    }
    
    // Check file type
    const fileExtension = file.originalname.split('.').pop()?.toLowerCase();
    if (!fileExtension || !allowedTypes.includes(fileExtension)) {
      return {
        isValid: false,
        error: `File type not allowed. Allowed types: ${allowedTypes.join(', ')}`
      };
    }
    
    // Check MIME type
    if (!allowedTypes.some(type => file.mimetype.includes(type))) {
      return {
        isValid: false,
        error: `MIME type not allowed: ${file.mimetype}`
      };
    }
    
    return { isValid: true };
  }
}

// SQL Injection Prevention
class SQLInjectionProtection {
  // Parameterized query helper
  static createParameterizedQuery(query: string, params: any[]): { text: string; values: any[] } {
    // Replace ? placeholders with $1, $2, etc. for PostgreSQL
    let paramIndex = 1;
    const text = query.replace(/\?/g, () => `$${paramIndex++}`);
    
    return { text, values: params };
  }
  
  // Validate table and column names
  static validateIdentifier(identifier: string): boolean {
    // Only allow alphanumeric characters, underscores, and dots
    return /^[a-zA-Z0-9_.]+$/.test(identifier);
  }
  
  // Escape LIKE patterns
  static escapeLikePattern(pattern: string): string {
    return pattern
      .replace(/%/g, '\\%')
      .replace(/_/g, '\\_')
      .replace(/\\/g, '\\\\');
  }
}

// Express.js middleware for validation
const createValidationMiddleware = (ruleName: string, source: 'body' | 'query' | 'params' = 'body') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const data = req[source];
    const validation = validationService.validate(ruleName, data);
    
    if (!validation.isValid) {
      return res.status(400).json({
        error: 'Validation failed',
        details: validation.errors
      });
    }
    
    // Replace with sanitized data
    req[source] = validation.sanitizedData;
    next();
  };
};

// Usage examples
app.post('/api/users/register', 
  createValidationMiddleware('userRegistration'),
  authController.register
);

app.post('/api/products',
  authenticate,
  requirePermission('product', 'write'),
  createValidationMiddleware('productCreation'),
  productController.create
);

app.get('/api/search',
  createValidationMiddleware('searchQuery', 'query'),
  searchController.search
);

// File upload validation
app.post('/api/upload',
  authenticate,
  (req: Request, res: Response, next: NextFunction) => {
    const file = req.file;
    if (!file) {
      return res.status(400).json({ error: 'No file uploaded' });
    }
    
    const validation = validationService.validateFile(
      file, 
      ['jpg', 'jpeg', 'png', 'gif', 'pdf'],
      5 * 1024 * 1024 // 5MB
    );
    
    if (!validation.isValid) {
      return res.status(400).json({ error: validation.error });
    }
    
    next();
  },
  uploadController.processFile
);

// XSS Prevention in templates
const escapeHtml = (unsafe: string): string => {
  return unsafe
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
};

// Content Security Policy Header Generator
class CSPGenerator {
  static generate(directives: Record<string, string[]>): string {
    const policy = Object.entries(directives)
      .map(([directive, sources]) => {
        return `${directive} ${sources.join(' ')}`;
      })
      .join('; ');
    
    return policy;
  }
  
  static strict(): string {
    return this.generate({
      'default-src': ["'self'"],
      'script-src': ["'self'", "'unsafe-inline'", 'https://trusted.cdn.com'],
      'style-src': ["'self'", "'unsafe-inline'", 'https://trusted.cdn.com'],
      'img-src': ["'self'", 'data:', 'https:'],
      'font-src': ["'self'", 'https://trusted.cdn.com'],
      'connect-src': ["'self'", 'https://api.example.com'],
      'frame-ancestors': ["'none'"],
      'base-uri': ["'self'"],
      'form-action': ["'self'"]
    });
  }
}
```

- **Pros**: Injection prevention, data integrity, compliance
- **Cons**: Development overhead, false positives risk

## Security Monitoring & Incident Response

### Pattern 6: Security Event Logging and Monitoring

- **When to use**: All production systems, compliance requirements
- **Implementation**: Structured logging, SIEM integration, alerting
- **Code Example**:
```typescript
// Security Event Logger
interface SecurityEvent {
  timestamp: Date;
  eventType: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  userId?: string;
  ipAddress: string;
  userAgent?: string;
  resource?: string;
  action?: string;
  result: 'success' | 'failure' | 'blocked';
  details: Record<string, any>;
}

class SecurityLogger {
  private events: SecurityEvent[] = [];
  
  constructor(private alertService: AlertService) {}
  
  // Log security event
  logEvent(event: Omit<SecurityEvent, 'timestamp'>): void {
    const securityEvent: SecurityEvent = {
      timestamp: new Date(),
      ...event
    };
    
    this.events.push(securityEvent);
    
    // Check for alert conditions
    this.checkAlertConditions(securityEvent);
    
    // Send to external logging system
    this.sendToLogAggregator(securityEvent);
  }
  
  // Log authentication events
  logAuthEvent(
    eventType: 'login' | 'logout' | 'login_failed' | 'mfa_failed',
    userId?: string,
    ipAddress: string,
    userAgent?: string,
    result: 'success' | 'failure',
    details?: Record<string, any>
  ): void {
    this.logEvent({
      eventType: `auth.${eventType}`,
      severity: eventType.includes('failed') ? 'medium' : 'low',
      userId,
      ipAddress,
      userAgent,
      result,
      details: details || {}
    });
  }
  
  // Log authorization events
  logAuthzEvent(
    eventType: 'access_denied' | 'access_granted' | 'privilege_escalation',
    userId: string,
    resource: string,
    action: string,
    ipAddress: string,
    result: 'success' | 'failure',
    details?: Record<string, any>
  ): void {
    this.logEvent({
      eventType: `authz.${eventType}`,
      severity: eventType === 'access_denied' ? 'medium' : 'low',
      userId,
      resource,
      action,
      ipAddress,
      result,
      details: details || {}
    });
  }
  
  // Log data access events
  logDataAccess(
    eventType: 'data_read' | 'data_write' | 'data_delete' | 'data_export',
    userId: string,
    resource: string,
    recordCount?: number,
    ipAddress: string,
    result: 'success' | 'failure',
    details?: Record<string, any>
  ): void {
    this.logEvent({
      eventType: `data.${eventType}`,
      severity: 'low',
      userId,
      resource,
      action: eventType,
      ipAddress,
      result,
      details: {
        recordCount,
        ...details
      }
    });
  }
  
  // Log security violations
  logSecurityViolation(
    violationType: 'injection_attempt' | 'xss_attempt' | 'csrf_attempt' | 'rate_limit_exceeded',
    ipAddress: string,
    userAgent?: string,
    details?: Record<string, any>
  ): void {
    this.logEvent({
      eventType: `violation.${violationType}`,
      severity: 'high',
      ipAddress,
      userAgent,
      result: 'blocked',
      details: details || {}
    });
  }
  
  private checkAlertConditions(event: SecurityEvent): void {
    // Multiple failed logins from same IP
    const recentFailedLogins = this.events.filter(e =>
      e.eventType === 'auth.login_failed' &&
      e.ipAddress === event.ipAddress &&
      e.timestamp > new Date(Date.now() - 15 * 60 * 1000) // Last 15 minutes
    );
    
    if (recentFailedLogins.length >= 5) {
      this.alertService.sendAlert({
        type: 'brute_force_attack',
        severity: 'high',
        message: `Multiple failed login attempts from ${event.ipAddress}`,
        details: { attempts: recentFailedLogins.length, ipAddress: event.ipAddress }
      });
    }
    
    // Privilege escalation attempts
    if (event.eventType === 'authz.privilege_escalation') {
      this.alertService.sendAlert({
        type: 'privilege_escalation',
        severity: 'critical',
        message: `Privilege escalation attempt by user ${event.userId}`,
        details: { userId: event.userId, resource: event.resource, action: event.action }
      });
    }
    
    // High rate of security violations
    const recentViolations = this.events.filter(e =>
      e.eventType.startsWith('violation.') &&
      e.ipAddress === event.ipAddress &&
      e.timestamp > new Date(Date.now() - 5 * 60 * 1000) // Last 5 minutes
    );
    
    if (recentViolations.length >= 10) {
      this.alertService.sendAlert({
        type: 'attack_pattern',
        severity: 'high',
        message: `Attack pattern detected from ${event.ipAddress}`,
        details: { violations: recentViolations.length, ipAddress: event.ipAddress }
      });
    }
  }
  
  private sendToLogAggregator(event: SecurityEvent): void {
    // Send to SIEM, log management system, etc.
    console.log('Security Event:', JSON.stringify(event, null, 2));
  }
}

// Alert Service
interface Alert {
  type: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  message: string;
  details: Record<string, any>;
}

class AlertService {
  async sendAlert(alert: Alert): Promise<void> {
    // Send to different channels based on severity
    switch (alert.severity) {
      case 'critical':
        await this.sendEmail(alert);
        await this.sendSlack(alert);
        await this.sendSMS(alert);
        break;
      case 'high':
        await this.sendEmail(alert);
        await this.sendSlack(alert);
        break;
      case 'medium':
        await this.sendSlack(alert);
        break;
      case 'low':
        await this.logAlert(alert);
        break;
    }
  }
  
  private async sendEmail(alert: Alert): Promise<void> {
    // Email implementation
    console.log(`EMAIL ALERT: ${alert.message}`);
  }
  
  private async sendSlack(alert: Alert): Promise<void> {
    // Slack implementation
    console.log(`SLACK ALERT: ${alert.message}`);
  }
  
  private async sendSMS(alert: Alert): Promise<void> {
    // SMS implementation
    console.log(`SMS ALERT: ${alert.message}`);
  }
  
  private async logAlert(alert: Alert): Promise<void> {
    // Log implementation
    console.log(`LOG ALERT: ${alert.message}`);
  }
}

// Express.js middleware for security logging
const securityLogger = new SecurityLogger(new AlertService());

const logSecurityEvent = (eventType: string, severity: 'low' | 'medium' | 'high' | 'critical') => {
  return (req: Request, res: Response, next: NextFunction) => {
    const originalSend = res.send;
    
    res.send = function(body) {
      // Log the security event
      securityLogger.logEvent({
        eventType,
        severity,
        userId: req.user?.id,
        ipAddress: req.ip,
        userAgent: req.get('User-Agent'),
        resource: req.path,
        action: req.method,
        result: res.statusCode < 400 ? 'success' : 'failure',
        details: {
          statusCode: res.statusCode,
          requestBody: req.body,
          queryParams: req.query
        }
      });
      
      return originalSend.call(this, body);
    };
    
    next();
  };
};

// Usage examples
app.post('/api/auth/login', 
  logSecurityEvent('auth.login_attempt', 'low'),
  authController.login
);

app.use('/api/admin/*',
  logSecurityEvent('admin_access', 'medium'),
  requirePermission('admin', 'access')
);

// Intrusion Detection System
class IntrusionDetectionSystem {
  private suspiciousPatterns = [
    /\b(SELECT|INSERT|UPDATE|DELETE|DROP|CREATE|ALTER)\b/i, // SQL injection patterns
    /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi, // XSS patterns
    /\.\./, // Directory traversal
    /union.*select/i, // SQL union injection
    /javascript:/i, // JavaScript protocol
    /<iframe\b/i, // iframe injection
  ];
  
  detectSuspiciousActivity(input: string): { detected: boolean; patterns: string[] } {
    const detectedPatterns: string[] = [];
    
    for (const pattern of this.suspiciousPatterns) {
      if (pattern.test(input)) {
        detectedPatterns.push(pattern.source);
      }
    }
    
    return {
      detected: detectedPatterns.length > 0,
      patterns: detectedPatterns
    };
  }
  
  analyzeRequest(req: Request): { isSuspicious: boolean; reasons: string[] } {
    const reasons: string[] = [];
    
    // Analyze query parameters
    for (const [key, value] of Object.entries(req.query)) {
      if (typeof value === 'string') {
        const detection = this.detectSuspiciousActivity(value);
        if (detection.detected) {
          reasons.push(`Suspicious pattern in query parameter '${key}': ${detection.patterns.join(', ')}`);
        }
      }
    }
    
    // Analyze request body
    if (req.body && typeof req.body === 'object') {
      for (const [key, value] of Object.entries(req.body)) {
        if (typeof value === 'string') {
          const detection = this.detectSuspiciousActivity(value);
          if (detection.detected) {
            reasons.push(`Suspicious pattern in body field '${key}': ${detection.patterns.join(', ')}`);
          }
        }
      }
    }
    
    // Analyze headers
    const userAgent = req.get('User-Agent');
    if (userAgent) {
      const detection = this.detectSuspiciousActivity(userAgent);
      if (detection.detected) {
        reasons.push(`Suspicious pattern in User-Agent: ${detection.patterns.join(', ')}`);
      }
    }
    
    return {
      isSuspicious: reasons.length > 0,
      reasons
    };
  }
}

// IDS middleware
const ids = new IntrusionDetectionSystem();

const intrusionDetection = (req: Request, res: Response, next: NextFunction) => {
  const analysis = ids.analyzeRequest(req);
  
  if (analysis.isSuspicious) {
    securityLogger.logSecurityViolation(
      'suspicious_request',
      req.ip,
      req.get('User-Agent'),
      { reasons: analysis.reasons }
    );
    
    return res.status(400).json({
      error: 'Bad Request',
      message: 'Request contains suspicious content'
    });
  }
  
  next();
};

// Apply IDS middleware
app.use(intrusionDetection);
```

- **Pros**: Threat detection, incident response, compliance
- **Cons**: Alert fatigue, storage requirements, complexity

## Best Practices

### Security Principles
1. **Defense in Depth**: Multiple layers of security controls
2. **Least Privilege**: Minimum necessary access rights
3. **Fail Securely**: Default to secure state on failure
4. **Secure by Default**: Secure configurations out of the box
5. **Transparency**: Open about security practices

### Development Security
1. **Secure Coding**: Follow secure coding standards
2. **Input Validation**: Validate and sanitize all inputs
3. **Output Encoding**: Encode outputs to prevent injection
4. **Error Handling**: Don't expose sensitive information
5. **Regular Updates**: Keep dependencies updated

### Operational Security
1. **Access Control**: Strong authentication and authorization
2. **Monitoring**: Comprehensive logging and monitoring
3. **Backup Security**: Encrypt and secure backups
4. **Incident Response**: Have a response plan
5. **Regular Audits**: Periodic security assessments

## Common Pitfalls

### Implementation Pitfalls
- **Rolling Your Own Crypto**: Use standard libraries
- **Hardcoded Secrets**: Store secrets securely
- **Insufficient Validation**: Trusting user input
- **Overly Permissive**: Too many permissions

### Operational Pitfalls
- **Ignoring Logs**: Not monitoring security events
- **Delayed Updates**: Not patching vulnerabilities
- **Poor Key Management**: Insecure key storage
- **Insufficient Testing**: Not testing security controls

## Tools & Resources

### Security Testing
- **OWASP ZAP**: Web application security scanner
- **Burp Suite**: Web vulnerability scanner
- **Nessus**: Vulnerability scanner
- **Metasploit**: Penetration testing framework

### Application Security
- **Snyk**: Dependency vulnerability scanner
- **SonarQube**: Code quality and security
- **Checkmarx**: Static application security testing
- **Veracode**: Dynamic application security testing

### Infrastructure Security
- **HashiCorp Vault**: Secrets management
- **Aqua Security**: Container security
- **Twistlock**: Container vulnerability scanning
- **Falco**: Runtime security monitoring

This playbook provides comprehensive security patterns and should be adapted to specific application requirements and threat models.
