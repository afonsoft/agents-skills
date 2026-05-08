# Testing Strategies

This document contains comprehensive testing patterns, best practices, and implementation guides for different testing types and strategies.

## Overview

Comprehensive guide for building robust testing strategies including unit tests, integration tests, end-to-end tests, performance testing, and security testing.

## Quick Reference

| Test Type | Purpose | Tools | Coverage Target |
|-----------|---------|-------|-----------------|
| **Unit Tests** | Function/component isolation | Jest, Vitest, pytest | 80-90% |
| **Integration Tests** | Component interaction | Supertest, TestContainers | 60-70% |
| **E2E Tests** | User workflows | Cypress, Playwright | Critical paths |
| **Performance Tests** | Load, stress, scalability | Artillery, k6 | Key scenarios |
| **Security Tests** | Vulnerability detection | OWASP ZAP, Snyk | 100% |

## Unit Testing Patterns

### Pattern 1: Test-Driven Development (TDD)

- **When to use**: New features, complex logic, refactoring
- **Implementation**: Red-Green-Refactor cycle
- **Code Example**:
```typescript
// TDD Example: User Service
// 1. RED - Write failing test
describe('UserService', () => {
  let userService: UserService;
  let mockUserRepository: jest.Mocked<UserRepository>;
  let mockEmailService: jest.Mocked<EmailService>;
  
  beforeEach(() => {
    mockUserRepository = createMockUserRepository();
    mockEmailService = createMockEmailService();
    userService = new UserService(mockUserRepository, mockEmailService);
  });
  
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const userData = {
        email: 'test@example.com',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe'
      };
      
      const expectedUser = {
        id: '123',
        email: userData.email,
        firstName: userData.firstName,
        lastName: userData.lastName,
        isActive: true,
        createdAt: new Date()
      };
      
      mockUserRepository.findByEmail.mockResolvedValue(null);
      mockUserRepository.create.mockResolvedValue(expectedUser);
      mockEmailService.sendWelcomeEmail.mockResolvedValue(true);
      
      // Act
      const result = await userService.createUser(userData);
      
      // Assert
      expect(result).toEqual(expectedUser);
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockUserRepository.create).toHaveBeenCalledWith({
        email: userData.email,
        passwordHash: expect.any(String), // Hashed password
        firstName: userData.firstName,
        lastName: userData.lastName,
        isActive: true
      });
      expect(mockEmailService.sendWelcomeEmail).toHaveBeenCalledWith(
        userData.email,
        userData.firstName
      );
    });
    
    it('should throw error if email already exists', async () => {
      // Arrange
      const userData = {
        email: 'existing@example.com',
        password: 'SecurePass123!',
        firstName: 'Jane',
        lastName: 'Smith'
      };
      
      const existingUser = {
        id: '456',
        email: userData.email,
        firstName: 'Existing',
        lastName: 'User'
      };
      
      mockUserRepository.findByEmail.mockResolvedValue(existingUser as any);
      
      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Email already exists');
      
      expect(mockUserRepository.findByEmail).toHaveBeenCalledWith(userData.email);
      expect(mockUserRepository.create).not.toHaveBeenCalled();
      expect(mockEmailService.sendWelcomeEmail).not.toHaveBeenCalled();
    });
    
    it('should throw error with invalid email format', async () => {
      // Arrange
      const userData = {
        email: 'invalid-email',
        password: 'SecurePass123!',
        firstName: 'John',
        lastName: 'Doe'
      };
      
      // Act & Assert
      await expect(userService.createUser(userData))
        .rejects
        .toThrow('Invalid email format');
      
      expect(mockUserRepository.findByEmail).not.toHaveBeenCalled();
      expect(mockUserRepository.create).not.toHaveBeenCalled();
    });
  });
});

// Helper function to create mocks
function createMockUserRepository(): jest.Mocked<UserRepository> {
  return {
    findByEmail: jest.fn(),
    create: jest.fn(),
    findById: jest.fn(),
    update: jest.fn(),
    delete: jest.fn()
  } as any;
}

function createMockEmailService(): jest.Mocked<EmailService> {
  return {
    sendWelcomeEmail: jest.fn(),
    sendPasswordReset: jest.fn(),
    sendNotification: jest.fn()
  } as any;
}

// 2. GREEN - Implement minimal code to pass tests
export class UserService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService
  ) {}
  
  async createUser(userData: CreateUserDto): Promise<User> {
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userData.email)) {
      throw new Error('Invalid email format');
    }
    
    // Check if user already exists
    const existingUser = await this.userRepository.findByEmail(userData.email);
    if (existingUser) {
      throw new Error('Email already exists');
    }
    
    // Hash password
    const passwordHash = await this.hashPassword(userData.password);
    
    // Create user
    const user = await this.userRepository.create({
      email: userData.email,
      passwordHash,
      firstName: userData.firstName,
      lastName: userData.lastName,
      isActive: true
    });
    
    // Send welcome email
    await this.emailService.sendWelcomeEmail(
      user.email,
      user.firstName
    );
    
    return user;
  }
  
  private async hashPassword(password: string): Promise<string> {
    // Simplified hashing - use bcrypt in production
    return `hashed_${password}`;
  }
}

// 3. REFACTOR - Improve code while keeping tests green
export class UserService {
  constructor(
    private userRepository: UserRepository,
    private emailService: EmailService,
    private passwordHasher: PasswordHasher
  ) {}
  
  async createUser(userData: CreateUserDto): Promise<User> {
    this.validateUserData(userData);
    
    await this.ensureEmailIsUnique(userData.email);
    
    const passwordHash = await this.passwordHasher.hash(userData.password);
    
    const user = await this.userRepository.create({
      email: userData.email,
      passwordHash,
      firstName: userData.firstName,
      lastName: userData.lastName,
      isActive: true
    });
    
    await this.sendWelcomeEmail(user);
    
    return user;
  }
  
  private validateUserData(userData: CreateUserDto): void {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(userData.email)) {
      throw new ValidationError('Invalid email format');
    }
    
    if (userData.password.length < 8) {
      throw new ValidationError('Password must be at least 8 characters');
    }
  }
  
  private async ensureEmailIsUnique(email: string): Promise<void> {
    const existingUser = await this.userRepository.findByEmail(email);
    if (existingUser) {
      throw new ConflictError('Email already exists');
    }
  }
  
  private async sendWelcomeEmail(user: User): Promise<void> {
    try {
      await this.emailService.sendWelcomeEmail(user.email, user.firstName);
    } catch (error) {
      // Log error but don't fail user creation
      console.error('Failed to send welcome email:', error);
    }
  }
}
```

