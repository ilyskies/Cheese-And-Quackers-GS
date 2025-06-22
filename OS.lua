-- Virtual OS Simulation in Lua
math.randomseed(os.time())

-- Logger
Logger = {}
Logger.__index = Logger
function Logger:new()
    return setmetatable({ logs = {} }, Logger)
end
function Logger:log(msg)
    table.insert(self.logs, os.time() .. ": " .. msg)
end
function Logger:printLogs()
    for _, log in ipairs(self.logs) do print(log) end
end

logger = Logger:new()

-- User system
User = {}
User.__index = User
function User:new(username, isAdmin)
    return setmetatable({
        username = username,
        isAdmin = isAdmin or false
    }, User)
end

-- Permissions
Permission = { READ = 1, WRITE = 2, EXECUTE = 4 }

-- Virtual File
VFile = {}
VFile.__index = VFile
function VFile:new(name, owner, permissions, content)
    return setmetatable({
        name = name,
        owner = owner,
        permissions = permissions,
        content = content or ""
    }, VFile)
end
function VFile:canRead(user)
    return self.owner == user.username or user.isAdmin
end

-- Virtual File System
FileSystem = {}
FileSystem.__index = FileSystem
function FileSystem:new()
    return setmetatable({ files = {} }, FileSystem)
end
function FileSystem:createFile(name, owner, permissions, content)
    self.files[name] = VFile:new(name, owner, permissions, content)
    logger:log("File created: " .. name .. " by " .. owner)
end
function FileSystem:readFile(user, name)
    local file = self.files[name]
    if file and file:canRead(user) then
        logger:log(user.username .. " read file: " .. name)
        return file.content
    else
        logger:log(user.username .. " denied access to file: " .. name)
        return nil
    end
end

-- Virtual Memory Manager
MemoryManager = {}
MemoryManager.__index = MemoryManager
function MemoryManager:new(maxMemory)
    return setmetatable({
        maxMemory = maxMemory,
        usedMemory = 0,
        allocations = {}
    }, MemoryManager)
end
function MemoryManager:allocate(pid, amount)
    if self.usedMemory + amount > self.maxMemory then
        logger:log("Memory allocation failed for PID " .. pid)
        return false
    end
    self.usedMemory = self.usedMemory + amount
    self.allocations[pid] = (self.allocations[pid] or 0) + amount
    logger:log("Allocated " .. amount .. " units to PID " .. pid)
    return true
end
function MemoryManager:free(pid)
    local amount = self.allocations[pid] or 0
    self.usedMemory = self.usedMemory - amount
    self.allocations[pid] = nil
    logger:log("Freed " .. amount .. " units from PID " .. pid)
end

-- Process
Process = {}
Process.__index = Process
function Process:new(pid, user, priority, execFn)
    return setmetatable({
        pid = pid,
        user = user,
        priority = priority or 1,
        execFn = execFn,
        state = "READY",
        cycles = 0
    }, Process)
end
function Process:run()
    self.state = "RUNNING"
    self.execFn(self)
    self.cycles = self.cycles + 1
    self.state = "WAITING"
end

-- Scheduler
Scheduler = {}
Scheduler.__index = Scheduler
function Scheduler:new()
    return setmetatable({ processes = {}, pidCounter = 0 }, Scheduler)
end
function Scheduler:addProcess(user, priority, execFn)
    self.pidCounter = self.pidCounter + 1
    local proc = Process:new(self.pidCounter, user, priority, execFn)
    table.insert(self.processes, proc)
    logger:log("Added process PID " .. proc.pid)
    return proc.pid
end
function Scheduler:run(memoryManager)
    table.sort(self.processes, function(a, b)
        return a.priority > b.priority
    end)
    for _, proc in ipairs(self.processes) do
        if proc.state ~= "TERMINATED" then
            if memoryManager:allocate(proc.pid, math.random(5, 15)) then
                proc:run()
                memoryManager:free(proc.pid)
                if proc.cycles > 3 then
                    proc.state = "TERMINATED"
                    logger:log("PID " .. proc.pid .. " terminated.")
                end
            end
        end
    end
end

-- Shell
Shell = {}
Shell.__index = Shell
function Shell:new(user, fs, scheduler)
    return setmetatable({
        user = user,
        fs = fs,
        scheduler = scheduler
    }, Shell)
end

function Shell:execute(command)
    logger:log(self.user.username .. " issued command: " .. command)
    local args = {}
    for word in command:gmatch("%S+") do table.insert(args, word) end
    local cmd = args[1]

    if cmd == "read" then
        local content = self.fs:readFile(self.user, args[2])
        print(content or "Access Denied or File Not Found")
    elseif cmd == "run" then
        self.scheduler:addProcess(self.user, 1, function(proc)
            print("Process " .. proc.pid .. " running task...")
        end)
    else
        print("Unknown command.")
    end
end

-- Simulated environment setup
local admin = User:new("admin", true)
local alice = User:new("alice")
local fs = FileSystem:new()
local memory = MemoryManager:new(100)
local scheduler = Scheduler:new()

fs:createFile("hello.txt", "alice", Permission.READ, "Hello from Alice.")
fs:createFile("admin.log", "admin", Permission.READ, "System logs.")

-- Create shell and interact
local shell = Shell:new(alice, fs, scheduler)
shell:execute("read hello.txt")
shell:execute("read admin.log")
shell:execute("run")

-- Main loop
for cycle = 1, 5 do
    print("=== SYSTEM TICK " .. cycle .. " ===")
    scheduler:run(memory)
end

-- Print logs
print("\n=== SYSTEM LOGS ===")
logger:printLogs()
