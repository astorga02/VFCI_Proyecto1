 /////////////////////////////////////////////////////////////////////////////////////////////////////////////
 // Driver/Monitor: este objeto es responsable de la interacción entre el ambiente y el la fifo bajo prueba //
 /////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Inico del modulo para definir la FIFO virtual para el driver del ambiente //

class Fifo #(parameter tama_de_paquete);
  bit [tama_de_paquete-1:0]D_pop;
  bit [tama_de_paquete-1:0]D_push;
  bit [tama_de_paquete-1:0]queue[$];
  
  task pop(output bit [tama_de_paquete-1:0] D_pop);
    if (q.size()!=0)
      begin
		D_pop=q.pop_front;
      end
    this.tamano=q.size();

  endtask
endclass



  class driver #(parameter width =16);
    virtual fifo_if #(.width(width))vif;
    trans_fifo_mbx agnt_drv_mbx;
    trans_fifo_mbx drv_chkr_mbx;    
    int espera;

    task run();
      $display("[%g]  El driver fue inicializado",$time);
      @(posedge vif.clk);
      vif.rst=1;
      @(posedge vif.clk);
      forever begin
        trans_fifo #(.width(width)) transaction; 
        vif.push = 0;
        vif.rst = 0;
        vif.pop = 0;
        vif.dato_in = 0;
        $display("[%g] el Driver espera por una transacción",$time);
        espera = 0;
        @(posedge vif.clk);
        agnt_drv_mbx.get(transaction);
        transaction.print("Driver: Transaccion recibida");
        $display("Transacciones pendientes en el mbx agnt_drv = %g",agnt_drv_mbx.num());

        while(espera < transaction.retardo)begin
          @(posedge vif.clk);
          espera = espera+1;
          vif.dato_in = transaction.dato;
	end
        case(transaction.tipo)
	  lectura: begin
	     transaction.dato = vif.dato_out;
	     transaction.tiempo = $time;
	     @(posedge vif.clk);
	     vif.pop = 1;
	     drv_chkr_mbx.put(transaction);
	     transaction.print("Driver: Transaccion ejecutada");
	   end
	   escritura: begin
	     vif.push = 1;
	     transaction.tiempo = $time;
	     drv_chkr_mbx.put(transaction); 
	     transaction.print("Driver: Transaccion ejecutada");
	   end
	   reset: begin
	     vif.rst =1;
	     transaction.tiempo = $time;
	     drv_chkr_mbx.put(transaction); 
	     transaction.print("Driver: Transaccion ejecutada");
	   end
	  default: begin
	    $display("[%g] Driver Error: la transacción recibida no tiene tipo valido",$time);
	    $finish;
	  end 
	endcase    
	@(posedge vif.clk);
      end
    endtask
  endclass

