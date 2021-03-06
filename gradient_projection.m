function alpha_new = gradient_projection (f,alpha0,up,low,maxit,beta,n,c,y,k,b,landa,regHyper,num_feas)
       
     ndim = length(alpha0);
     kku = up; kkl = low;
     xc = alpha0; 
     fc = f(xc);
     numf=1; numg=1; numh=0;
     for i = 1:ndim
         kku(i) = up(i); kkl(i) = low(i);
         if kkl(i)> kku(i)
             error('lower bound exceeds upper bound');
         end
     end
     
     if norm (xc-kk_proj(xc,kku,kkl))>0
         disp('initial iterate not feasible')
         xc = kk_proj(xc,kku,kkl);
     end 
     alp = 1.d-4;
     itc=1;
     % compute the gradient function g
     % if yi*f(xi)>=1 ==> g =0
     % if yi*f(xi)<1 ==> g = k*(sum(beta.*y))
     h = 1-y'.*(sum(repmat(c,1,n).*kernel_matrix(k, xc),1) + b);
     posit_indx = find(h>0); 
     gc =zeros(num_feas*5,1);
     for i = 1:n
         for j = 1:numel(posit_indx)
             gc = gc + (-y(posit_indx(j))*beta(i)*y(i))*k{i,posit_indx(j)};
         end
     end
     gc = regHyper*gc +landa;
     pgc = xc-kk_proj(xc - gc,kku,kkl);
     ia =0;
     for i = 1:ndim
        if (xc(i)==kku(i)| xc(i)==kkl(i))
            ia = ia +1;
        end 
     end
     
     ithist(1,5)=ia/ndim;
ithist(1,1)=norm(pgc); ithist(1,2) = fc; ithist(1,4)=itc-1; ithist(1,3)=0; 
tol=1.d-6;
while(itc <= maxit)
        lambda=1;
        xt=kk_proj(xc-lambda*gc,kku,kkl); ft=f(xt);
        numf=numf+1;
	iarm=0; itc=itc+1;
        pl=xc - xt; 
        fgoal=fc-(pl'*pl)*(alp/lambda);
        norm_xc = norm((xt-xc),2)/(norm(xc,2)*norm(xt,2));
        
%
%       simple line search
%
        q0=fc; qp0=-gc'*gc; qc=ft;
	while(ft > fgoal)
                lambda=lambda*.1;
		iarm=iarm+1;
		xt=kk_proj(xc-lambda*gc,kku,kkl);
                pl=xc-xt;
		ft=f(xt); numf = numf+1;
% 		if(iarm > 10) 
% 		disp(' Armijo error in gradient projection')
% %                 histout=ithist(1:itc,:); costdata=[numf, numg, numh];
% 		return; end
                fgoal=fc-(pl'*pl)*(alp/lambda);
	end
	xc=xt; fc=f(xc);
     h = 1-y'.*(sum(repmat(c,1,n).*kernel_matrix(k, xc),1) + b);
     posit_indx = find(h>0); 
     gc =zeros(5*num_feas,1);
     for i = 1:n
         for j = 1:numel(posit_indx)
             gc = gc + (-y(posit_indx(j))*beta(i)*y(i))*k{i,posit_indx(j)};
         end
     end
    gc = regHyper*gc +landa;
    numf=numf+1; numg=numg+1;
        pgc=xc-kk_proj(xc-gc,kku,kkl); 
	ithist(itc,1)=norm(pgc); ithist(itc,2) = fc; 
	ithist(itc,4)=itc-1; ithist(itc,3)=iarm;
ia=0; for i=1:ndim; if(xc(i)==kku(i) | xc(i)==kkl(i)) ia=ia+1; end; end;
ithist(itc,5)=ia/ndim;

 

end
alpha_new =xc; 
% histout=ithist(1:itc,:); costdata=[numf, numg, numh];
end

function px = kk_proj(x,kku,kkl)
ndim=length(x);
px=zeros(ndim,1);
px=min(kku,x); 
px=max(kkl,px);
end
