# Copyright 2023 Swisscom (Schweiz) AG

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

@PolicyScheduler
Feature: Policy scheduler composition
  Tests the policy scheduler composition

  Background:
    Given input claim xr.yaml
    And input composition composition.yaml
    And input functions functions.yaml
    Then check that no resources are provisioning

  @normal
  Scenario: this scenario doesn't make any output

    # render 1
    When crossplane renders the composition
    Then check that no resources are provisioning

  @normal
  Scenario: active schedule creates a role and when it is ready an attachment is created

    Given input claim xr-active.yaml
    When crossplane renders the composition
    Then check that 1 resource is provisioning and it is
      | resource-name |
      | role-0        |
    And check that resource role-0 has parameters
      | param name     | param value |
      | metadata.name  | role-app-1  |

    Given change observed resource role-0 with status READY
    When crossplane renders the composition
    Then check that 2 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | attachment-0      |
    And check that resource attachment-0 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-1  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy1 |
  @normal
  Scenario: multiple active schedules create multiple roles and attachments
    Given input claim xr-multiple-active.yaml
    When crossplane renders the composition
    Then check that 2 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-1            |
    And check that resource role-0 has parameters
      | param name     | param value |
      | metadata.name  | role-app-1  |
    And check that resource role-1 has parameters
      | param name     | param value |
      | metadata.name  | role-app-2  |

    Given change observed resource role-0 with status READY
    And change observed resource role-1 with status READY
    When crossplane renders the composition
    Then check that 4 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-1            |
      | attachment-0      |
      | attachment-1      |
    And check that resource attachment-0 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-1  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy1 |
    And check that resource attachment-1 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-2  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy2 |
  @normal
  Scenario: multiple and mixed active schedules create multiple roles and attachments
    Given input claim xr-mixed.yaml
    When crossplane renders the composition
    Then check that 2 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-2            |
    And check that resource role-0 has parameters
      | param name     | param value |
      | metadata.name  | role-app-1  |
    And check that resource role-2 has parameters
      | param name     | param value |
      | metadata.name  | role-app-3  |

    Given change observed resource role-0 with status READY
    And change observed resource role-2 with status READY
    When crossplane renders the composition
    Then check that 4 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-2            |
      | attachment-0      |
      | attachment-2      |
    And check that resource attachment-0 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-1  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy1 |
    And check that resource attachment-2 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-3  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy3 |
  @normal
  Scenario: resources are deleted when schedule is not active anymore
    Given input claim xr-mixed.yaml
    When crossplane renders the composition
    Then check that 2 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-2            |
    And check that resource role-0 has parameters
      | param name     | param value |
      | metadata.name  | role-app-1  |
    And check that resource role-2 has parameters
      | param name     | param value |
      | metadata.name  | role-app-3  |

    Given change observed resource role-0 with status READY
    And change observed resource role-2 with status READY
    When crossplane renders the composition
    Then check that 4 resources are provisioning and they are
      | resource-name     |
      | role-0            |
      | role-2            |
      | attachment-0      |
      | attachment-2      |
    And check that resource attachment-0 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-1  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy1 |
    And check that resource attachment-2 has parameters
      | param name     | param value |
      | spec.forProvider.roleName  | role-app-3  |
      | spec.forProvider.policyArn  | arn:aws:iam::aws:policy/AmazonPolicy3 |

    Given input claim xr.yaml
    When crossplane renders the composition
    Then check that no resources are provisioning