- **Pros**: High code quality, comprehensive coverage, design improvement
- **Cons**: Slower development, learning curve

### Pattern 2: Behavior-Driven Development (BDD)

- **When to use**: Complex business rules, stakeholder collaboration
- **Implementation**: Gherkin syntax, step definitions
- **Code Example**:
```gherkin
# user_management.feature
Feature: User Management
  As a system administrator
  I want to manage user accounts
  So that I can control access to the system

  Background:
    Given the system is initialized
    And I am logged in as an administrator

  Scenario: Create new user account
    Given I navigate to the user management page
    When I fill in the user creation form with valid data:
      | Field      | Value              |
      | Email      | john.doe@test.com |
      | First Name | John               |
      | Last Name  | Doe               |
      | Role       | User               |
    And I click the "Create User" button
    Then I should see a success message "User created successfully"
    And the user should be created in the system
    And a welcome email should be sent to the user

  Scenario: Attempt to create user with existing email
    Given a user with email "jane.doe@test.com" already exists
    When I try to create a new user with email "jane.doe@test.com"
    Then I should see an error message "Email already exists"
    And no new user should be created

  Scenario: User account activation
    Given a user account exists with email "inactive@test.com"
    And the user account is inactive
    When I activate the user account
    Then the user account should be active
    And the user should receive an activation notification email

  Scenario Outline: Validate user input fields
    Given I am creating a new user
    When I enter "<field>" with "<value>"
    Then I should see "<expected_message>"
    
    Examples:
      | Field      | Value               | Expected Message                |
      | Email      | invalid-email       | Invalid email format            |
      | First Name |                    | First name is required         |
      | Last Name  |                    | Last name is required          |
      | Password   | 123                | Password must be at least 8 characters |
```

