# Contributing to MasterG

Thank you for your interest in improving MasterG! We appreciate your contributions to help language learners around the world.

---

## 1. Development Workflow

1. **Fork the Repository**: Create a personal fork on GitHub.
2. **Clone your Fork**:
   ```bash
   git clone git@github.com:<your-username>/MasterG.git
   cd MasterG
   ```
3. **Create a Feature Branch**:
   ```bash
   git checkout -b feature/your-feature-name
   # or for bug fixes:
   git checkout -b fix/issue-description
   ```
4. **Make Changes & Test**:
   - Ensure backend tests pass:
     ```bash
     cd masterg_api && python api/manage.py test authentication grammar vocabulary
     ```
   - Ensure frontend tests & lints pass:
     ```bash
     cd masterg_app && flutter analyze && flutter test
     ```
5. **Commit with Conventional Commits**:
   - `feat: add speaking fluency assessment`
   - `fix: resolve token refresh race condition`
   - `docs: update API documentation`
6. **Push and Open a Pull Request**:
   Push to your feature branch and submit a PR against `main`.

---

## 2. Commit Message Standards

We follow the Conventional Commits specification:
- `feat`: A new user-facing capability or API endpoint.
- `fix`: A bug fix or defect correction.
- `docs`: Documentation updates or additions.
- `style`: Changes that do not affect code logic (formatting, whitespace).
- `refactor`: Code change that neither fixes a bug nor adds a feature.
- `test`: Adding missing tests or correcting existing tests.
- `chore`: Build process, dependency updates, or tooling configuration.

---

## 3. Pull Request Guidelines

- Fill out the provided [Pull Request Template](.github/pull_request_template.md).
- Keep pull requests focused on a single responsibility.
- Verify that automated CI checks pass before requesting reviews.
