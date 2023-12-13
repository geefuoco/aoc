cache = {}

def count(string, nums):
    if string == "":
        return 1 if nums == () else 0
    if nums == ():
        return 0 if "#" in string else 1
    result = 0

    key = (string, nums)
    if key in cache:
        return cache[key]

    if string[0] in ".?":
        result += count(string[1:], nums)

    if string[0] in "#?":
        if nums[0] <= len(string) and "." not in string[:nums[0]] and (nums[0] == len(string) or string[nums[0]] != "#"):
            result += count(string[nums[0]+1:], nums[1:])

    cache[key] = result
    return result

total = 0
for line in open(0):
    string, nums = line.split()
    nums = tuple(map(int, nums.split(",")))

    string = "?".join([string]*5)
    nums *= 5

    total += count(string, nums)

print(total)


    
    
    