```typescript
// Step definitions for BDD
import { Given, When, Then } from '@cucumber/cucumber';
import { expect } from 'chai';
import { UserService } from '../src/services/UserService';
import { EmailService } from '../src/services/EmailService';
import { UserRepository } from '../src/repositories/UserRepository';

// Test context setup
let userService: UserService;
let mockUserRepository: UserRepository;
let mockEmailService: EmailService;
let lastError: Error | null = null;
let lastResult: any = null;

Given('the system is initialized', function () {
  mockUserRepository = new MockUserRepository();
  mockEmailService = new MockEmailService();
  userService = new UserService(mockUserRepository, mockEmailService);
  lastError = null;
  lastResult = null;
});

Given('I am logged in as an administrator', function () {
  // Setup admin authentication context
  // This would typically involve setting up authentication tokens
});

Given('a user with email {string} already exists', async function (email: string) {
  await userService.createUser({
    email,
    password: 'SecurePass123!',
    firstName: 'Existing',
    lastName: 'User'
  });
});

Given('a user account exists with email {string}', async function (email: string) {
  await userService.createUser({
    email,
    password: 'SecurePass123!',
    firstName: 'Test',
    lastName: 'User'
  });
});

Given('the user account is inactive', async function () {
  // Find the user and set to inactive
  const user = await mockUserRepository.findByEmail('inactive@test.com');
  if (user) {
    user.isActive = false;
    await mockUserRepository.update(user.id, { isActive: false });
  }
});

When('I fill in the user creation form with valid data', async function (dataTable) {
  const userData = dataTable.rowsHash();
  
  try {
    lastResult = await userService.createUser({
      email: userData.Email,
      password: 'SecurePass123!',
      firstName: userData['First Name'],
      lastName: userData['Last Name']
    });
  } catch (error) {
    lastError = error as Error;
  }
});

When('I try to create a new user with email {string}', async function (email: string) {
  try {
    lastResult = await userService.createUser({
      email,
      password: 'SecurePass123!',
      firstName: 'New',
      lastName: 'User'
    });
  } catch (error) {
    lastError = error as Error;
  }
});

When('I activate the user account', async function () {
  try {
    const user = await mockUserRepository.findByEmail('inactive@test.com');
    if (user) {
      lastResult = await userService.activateUser(user.id);
    }
  } catch (error) {
    lastError = error as Error;
  }
});

When('I enter {string} with {string}', async function (field: string, value: string) {
  const userData: any = {
    email: 'test@example.com',
    password: 'SecurePass123!',
    firstName: 'Test',
    lastName: 'User'
  };
  
  userData[field] = value;
  
  try {
    lastResult = await userService.createUser(userData);
  } catch (error) {
    lastError = error as Error;
  }
});

Then('I should see a success message {string}', function (message: string) {
  expect(lastError).to.be.null;
  expect(lastResult).to.not.be.null;
  // In a real UI test, this would check the UI
  // For API tests, we check the response message
});

Then('the user should be created in the system', async function () {
  expect(lastError).to.be.null;
  expect(lastResult).to.have.property('id');
  expect(lastResult).to.have.property('email');
});

Then('a welcome email should be sent to the user', function () {
  expect(mockEmailService.sentEmails).to.have.length.greaterThan(0);
  const welcomeEmail = mockEmailService.sentEmails.find(
    email => email.type === 'welcome'
  );
  expect(welcomeEmail).to.not.be.undefined;
});

Then('I should see an error message {string}', function (message: string) {
  expect(lastError).to.not.be.null;
  expect(lastError.message).to.equal(message);
});

Then('no new user should be created', function () {
  expect(lastResult).to.be.null;
});

Then('the user account should be active', async function () {
  expect(lastError).to.be.null;
  expect(lastResult).to.have.property('isActive', true);
});

Then('the user should receive an activation notification email', function () {
  expect(mockEmailService.sentEmails).to.have.length.greaterThan(0);
  const activationEmail = mockEmailService.sentEmails.find(
    email => email.type === 'activation'
  );
  expect(activationEmail).to.not.be.undefined;
});

// Mock implementations
class MockUserRepository implements UserRepository {
  private users: User[] = [];
  
  async findByEmail(email: string): Promise<User | null> {
    return this.users.find(user => user.email === email) || null;
  }
  
  async create(userData: any): Promise<User> {
    const user: User = {
      id: Math.random().toString(36).substr(2, 9),
      ...userData,
      createdAt: new Date()
    };
    this.users.push(user);
    return user;
  }
  
  async findById(id: string): Promise<User | null> {
    return this.users.find(user => user.id === id) || null;
  }
  
  async update(id: string, data: Partial<User>): Promise<User> {
    const userIndex = this.users.findIndex(user => user.id === id);
    if (userIndex !== -1) {
      this.users[userIndex] = { ...this.users[userIndex], ...data };
      return this.users[userIndex];
    }
    throw new Error('User not found');
  }
  
  async delete(id: string): Promise<void> {
    this.users = this.users.filter(user => user.id !== id);
  }
}

class MockEmailService implements EmailService {
  sentEmails: any[] = [];
  
  async sendWelcomeEmail(email: string, firstName: string): Promise<boolean> {
    this.sentEmails.push({
      type: 'welcome',
      to: email,
      firstName,
      sentAt: new Date()
    });
    return true;
  }
  
  async sendActivationEmail(email: string): Promise<boolean> {
    this.sentEmails.push({
      type: 'activation',
      to: email,
      sentAt: new Date()
    });
    return true;
  }
  
  async sendPasswordReset(email: string): Promise<boolean> {
    this.sentEmails.push({
      type: 'password_reset',
      to: email,
      sentAt: new Date()
    });
    return true;
  }
}
```

- **Pros**: Clear requirements, stakeholder collaboration, living documentation
- **Cons**: Overhead, maintenance complexity

## Integration Testing Patterns

### Pattern 3: Database Integration Testing

