# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# # limitations under the License.
module Google
  module Cloud
    module Talent
      module V4beta1
        class CompanyServiceClient
          # Alias for Google::Cloud::Talent::V4beta1::CompanyServiceClient.company_path.
          # @param project [String]
          # @param company [String]
          # @return [String]
          def company_path project, company
            self.class.company_path project, company
          end
        
          # Alias for Google::Cloud::Talent::V4beta1::CompanyServiceClient.project_path.
          # @param project [String]
          # @return [String]
          def project_path project
            self.class.project_path project
          end
        end
        
        class JobServiceClient
          # Alias for Google::Cloud::Talent::V4beta1::JobServiceClient.job_path.
          # @param project [String]
          # @param jobs [String]
          # @return [String]
          def job_path project, jobs
            self.class.job_path project, jobs
          end
        
          # Alias for Google::Cloud::Talent::V4beta1::JobServiceClient.project_path.
          # @param project [String]
          # @return [String]
          def project_path project
            self.class.project_path project
          end
        end
        
        class ProfileServiceClient
          # Alias for Google::Cloud::Talent::V4beta1::ProfileServiceClient.profile_path.
          # @param project [String]
          # @param tenant [String]
          # @param profile [String]
          # @return [String]
          def profile_path project, tenant, profile
            self.class.profile_path project, tenant, profile
          end
        
          # Alias for Google::Cloud::Talent::V4beta1::ProfileServiceClient.tenant_path.
          # @param project [String]
          # @param tenant [String]
          # @return [String]
          def tenant_path project, tenant
            self.class.tenant_path project, tenant
          end
        end
        
        class TenantServiceClient
          # Alias for Google::Cloud::Talent::V4beta1::TenantServiceClient.project_path.
          # @param project [String]
          # @return [String]
          def project_path project
            self.class.project_path project
          end
        
          # Alias for Google::Cloud::Talent::V4beta1::TenantServiceClient.tenant_path.
          # @param project [String]
          # @param tenant [String]
          # @return [String]
          def tenant_path project, tenant
            self.class.tenant_path project, tenant
          end
        end
      end
    end
  end
end