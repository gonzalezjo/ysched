# ysched
### Easily control script execution.
##### An easy, advanced, coroutine based Lua scheduler. 


***


###### Docs: 

`wait(float seconds)` - Calls custom yield function with a check. Resumes execution after the amount of seconds that has been passed.

`yield(function condition, (optional) function callback, (optional) callback arguments)` - If only a condition is passed, resume execution after condition is met. If a function callback is provided, call that function after with the arguments specified by the optional callback arguments list. Additional callback arguments can be provided by passing additional arguments to yield. 

`spawn(function createasync)` - Create a function and add it to the scheduler thread, so it runs "asynchronously". 


###### Usage
There are two ways of using ysched. You can directly launch scripts using it, or you can just require it from your script. 


**Direct Launch**

Use lua (or luajit) in the commandline with the first argument being ysched.lua and the second being the script you want it to manage. As an example, you can load `TARGETFILE.lua` in the scheduler with: `luajit ysched.lua TARGETFILE.lua`

**Requiring**
Put ysched in the same folder as your script, and then add: 
```lua
require "ysched"
```
to the top of your script. 

###### Code Examples

**Input:**
```lua
require "scheduler\\ysched"
print "Start"

local variable = 5

print("Line 5: " .. os.clock())

spawn(function()
    print("Line 8: " .. os.clock())
    yield(function() return variable == 10 end, print, "'variable' is " .. variable)
    print("Line 10: " .. os.clock())
end)

print("Line 13: " .. os.clock())
wait(3)
print("Line 15: " .. os.clock())
variable = 10
print("Line 17: " .. os.clock())
```

**Output:**
```
Start
Line 5: 0
Line 13: 0
Line 8: 0
Line 15: 3
Line 17: 3
Line 10: 3.001
lua: scheduler\ysched.lua:70: Execution complete.
```