- **When to use**: Data access layer, repository patterns
- **Implementation**: TestContainers, in-memory databases
- **Code Example**:
```typescript
// Database Integration Test with TestContainers
import { TestContainer, StartedTestContainer } from 'testcontainers';
import { PostgreSqlContainer } from 'testcontainers/modules/postgres';
import { UserService } from '../src/services/UserService';
import { UserRepository } from '../src/repositories/UserRepository';
import { DatabaseConnection } from '../src/database/DatabaseConnection';

describe('UserService Integration Tests', () => {
  let postgresContainer: StartedTestContainer;
  let databaseConnection: DatabaseConnection;
  let userRepository: UserRepository;
  let userService: UserService;
  
  beforeAll(async () => {
    // Start PostgreSQL container
    postgresContainer = await new PostgreSqlContainer('postgres:15')
      .withDatabase('testdb')
      .withUsername('test')
      .withPassword('test')
      .withExposedPorts(5432)
      .start();
    
    // Initialize database connection
    databaseConnection = new DatabaseConnection({
      host: postgresContainer.getHost(),
      port: postgresContainer.getMappedPort(5432),
      database: 'testdb',
      username: 'test',
      password: 'test'
    });
    
    await databaseConnection.initialize();
    await runMigrations(databaseConnection);
    
    // Initialize services
    userRepository = new UserRepository(databaseConnection);
    userService = new UserService(userRepository, new MockEmailService());
  });
  
  afterAll(async () => {
    await databaseConnection.close();
    await postgresContainer.stop();
  });
  
  beforeEach(async () => {
    // Clean database before each test
    await databaseConnection.query('TRUNCATE TABLE users RESTART IDENTITY CASCADE');
  });
  
  describe('createUser', () => {
    it('should persist user in database', async () => {
      // Arrange
      const userData = {
        email: 'integration@test.com',
        password: 'SecurePass123!',
        firstName: 'Integration',
        lastName: 'Test'
      };
      
      // Act
      const createdUser = await userService.createUser(userData);
      
      // Assert
      expect(createdUser).to.have.property('id');
      expect(createdUser.email).to.equal(userData.email);
      
      // Verify user exists in database
      const foundUser = await userRepository.findById(createdUser.id);
      expect(foundUser).to.not.be.null;
      expect(foundUser.email).to.equal(userData.email);
    });
    
    it('should handle concurrent user creation', async () => {
      // Arrange
      const userData = {
        email: 'concurrent@test.com',
        password: 'SecurePass123!',
        firstName: 'Concurrent',
        lastName: 'Test'
      };
      
      // Act - Create multiple users concurrently
      const promises = Array.from({ length: 10 }, (_, index) =>
        userService.createUser({
          ...userData,
          email: `${index}-${userData.email}`
        })
      );
      
      const results = await Promise.allSettled(promises);
      
      // Assert
      const successful = results.filter(r => r.status === 'fulfilled');
      const failed = results.filter(r => r.status === 'rejected');
      
      expect(successful).to.have.length(10);
      expect(failed).to.have.length(0);
      
      // Verify all users were created
      const allUsers = await userRepository.findAll();
      expect(allUsers).to.have.length(10);
    });
    
    it('should enforce unique email constraint', async () => {
      // Arrange
      const userData = {
        email: 'unique@test.com',
        password: 'SecurePass123!',
        firstName: 'Unique',
        lastName: 'Test'
      };
      
      // Act - Create first user
      await userService.createUser(userData);
      
      // Assert - Second creation should fail
      await expect(userService.createUser(userData))
        .to.be.rejectedWith('Email already exists');
      
      // Verify only one user exists
      const allUsers = await userRepository.findAll();
      expect(allUsers).to.have.length(1);
    });
  });
  
  describe('transaction handling', () => {
    it('should rollback on error', async () => {
      // Arrange
      const userData = {
        email: 'rollback@test.com',
        password: 'SecurePass123!',
        firstName: 'Rollback',
        lastName: 'Test'
      };
      
      // Mock email service to throw error
      const failingEmailService = {
        sendWelcomeEmail: jest.fn().mockRejectedValue(new Error('Email service failed'))
      };
      
      const userServiceWithFailingEmail = new UserService(
        userRepository,
        failingEmailService as any
      );
      
      // Act & Assert
      await expect(userServiceWithFailingEmail.createUser(userData))
        .to.be.rejectedWith('Email service failed');
      
      // Verify user was not created (transaction rolled back)
      const allUsers = await userRepository.findAll();
      expect(allUsers).to.have.length(0);
    });
  });
});

// Migration runner helper
async function runMigrations(db: DatabaseConnection): Promise<void> {
  const migrations = [
    'CREATE TABLE users (id SERIAL PRIMARY KEY, email VARCHAR(255) UNIQUE NOT NULL, password_hash VARCHAR(255) NOT NULL, first_name VARCHAR(100) NOT NULL, last_name VARCHAR(100) NOT NULL, is_active BOOLEAN DEFAULT TRUE, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP);'
  ];
  
  for (const migration of migrations) {
    await db.query(migration);
  }
}

// Repository integration tests
describe('UserRepository Integration Tests', () => {
  let postgresContainer: StartedTestContainer;
  let db: DatabaseConnection;
  let repository: UserRepository;
  
  beforeAll(async () => {
    postgresContainer = await new PostgreSqlContainer('postgres:15')
      .withDatabase('testdb')
      .withUsername('test')
      .withPassword('test')
      .start();
    
    db = new DatabaseConnection({
      host: postgresContainer.getHost(),
      port: postgresContainer.getMappedPort(5432),
      database: 'testdb',
      username: 'test',
      password: 'test'
    });
    
    await db.initialize();
    await runMigrations(db);
    
    repository = new UserRepository(db);
  });
  
  afterAll(async () => {
    await db.close();
    await postgresContainer.stop();
  });
  
  beforeEach(async () => {
    await db.query('TRUNCATE TABLE users RESTART IDENTITY CASCADE');
  });
  
  describe('CRUD operations', () => {
    it('should create and retrieve user', async () => {
      // Arrange
      const userData = {
        email: 'crud@test.com',
        passwordHash: 'hashed_password',
        firstName: 'CRUD',
        lastName: 'Test'
      };
      
      // Act
      const created = await repository.create(userData);
      const retrieved = await repository.findById(created.id);
      
      // Assert
      expect(retrieved).to.not.be.null;
      expect(retrieved.email).to.equal(userData.email);
      expect(retrieved.firstName).to.equal(userData.firstName);
      expect(retrieved.lastName).to.equal(userData.lastName);
    });
    
    it('should update user', async () => {
      // Arrange
      const userData = {
        email: 'update@test.com',
        passwordHash: 'hashed_password',
        firstName: 'Update',
        lastName: 'Test'
      };
      
      const created = await repository.create(userData);
      
      // Act
      const updateData = { firstName: 'Updated' };
      const updated = await repository.update(created.id, updateData);
      
      // Assert
      expect(updated.firstName).to.equal('Updated');
      
      const retrieved = await repository.findById(created.id);
      expect(retrieved.firstName).to.equal('Updated');
    });
    
    it('should delete user', async () => {
      // Arrange
      const userData = {
        email: 'delete@test.com',
        passwordHash: 'hashed_password',
        firstName: 'Delete',
        lastName: 'Test'
      };
      
      const created = await repository.create(userData);
      
      // Act
      await repository.delete(created.id);
      
      // Assert
      const retrieved = await repository.findById(created.id);
      expect(retrieved).to.be.null;
    });
  });
  
  describe('query operations', () => {
    beforeEach(async () => {
      // Seed test data
      const users = [
        { email: 'user1@test.com', passwordHash: 'hash1', firstName: 'User', lastName: 'One' },
        { email: 'user2@test.com', passwordHash: 'hash2', firstName: 'User', lastName: 'Two' },
        { email: 'user3@test.com', passwordHash: 'hash3', firstName: 'User', lastName: 'Three' }
      ];
      
      for (const user of users) {
        await repository.create(user);
      }
    });
    
    it('should find all users', async () => {
      const users = await repository.findAll();
      expect(users).to.have.length(3);
    });
    
    it('should find user by email', async () => {
      const user = await repository.findByEmail('user2@test.com');
      expect(user).to.not.be.null;
      expect(user.email).to.equal('user2@test.com');
      expect(user.lastName).to.equal('Two');
    });
    
    it('should return null for non-existent email', async () => {
      const user = await repository.findByEmail('nonexistent@test.com');
      expect(user).to.be.null;
    });
  });
});
```

