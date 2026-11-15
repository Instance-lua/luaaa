--Strict
--Made by instance.


local Benchmark = {}

function Benchmark.Run(callback: () -> (), iterations: number?, warmup: number?)
    iterations = iterations or 100
    warmup = warmup or math.min(10, iterations)
    assert(iterations > 0 and iterations % 1 == 0, "Iterations must be a positive integer")

    for _ = 1, warmup do callback() end

    local samples = table.create(iterations)
    local total = 0
    for index = 1, iterations do
        local startedAt = os.clock()
        callback()
        local elapsed = os.clock() - startedAt
        samples[index] = elapsed
        total += elapsed
    end

    table.sort(samples)
    local percentileIndex = math.max(1, math.ceil(#samples * 0.95))
    return {
        Iterations = iterations,
        Total = total,
        Average = total / iterations,
        Minimum = samples[1],
        Median = samples[math.ceil(iterations / 2)],
        P95 = samples[percentileIndex],
        Maximum = samples[#samples],
    }
end

return Benchmark
