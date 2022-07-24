`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/22/2021 08:45:04 AM
// Design Name: 
// Module Name: islemci
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module islemci(
    input saat,
    input reset,
    input [31:0]buyruk,
    output reg [31:0]ps,
    output reg [31:0]yazmac_on
    );
    integer i;
    reg [31:0] yazmaclar [31:0];
    reg [31:0] yeni_ps;
    reg signed [31:0] anlik_deger_SB;
    reg signed [31:0] anlik_deger_I;
    reg signed [31:0] anlik_deger_UJ;
    reg [4:0] hy, ky1, ky2;
    reg [6:0] is_kodu;
    reg [2:0] funct3;
    reg [6:0] funct7;
    reg [31:0] temp_hedef_yazmaci;
    
    
    initial begin
        for(i=0; i<32; i=i+1)   begin
        yazmaclar[i] = 0;
        end
        yazmac_on = 0;
        yeni_ps = 0;
        ps[31:0] = 32'd0;
        temp_hedef_yazmaci = 0;
    end
    
    always@ (*) begin
        
        if (reset == 0)   begin
            is_kodu = buyruk[6:0];
            if(is_kodu == 7'b0110011) begin   // R tipi buyruk calistirilir
                hy = buyruk[11:7];
                ky1 = buyruk[19:15];
                ky2 = buyruk[24:20];
                funct3 = buyruk[14:12];
                funct7 = buyruk[31:25];
                if(funct3 == 3'b000 && funct7 == 7'b0000000)    begin //add
                    temp_hedef_yazmaci = yazmaclar[ky1] + yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
                else if (funct3 == 3'b000 && funct7 == 7'b0100000)  begin //sub
                    temp_hedef_yazmaci = yazmaclar[ky1] - yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
                else if (funct3 == 3'b100 && funct7 == 7'b0000000)  begin //xor
                    temp_hedef_yazmaci = yazmaclar[ky1] ^ yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
                else if (funct3 == 3'b111 && funct7 == 7'b0000000)  begin //and
                    temp_hedef_yazmaci = yazmaclar[ky1] & yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
                else if (funct3 == 3'b101 && funct7 == 7'b0000000)  begin //srl
                    temp_hedef_yazmaci = yazmaclar[ky1] >> yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
                else if (funct3 == 3'b101 && funct7 == 7'b0100000)  begin //sra
                    temp_hedef_yazmaci = yazmaclar[ky1] >>> yazmaclar[ky2];
                    yeni_ps = ps + 4;
                end
            end // R tipi buyryk end
            
            
            else if(is_kodu == 7'b0010011 || is_kodu == 7'b1100111)    begin   // I tipi buyruk calistirilir
                hy = buyruk[11:7];
                ky1 = buyruk[19:15];
                anlik_deger_I = {{20{buyruk[31]}},buyruk[31:20]};
                funct3 = buyruk[14:12];
                if(funct3 == 3'b000 && is_kodu == 7'b0010011)    begin //addi
                    temp_hedef_yazmaci = yazmaclar[ky1] + anlik_deger_I; 
                    yeni_ps = ps + 4;  
                end
                else if (funct3 == 3'b100 && is_kodu == 7'b0010011)  begin //xori
                    temp_hedef_yazmaci = yazmaclar[ky1] ^ anlik_deger_I;
                    yeni_ps = ps + 4;  
                end
                else if (funct3 == 3'b101 && is_kodu == 7'b0010011)  begin //srai
                    temp_hedef_yazmaci = yazmaclar[ky1] >>> anlik_deger_I;  
                    yeni_ps = ps + 4;  
                end
                else if (funct3 == 3'b010 && is_kodu == 7'b0010011)  begin //slti
                    if(yazmaclar[ky1] < anlik_deger_I) begin
                        temp_hedef_yazmaci = 32'd1;
                    end
                    else    begin
                        temp_hedef_yazmaci = 32'd0;
                    end
                    yeni_ps = ps + 4; 
                end
                else if (funct3 == 3'b000 && is_kodu == 7'b1100111)  begin //jalr
                    temp_hedef_yazmaci = ps + 4;
                    yeni_ps = yazmaclar[ky1] + anlik_deger_I; 
                  
                end 
            end // I tipi buyruk biter
            
            
            else if(is_kodu == 7'b1100011)    begin   // SB tipi buyruk calistirilir
                    anlik_deger_SB[0] = 0;
                    anlik_deger_SB[12] = buyruk[31];
                    anlik_deger_SB[11] = buyruk[7];
                    anlik_deger_SB[4:1] = buyruk[11:8];
                    anlik_deger_SB[10:5] = buyruk[30:25];
                    anlik_deger_SB[31:13] = {20{buyruk[31]}};
                    ky1 = buyruk[19:15];
                    ky2 = buyruk[24:20];
                    funct3 = buyruk[14:12];
                if(funct3 == 3'b000 )    begin //beg
                    if(yazmaclar[ky1] == yazmaclar[ky2])    begin
                        yeni_ps = ps + anlik_deger_SB;
                    end
                    else    begin
                        yeni_ps = ps + 4;
                    end
                end
                else if (funct3 == 3'b100 )  begin //blt
                    if(yazmaclar[ky1] < yazmaclar[ky2])    begin
                        yeni_ps = ps + anlik_deger_SB;
                    end
                    else    begin
                        yeni_ps = ps + 4;
                    end
                end
                else if (funct3 == 3'b101 )  begin //bge    
                    if(yazmaclar[ky1] >= yazmaclar[ky2])    begin
                        yeni_ps = ps + anlik_deger_SB;
                    end
                    else    begin
                        yeni_ps = ps + 4;
                    end 
                end
            end// SB tipi buyruk biter
            
            
            
            else if(is_kodu == 7'b1101111)    begin   // UJ tipi buyruk calistirilir
                hy = buyruk[11:7];
                anlik_deger_UJ[0] = 0;
                anlik_deger_UJ[10:1] = buyruk[30:21];
                anlik_deger_UJ[20] = buyruk[31];
                anlik_deger_UJ[11] = buyruk[20];
                anlik_deger_UJ[19:12] = buyruk[19:12];
                anlik_deger_UJ[31:21] = {11{buyruk[31]}};
                temp_hedef_yazmaci = ps + 4;
                yeni_ps = ps + anlik_deger_UJ; 
            end // UJ tipi buyruk biter
            
            yazmac_on = yazmaclar[10];
        end// else end
        
        
    end//always * end
    
    always@ (posedge saat)  begin
        if(reset == 1)  begin
            ps = 0; 
            yeni_ps = 0;
            yazmac_on = 0;
            temp_hedef_yazmaci = 0;
            for(i=0; i<32; i=i+1)    begin
                    yazmaclar[i] = 0;
            end
        end // reset ends
        else    begin
            ps <= yeni_ps;  // ps degeri atanir
            yazmaclar[hy] <= temp_hedef_yazmaci;
            yazmac_on <= yazmaclar[10];  // yazmac_on degeri atanir    
        end    
    end
    
endmodule