- **Pros**: Real environment testing, confidence in integration
- **Cons**: Slower tests, setup complexity

## End-to-End Testing Patterns

### Pattern 4: User Journey Testing

- **When to use**: Critical user paths, regression testing
- **Implementation**: Playwright, Cypress, Selenium
- **Code Example**:
```typescript
// Playwright E2E Tests
import { test, expect } from '@playwright/test';

test.describe('User Registration Journey', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/register');
  });
  
  test('should complete user registration successfully', async ({ page }) => {
    // Step 1: Fill registration form
    await page.fill('[data-testid=email-input]', 'newuser@example.com');
    await page.fill('[data-testid=password-input]', 'SecurePass123!');
    await page.fill('[data-testid=confirm-password-input]', 'SecurePass123!');
    await page.fill('[data-testid=first-name-input]', 'John');
    await page.fill('[data-testid=last-name-input]', 'Doe');
    
    // Step 2: Accept terms and conditions
    await page.check('[data-testid=terms-checkbox]');
    
    // Step 3: Submit registration
    await page.click('[data-testid=register-button]');
    
    // Step 4: Verify success
    await expect(page.locator('[data-testid=success-message]')).toBeVisible();
    await expect(page.locator('[data-testid=success-message]')).toContainText('Registration successful');
    
    // Step 5: Verify redirect to dashboard
    await expect(page).toHaveURL('/dashboard');
    
    // Step 6: Verify user is logged in
    await expect(page.locator('[data-testid=user-menu]')).toBeVisible();
    await expect(page.locator('[data-testid=user-email]')).toContainText('newuser@example.com');
  });
  
  test('should show validation errors for invalid data', async ({ page }) => {
    // Submit empty form
    await page.click('[data-testid=register-button]');
    
    // Verify validation errors
    await expect(page.locator('[data-testid=email-error]')).toBeVisible();
    await expect(page.locator('[data-testid=password-error]')).toBeVisible();
    await expect(page.locator('[data-testid=first-name-error]')).toBeVisible();
    await expect(page.locator('[data-testid=last-name-error]')).toBeVisible();
    
    // Fill invalid email
    await page.fill('[data-testid=email-input]', 'invalid-email');
    await page.click('[data-testid=register-button]');
    
    await expect(page.locator('[data-testid=email-error]')).toContainText('Invalid email format');
    
    // Fill short password
    await page.fill('[data-testid=password-input]', '123');
    await page.click('[data-testid=register-button]');
    
    await expect(page.locator('[data-testid=password-error]')).toContainText('Password must be at least 8 characters');
  });
  
  test('should handle email already exists scenario', async ({ page }) => {
    // Try to register with existing email
    await page.fill('[data-testid=email-input]', 'existing@example.com');
    await page.fill('[data-testid=password-input]', 'SecurePass123!');
    await page.fill('[data-testid=confirm-password-input]', 'SecurePass123!');
    await page.fill('[data-testid=first-name-input]', 'Jane');
    await page.fill('[data-testid=last-name-input]', 'Smith');
    await page.check('[data-testid=terms-checkbox]');
    await page.click('[data-testid=register-button]');
    
    // Verify error message
    await expect(page.locator('[data-testid=error-message]')).toBeVisible();
    await expect(page.locator('[data-testid=error-message]')).toContainText('Email already exists');
    
    // Verify user stays on registration page
    await expect(page).toHaveURL('/register');
  });
});

test.describe('E-commerce Purchase Journey', () => {
  test.beforeEach(async ({ page }) => {
    // Login before each test
    await page.goto('/login');
    await page.fill('[data-testid=email-input]', 'customer@example.com');
    await page.fill('[data-testid=password-input]', 'password123');
    await page.click('[data-testid=login-button]');
    await expect(page).toHaveURL('/dashboard');
  });
  
  test('should complete purchase flow successfully', async ({ page }) => {
    // Step 1: Browse products
    await page.goto('/products');
    await expect(page.locator('[data-testid=product-list]')).toBeVisible();
    
    // Step 2: Add product to cart
    await page.click('[data-testid=product-card]:first-child [data-testid=add-to-cart]');
    await expect(page.locator('[data-testid=cart-badge]')).toContainText('1');
    
    // Step 3: View cart
    await page.click('[data-testid=cart-icon]');
    await expect(page).toHaveURL('/cart');
    await expect(page.locator('[data-testid=cart-item]')).toHaveCount(1);
    
    // Step 4: Proceed to checkout
    await page.click('[data-testid=checkout-button]');
    await expect(page).toHaveURL('/checkout');
    
    // Step 5: Fill shipping information
    await page.fill('[data-testid=shipping-first-name]', 'John');
    await page.fill('[data-testid=shipping-last-name]', 'Doe');
    await page.fill('[data-testid=shipping-address]', '123 Main St');
    await page.fill('[data-testid=shipping-city]', 'Anytown');
    await page.fill('[data-testid=shipping-zip]', '12345');
    
    // Step 6: Select shipping method
    await page.click('[data-testid=shipping-method-standard]');
    
    // Step 7: Fill payment information
    await page.fill('[data-testid=card-number]', '4242424242424242');
    await page.fill('[data-testid=card-expiry]', '12/25');
    await page.fill('[data-testid=card-cvc]', '123');
    await page.fill('[data-testid=card-name]', 'John Doe');
    
    // Step 8: Place order
    await page.click('[data-testid=place-order-button]');
    
    // Step 9: Verify order confirmation
    await expect(page).toHaveURL('/order-confirmation');
    await expect(page.locator('[data-testid=order-number]')).toBeVisible();
    await expect(page.locator('[data-testid=success-message]')).toContainText('Order placed successfully');
    
    // Step 10: Verify order in order history
    await page.goto('/orders');
    await expect(page.locator('[data-testid=order-list]')).toBeVisible();
    await expect(page.locator('[data-testid=order-item]')).toHaveCount(1);
  });
  
  test('should handle out of stock scenario', async ({ page }) => {
    // Navigate to out of stock product
    await page.goto('/products/out-of-stock-product');
    
    // Verify out of stock message
    await expect(page.locator('[data-testid=out-of-stock-message]')).toBeVisible();
    
    // Verify add to cart is disabled
    await expect(page.locator('[data-testid=add-to-cart]')).toBeDisabled();
    
    // Verify notify when available button
    await expect(page.locator('[data-testid=notify-button]')).toBeVisible();
    
    // Click notify button
    await page.click('[data-testid=notify-button]');
    
    // Verify notification setup
    await expect(page.locator('[data-testid=notification-confirmation]')).toBeVisible();
  });
});

test.describe('Responsive Design Testing', () => {
  const devices = [
    { name: 'Desktop', viewport: { width: 1200, height: 800 } },
    { name: 'Tablet', viewport: { width: 768, height: 1024 } },
    { name: 'Mobile', viewport: { width: 375, height: 667 } }
  ];
  
  devices.forEach(device => {
    test(`should display correctly on ${device.name}`, async ({ page }) => {
      await page.setViewportSize(device.viewport);
      await page.goto('/');
      
      // Verify navigation adapts to screen size
      if (device.name === 'Mobile') {
        await expect(page.locator('[data-testid=mobile-menu-button]')).toBeVisible();
        await expect(page.locator('[data-testid=desktop-nav]')).toBeHidden();
      } else {
        await expect(page.locator('[data-testid=desktop-nav]')).toBeVisible();
        await expect(page.locator('[data-testid=mobile-menu-button]')).toBeHidden();
      }
      
      // Verify content is accessible
      await expect(page.locator('[data-testid=hero-section]')).toBeVisible();
      await expect(page.locator('[data-testid=product-grid]')).toBeVisible();
      
      // Test mobile menu if on mobile
      if (device.name === 'Mobile') {
        await page.click('[data-testid=mobile-menu-button]');
        await expect(page.locator('[data-testid=mobile-menu]')).toBeVisible();
      }
    });
  });
});

test.describe('Accessibility Testing', () => {
  test('should be keyboard navigable', async ({ page }) => {
    await page.goto('/');
    
    // Test tab navigation
    await page.keyboard.press('Tab');
    await expect(page.locator(':focus')).toBeVisible();
    
    // Navigate through all focusable elements
    const focusableElements = page.locator('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
    const count = await focusableElements.count();
    
    for (let i = 0; i < count; i++) {
      await page.keyboard.press('Tab');
      const focusedElement = page.locator(':focus');
      await expect(focusedElement).toBeVisible();
    }
  });
  
  test('should have proper ARIA labels', async ({ page }) => {
    await page.goto('/');
    
    // Check for proper ARIA labels
    await expect(page.locator('[data-testid=search-input]')).toHaveAttribute('aria-label', 'Search products');
    await expect(page.locator('[data-testid=cart-button]')).toHaveAttribute('aria-label', 'Shopping cart');
    
    // Check for proper heading structure
    const headings = page.locator('h1, h2, h3, h4, h5, h6');
    const headingCount = await headings.count();
    expect(headingCount).toBeGreaterThan(0);
    
    // Verify h1 exists and is unique
    const h1Elements = page.locator('h1');
    await expect(h1Elements).toHaveCount(1);
  });
  
  test('should support screen readers', async ({ page }) => {
    await page.goto('/');
    
    // Check for alt text on images
    const images = page.locator('img');
    const imageCount = await images.count();
    
    for (let i = 0; i < imageCount; i++) {
      const image = images.nth(i);
      await expect(image).toHaveAttribute('alt');
    }
    
    // Check for proper semantic HTML
    await expect(page.locator('main')).toBeVisible();
    await expect(page.locator('nav')).toBeVisible();
    await expect(page.locator('footer')).toBeVisible();
  });
});

// Performance testing with Playwright
test.describe('Performance Testing', () => {
  test('should load within performance budget', async ({ page }) => {
    const startTime = Date.now();
    
    await page.goto('/');
    
    // Wait for page to be fully loaded
    await page.waitForLoadState('networkidle');
    
    const loadTime = Date.now() - startTime;
    
    // Performance assertions
    expect(loadTime).toBeLessThan(3000); // Load within 3 seconds
    
    // Check Core Web Vitals
    const metrics = await page.evaluate(() => {
      return new Promise((resolve) => {
        new PerformanceObserver((list) => {
          const entries = list.getEntries();
          const vitals = {
            lcp: 0,
            fid: 0,
            cls: 0
          };
          
          entries.forEach((entry) => {
            if (entry.entryType === 'largest-contentful-paint') {
              vitals.lcp = entry.startTime;
            } else if (entry.entryType === 'first-input') {
              vitals.fid = entry.processingStart - entry.startTime;
            } else if (entry.entryType === 'layout-shift') {
              vitals.cls += entry.value;
            }
          });
          
          resolve(vitals);
        }).observe({ entryTypes: ['largest-contentful-paint', 'first-input', 'layout-shift'] });
      });
    });
    
    expect(metrics.lcp).toBeLessThan(2500); // LCP < 2.5s
    expect(metrics.fid).toBeLessThan(100);   // FID < 100ms
    expect(metrics.cls).toBeLessThan(0.1);    // CLS < 0.1
  });
});
```

