# How to Use Freezed 3.0+

> **중요**: Partner Mate 프로젝트는 Freezed 3.2.3을 사용합니다. 이 문서의 가이드라인을 **반드시** 준수하세요.

## 📋 목차
1. [Freezed 3.0 Breaking Changes](#freezed-30-breaking-changes)
2. [Partner Mate 프로젝트 표준 패턴](#partner-mate-프로젝트-표준-패턴)
3. [두 가지 Freezed 3.0 스타일](#두-가지-freezed-30-스타일)
4. [JSON Serialization](#json-serialization)
5. [Extension Methods](#extension-methods)
6. [Common Patterns](#common-patterns)
7. [문제 해결](#문제-해결)

---

## Freezed 3.0 Breaking Changes

### 🔴 필수: abstract 또는 sealed 키워드

Freezed 3.0부터 factory constructor를 사용하는 클래스는 **반드시** `abstract` 또는 `sealed` 키워드가 필요합니다.

#### ❌ 잘못된 코드 (Freezed 2.x 스타일)
```dart
@freezed
class Manager with _$Manager {  // ❌ 컴파일 에러!
  const factory Manager({ ... }) = _Manager;
}
```

**에러 메시지**:
```
Error: The non-abstract class 'Manager' is missing implementations for these members:
 - _$Manager.field1
 - _$Manager.field2
 ...
```

#### ✅ 올바른 코드 (Freezed 3.0+ 스타일)
```dart
@freezed
abstract class Manager with _$Manager {  // ✅ abstract 키워드 필수
  const factory Manager({ ... }) = _Manager;
}
```

---

## Partner Mate 프로젝트 표준 패턴

> **이 프로젝트의 공식 패턴**: Factory Constructor + Abstract 방식

### 1. Domain Entity (순수 비즈니스 모델)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'manager.freezed.dart';

/// Enum 정의
enum ManagerRole {
  superUser,
  manager,
}

enum ManagerStatus {
  active,
  inactive,
}

/// Freezed Entity
@freezed
abstract class Manager with _$Manager {  // ✅ abstract 키워드
  const factory Manager({
    required String managerId,
    required String managerCode,
    required String name,
    required String email,
    required ManagerRole role,
    required ManagerStatus status,
    required int lifeMonths,
    required DateTime createdAt,
    required DateTime updatedAt,
    String? phone,
    String? fcmToken,
    DateTime? startDate,
  }) = _Manager;
}

/// Extension으로 custom 메서드 추가
extension ManagerX on Manager {
  bool get isSuperUser => role == ManagerRole.superUser;
  bool get isActive => status == ManagerStatus.active;
}
```

**중요 포인트**:
- ✅ `abstract class` 사용
- ✅ `const factory` constructor 사용
- ✅ `part 'manager.freezed.dart'` 추가
- ✅ Custom 메서드는 extension으로 분리
- ✅ JSON 없으면 .g.dart 불필요

### 2. Data Model (JSON Serialization)

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/manager.dart';

part 'manager_model.freezed.dart';
part 'manager_model.g.dart';  // ✅ JSON 직렬화용

@freezed
abstract class ManagerModel with _$ManagerModel {  // ✅ abstract 키워드
  const factory ManagerModel({
    @JsonKey(name: 'manager_id') required String managerId,
    @JsonKey(name: 'manager_code') required String managerCode,
    @JsonKey(name: 'name') required String name,
    @JsonKey(name: 'email') required String email,
    @JsonKey(name: 'role') required String role,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'life_months') required int lifeMonths,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') required DateTime updatedAt,
    @JsonKey(name: 'phone') String? phone,
    @JsonKey(name: 'fcm_token') String? fcmToken,
    @JsonKey(name: 'start_date') DateTime? startDate,
  }) = _ManagerModel;

  /// JSON → Model
  factory ManagerModel.fromJson(Map<String, dynamic> json) =>
      _$ManagerModelFromJson(json);
}

/// Extension으로 변환 로직 추가
extension ManagerModelX on ManagerModel {
  /// Model → Entity
  Manager toEntity() {
    return Manager(
      managerId: managerId,
      managerCode: managerCode,
      name: name,
      email: email,
      role: role == 'super_user' ? ManagerRole.superUser : ManagerRole.manager,
      status: status == 'active' ? ManagerStatus.active : ManagerStatus.inactive,
      lifeMonths: lifeMonths,
      createdAt: createdAt,
      updatedAt: updatedAt,
      phone: phone,
      fcmToken: fcmToken,
      startDate: startDate,
    );
  }

  /// Entity → Model (static factory)
  static ManagerModel fromEntity(Manager entity) {
    return ManagerModel(
      managerId: entity.managerId,
      managerCode: entity.managerCode,
      name: entity.name,
      email: entity.email,
      role: entity.role == ManagerRole.superUser ? 'super_user' : 'manager',
      status: entity.status == ManagerStatus.active ? 'active' : 'inactive',
      lifeMonths: entity.lifeMonths,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      phone: entity.phone,
      fcmToken: entity.fcmToken,
      startDate: entity.startDate,
    );
  }
}
```

---

## 두 가지 Freezed 3.0 스타일

Freezed 3.0에서는 두 가지 작성 방식이 가능합니다. **Partner Mate 프로젝트는 방식 1을 사용합니다.**

### 방식 1: Factory Constructor + Abstract (권장 ✅)

```dart
@freezed
abstract class ViewModule with _$ViewModule {
  const factory ViewModule({
    required String type,
    required String title,
    required String subtitle,
    required String imageUrl,
    required int time,
    required List<ProductInfo> products,
    required List<String> tabs,
  }) = _ViewModule;

  factory ViewModule.fromJson(Map<String, Object?> json) =>
      _$ViewModuleFromJson(json);
}
```

**장점**:
- ✅ Freezed의 모든 기능 사용 가능 (when, map, copyWith 등)
- ✅ 간결한 코드
- ✅ 보일러플레이트 최소화
- ✅ Union types 지원 (sealed class)

**단점**:
- ⚠️ Freezed 특유의 "magic" 존재

---

### 방식 2: 일반 클래스 스타일 (대안)

```dart
@freezed
@JsonSerializable(genericArgumentFactories: true)
class ViewModule with _$ViewModule {
  @override
  final String type;
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String imageUrl;
  @override
  final int time;
  @override
  final List<ProductInfo> products;
  @override
  final List<String> tabs;

  const ViewModule({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.time,
    required this.products,
    required this.tabs,
  });

  factory ViewModule.fromJson(Map<String, dynamic> json) =>
      _$ViewModuleFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ViewModuleToJson(this);
}
```

**장점**:
- ✅ 명시적인 필드 선언
- ✅ Freezed "magic" 없음

**단점**:
- ❌ when 메서드 자동 생성 안 됨 (switch 사용해야 함)
- ❌ @override 어노테이션 강제 (lint 경고)
- ❌ 보일러플레이트 증가
- ❌ Union types 지원 제한적

> **참고**: `@override` 경고를 무시하려면 `// ignore_for_file: annotate_overrides` 주석 추가

---

## JSON Serialization

### DateTime 자동 변환

Freezed + json_serializable은 DateTime을 자동으로 ISO 8601 문자열로 변환합니다.

```dart
// Supabase에서 가져온 JSON
{
  "created_at": "2025-01-16T12:34:56.789Z",  // ISO 8601 문자열
  "updated_at": "2025-01-16T12:34:56.789Z"
}

// Freezed가 자동으로 DateTime으로 변환
final model = ManagerModel.fromJson(json);
print(model.createdAt);  // DateTime 객체
```

### @JsonKey 어노테이션

```dart
@freezed
abstract class ManagerModel with _$ManagerModel {
  const factory ManagerModel({
    @JsonKey(name: 'manager_id') required String managerId,  // DB 컬럼명 매핑
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'phone') String? phone,  // nullable
  }) = _ManagerModel;
}
```

---

## Extension Methods

### 왜 Extension을 사용하나?

Freezed 3.0에서는 factory constructor 클래스에 직접 메서드를 추가할 수 없습니다. Extension을 사용해야 합니다.

#### ❌ 잘못된 코드
```dart
@freezed
abstract class Manager with _$Manager {
  const factory Manager({ ... }) = _Manager;

  // ❌ 컴파일 에러! factory constructor와 함께 사용 불가
  bool get isSuperUser => role == ManagerRole.superUser;
}
```

#### ✅ 올바른 코드
```dart
@freezed
abstract class Manager with _$Manager {
  const factory Manager({ ... }) = _Manager;
}

extension ManagerX on Manager {
  // ✅ Extension으로 분리
  bool get isSuperUser => role == ManagerRole.superUser;
  bool get isActive => status == ManagerStatus.active;
}
```

### Extension 네이밍 컨벤션

- **Entity Extension**: `{EntityName}X` (예: `ManagerX`, `CustomerX`)
- **Model Extension**: `{ModelName}X` (예: `ManagerModelX`, `CustomerModelX`)

---

## Common Patterns

### 1. Union Types (sealed class)

```dart
@freezed
sealed class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(Manager manager) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// when 메서드 사용
authState.when(
  initial: () => const CircularProgressIndicator(),
  loading: () => const LoadingWidget(),
  authenticated: (manager) => HomeScreen(manager: manager),
  unauthenticated: () => const LoginScreen(),
  error: (message) => ErrorWidget(message),
);
```

> **주의**: 방식 2 (일반 클래스 스타일)에서는 when 메서드가 생성되지 않습니다. `switch` 문을 사용해야 합니다.

### 2. Default Values

```dart
@freezed
abstract class Config with _$Config {
  const factory Config({
    @Default(false) bool isDebug,  // ✅ 기본값 설정
    @Default(30) int timeout,
    @Default([]) List<String> tags,
  }) = _Config;

  factory Config.fromJson(Map<String, dynamic> json) =>
      _$ConfigFromJson(json);
}
```

### 3. copyWith 사용

```dart
final manager = Manager(
  managerId: '1',
  managerCode: 'M001',
  name: '김영수',
  // ...
);

// 일부 필드만 수정
final updatedManager = manager.copyWith(
  name: '김철수',
  phone: '010-1234-5678',
);
```

---

## 문제 해결

### 1. "missing concrete implementations" 에러

**원인**: `abstract` 키워드 누락

**해결**:
```dart
@freezed
abstract class YourClass with _$YourClass {  // ← abstract 추가
  const factory YourClass({ ... }) = _YourClass;
}
```

### 2. "toEntity() method not found" 에러

**원인**: Extension에 메서드가 누락됨

**해결**:
```dart
extension YourModelX on YourModel {
  YourEntity toEntity() {  // ← 메서드 추가
    return YourEntity(...);
  }
}
```

### 3. JSON 직렬화 에러

**원인**: `part` 선언 누락

**해결**:
```dart
part 'your_model.freezed.dart';
part 'your_model.g.dart';  // ← JSON용 필수
```

### 4. when 메서드 사용 불가

**원인**: 방식 2 (일반 클래스 스타일) 사용 시 when 메서드가 생성되지 않음

**해결**: switch 문 사용
```dart
switch (result) {
  case Success():
    // 성공 처리
  case Error():
    // 에러 처리
}
```

---

## 코드 생성 명령어

```bash
# Clean & Generate
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs

# Static Analysis
flutter analyze

# Build Test
flutter build apk --debug
```

---

## 참고 문서

- [Freezed 공식 문서](https://pub.dev/packages/freezed)
- [Freezed 3.0 Migration Guide](https://github.com/rrousselGit/freezed/blob/master/packages/freezed/migration_guide.md)
- [json_serializable](https://pub.dev/packages/json_serializable)

---

**문서 버전**: 2.0
**최종 수정일**: 2025-01-16
**적용 대상**: Freezed 3.2.3+
**프로젝트**: Partner Mate
