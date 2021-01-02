require_relative "../tdl/tdl.rb"
TdlBuild.frequency(__dir__) do 
    input   - 'in_signal'  ## 采样输入
    input   - 'clock'
    input   - 'rst_n'
    output.logic[16]  - 'freq'
    output.logic[16]  - 'phase'

    ## 定义采集窗口
    localparam.TOTAL    (2<<16)
    logic[16]   - 'win_cnt'
    logic       - 'win_sample'

    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            win_cnt     <= 0.A 
            win_sample  <= 1.b0 
        end
        ELSE do 
            win_cnt     <= win_cnt  + 1.b1 
            win_sample  <= win_cnt == 1.A 
        end
    end

    logic[16]   - 'high_cnt'
    logic[16]   - 'low_cnt'

    always_ff(posedge.clock, negedge.rst_n) do 
        IF ~rst_n do 
            high_cnt    <= 0.A 
            low_cnt     <= 0.A 
        end
        ELSE do 
            IF win_sample do 
                high_cnt    <= 0.A 
                low_cnt     <= 0.A 
            end
            ELSE do 
                high_cnt    <= high_cnt + in_signal
                low_cnt     <= low_cnt  + (~in_signal)
            end
        end
    end

    ## base cnt
    logic[16]   - 'scnt'

    always_ff(posedge.in_signal,negedge.rst_n) do 
        IF ~rst_n do 
            scnt    <= 0.A 
        end
        ELSE do 
            scnt    <= scnt  + 1.b1
        end
    end

    ## 锁结果
    always_ff(posedge.in_signal,negedge.rst_n) do 
        IF ~rst_n do 
            freq    <= 0.A 
            phase   <= 0.A 
        end
        ELSE do 
            
            IF win_sample do 
                phase   <= high_cnt
                freq    <= scnt.cross_clock(clock: clock)
            end
            ELSE do 
                phase   <= phase
                freq    <= freq
            end
        end
    end
end