- **Pros**: Real user simulation, confidence in functionality
- **Cons**: Brittle tests, slow execution, maintenance overhead

## Performance Testing Patterns

### Pattern 5: Load Testing

- **When to use**: Performance validation, capacity planning
- **Implementation**: Artillery, k6, JMeter
- **Code Example**:
```yaml
# Artillery Load Test Configuration
config:
  target: 'https://api.example.com'
  phases:
    - duration: 60
      arrivalRate: 10
      name: "Warm up"
    - duration: 120
      arrivalRate: 50
      name: "Load test"
    - duration: 60
      arrivalRate: 100
      name: "Stress test"
    - duration: 30
      arrivalRate: 200
      name: "Peak load"
  payload:
    path: "test-data.csv"
    fields:
      - "email"
      - "password"
  processor: "./test-processor.js"

scenarios:
  - name: "User Registration and Login"
    weight: 30
    flow:
      - post:
          url: "/api/auth/register"
          headers:
            Content-Type: "application/json"
          json:
            email: "{{ email }}"
            password: "{{ password }}"
            firstName: "Test"
            lastName: "User"
          capture:
            - json: "$.token"
              as: "authToken"
      - think: 2
      - post:
          url: "/api/auth/login"
          headers:
            Content-Type: "application/json"
          json:
            email: "{{ email }}"
            password: "{{ password }}"
          capture:
            - json: "$.token"
              as: "authToken"

  - name: "Browse Products"
    weight: 50
    flow:
      - get:
          url: "/api/products"
          headers:
            Authorization: "Bearer {{ authToken }}"
          capture:
            - json: "$.products[*].id"
              as: "productIds"
      - think: 1
      - loop:
          - get:
              url: "/api/products/{{ productIds[$randomInt(0, {{ productIds.length-1 }})] }}"
              headers:
                Authorization: "Bearer {{ authToken }}"

  - name: "Place Order"
    weight: 20
    flow:
      - get:
          url: "/api/products"
          headers:
            Authorization: "Bearer {{ authToken }}"
          capture:
            - json: "$.products[0].id"
              as: "productId"
      - think: 2
      - post:
          url: "/api/orders"
          headers:
            Authorization: "Bearer {{ authToken }}"
            Content-Type: "application/json"
          json:
            items:
              - productId: "{{ productId }}"
                quantity: 1
            shippingAddress:
              street: "123 Test St"
              city: "Test City"
              zipCode: "12345"
              country: "US"
```

