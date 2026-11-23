#!/usr/bin/python
# Copyright 2026 Juan Manuel Palacios Plaza
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

from __future__ import annotations

DOCUMENTATION = r'''
---
module: localbase_facts
short_description: Gather FreeBSD user.localbase sysctl as a fact
description:
  - Queries the FreeBSD C(user.localbase) sysctl and exposes it as C(ansible_facts['localbase']).
version_added: "1.0.0"
author:
  - Juan Manuel Palacios Plaza (@jmpalacios)
options: {}
'''

EXAMPLES = r'''
- name: Gather local base fact
  ap_labs.freebsd_provisioning.localbase_facts:
'''

RETURN = r'''
ansible_facts:
  description: Dictionary containing the C(localbase) fact.
  returned: always
  type: dict
  contains:
    localbase:
      description: Path defined by the C(user.localbase) sysctl.
      type: str
      sample: /usr/local
'''

from ansible.module_utils.basic import AnsibleModule


def main():
    module = AnsibleModule(argument_spec={}, supports_check_mode=True)
    sysctl_bin = module.get_bin_path('sysctl', required=True)
    rc, out, err = module.run_command([sysctl_bin, '-n', 'user.localbase'])

    if rc != 0:
        module.fail_json(msg=f"Failed to query user.localbase: {err.strip()}")

    module.exit_json(
        changed=False,
        ansible_facts={
            'localbase': out.strip(),
        },
    )


if __name__ == '__main__':
    main()
