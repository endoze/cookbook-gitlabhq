gitlabhq Cookbook
=================
This cookbook installs and configures GitLab. It also installs and
configures GitLab CI.


Requirements
------------
- Hard disk space
  - Around 200 mb plus space for your repositories
 
#### packages
- `redisio` - Redis is needed
- `build-essential` - Used for building some dependencies

Attributes
----------
#### gitlabhq::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['gitlabhq']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### gitlabhq::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `gitlabhq` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[gitlabhq]"
  ]
}
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `my_cool_feature`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors: Chris 