```javascript
// k6 Load Test Script
import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// Custom metrics
const errorRate = new Rate('errors');

// Test configuration
export const options = {
  stages: [
    { duration: '2m', target: 10 },   // Warm up
    { duration: '5m', target: 50 },   // Load test
    { duration: '2m', target: 100 },  // Stress test
    { duration: '1m', target: 0 },    // Cool down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // 95% of requests under 500ms
    http_req_failed: ['rate<0.1'],     // Error rate under 10%
    errors: ['rate<0.05'],             // Custom error rate under 5%
  },
};

const BASE_URL = 'https://api.example.com';

export function setup() {
  // Setup test data
  console.log('Setting up test data...');
  
  // Create test users
  for (let i = 0; i < 100; i++) {
    const payload = JSON.stringify({
      email: `testuser${i}@example.com`,
      password: 'TestPass123!',
      firstName: 'Test',
      lastName: `User${i}`
    });
    
    const response = http.post(`${BASE_URL}/api/auth/register`, payload, {
      headers: { 'Content-Type': 'application/json' }
    });
    
    check(response, {
      'user created': (r) => r.status === 201,
    });
  }
  
  console.log('Test data setup complete');
}

export default function () {
  // Test authentication
  const loginPayload = JSON.stringify({
    email: `testuser${Math.floor(Math.random() * 100)}@example.com`,
    password: 'TestPass123!'
  });
  
  const loginResponse = http.post(`${BASE_URL}/api/auth/login`, loginPayload, {
    headers: { 'Content-Type': 'application/json' }
  });
  
  const loginSuccess = check(loginResponse, {
    'login successful': (r) => r.status === 200,
    'token received': (r) => r.json('token') !== undefined,
  });
  
  if (!loginSuccess) {
    errorRate.add(1);
    return;
  }
  
  const token = loginResponse.json('token');
  
  // Test API endpoints
  const headers = {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json'
  };
  
  // Get products
  const productsResponse = http.get(`${BASE_URL}/api/products`, { headers });
  
  check(productsResponse, {
    'products retrieved': (r) => r.status === 200,
    'products array exists': (r) => Array.isArray(r.json('products')),
  });
  
  sleep(1);
  
  // Get user profile
  const profileResponse = http.get(`${BASE_URL}/api/users/profile`, { headers });
  
  check(profileResponse, {
    'profile retrieved': (r) => r.status === 200,
    'profile data exists': (r) => r.json('email') !== undefined,
  });
  
  sleep(1);
  
  // Create order
  const orderPayload = JSON.stringify({
    items: [
      {
        productId: 1,
        quantity: 2
      }
    ],
    shippingAddress: {
      street: '123 Test St',
      city: 'Test City',
      zipCode: '12345',
      country: 'US'
    }
  });
  
  const orderResponse = http.post(`${BASE_URL}/api/orders`, orderPayload, { headers });
  
  check(orderResponse, {
    'order created': (r) => r.status === 201,
    'order id exists': (r) => r.json('id') !== undefined,
  });
  
  sleep(2);
}

export function teardown() {
  // Cleanup test data
  console.log('Cleaning up test data...');
  // Implementation would cleanup created users, orders, etc.
}
```

- **Pros**: Performance validation, capacity planning, bottleneck identification
- **Cons**: Complex setup, resource intensive

## Best Practices

### Test Organization
1. **Test Pyramid**: More unit tests, fewer E2E tests
2. **Descriptive Names**: Clear test names that describe behavior
3. **AAA Pattern**: Arrange, Act, Assert structure
4. **Independent Tests**: Tests should not depend on each other
5. **Test Data Management**: Use factories and fixtures

### Test Quality
1. **Assertion Quality**: Specific assertions with clear messages
2. **Edge Cases**: Test boundary conditions and error scenarios
3. **Mocking Strategy**: Mock external dependencies appropriately
4. **Test Coverage**: Aim for meaningful coverage, not just numbers
5. **Flaky Tests**: Eliminate unreliable tests

### Continuous Integration
1. **Fast Feedback**: Run tests quickly in CI/CD
2. **Parallel Execution**: Run tests in parallel when possible
3. **Test Environments**: Consistent test environments
4. **Test Reporting**: Clear test results and coverage reports
5. **Gatekeeping**: Prevent merging with failing tests

## Common Pitfalls

### Test Design Pitfalls
- **Testing Implementation**: Testing how rather than what
- **Brittle Tests**: Tests that break with implementation changes
- **Over-mocking**: Excessive mocking leading to false confidence
- **Test Coupling**: Tests depending on internal implementation

### Execution Pitfalls
- **Slow Tests**: Tests that take too long to run
- **Flaky Tests**: Non-deterministic test results
- **Test Pollution**: Tests affecting each other
- **Poor Isolation**: Tests depending on shared state

## Tools & Resources

### Testing Frameworks
- **Jest**: JavaScript testing framework
- **Vitest**: Fast JavaScript testing
- **pytest**: Python testing framework
- **JUnit**: Java testing framework
- **RSpec**: Ruby testing framework

### E2E Testing
- **Cypress**: JavaScript E2E testing
- **Playwright**: Modern browser automation
- **Selenium**: Web browser automation
- **TestCafe**: Node.js E2E testing

### Performance Testing
- **Artillery**: Load testing as code
- **k6**: Modern load testing
- **JMeter**: Java-based load testing
- **Gatling**: High-performance load testing

### Test Infrastructure
- **Docker**: Containerized test environments
- **TestContainers**: Integration testing with containers
- **GitHub Actions**: CI/CD pipeline
- **Jenkins**: Continuous integration server

This guide provides comprehensive testing strategies and should be adapted to specific project requirements and quality standards.
