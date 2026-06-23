--光の護封壁
-- 效果：
-- 支付1000的倍数的基本分发动。只要这张卡在场上存在，持有支付的数值以下的攻击力的对方怪兽不能攻击。
function c17078030.initial_effect(c)
	-- 支付1000的倍数的基本分发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17078030.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，持有支付的数值以下的攻击力的对方怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(c17078030.atktarget)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 检查玩家是否能支付1000点LP作为发动cost
function c17078030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000点LP作为发动cost
	if chk==0 then return Duel.CheckLPCost(tp,1000,true) end
	-- 获取当前玩家的LP值
	local lp=Duel.GetLP(tp)
	local t={}
	local f=math.floor((lp)/1000)
	local l=1
	while l<=f and l<=255 do
		t[l]=l*1000
		l=l+1
	end
	-- 向玩家发送提示信息“请选择支付的基本分”
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17078030,0))  --"请选择支付的基本分"
	-- 让玩家宣言一个可支付的1000倍数的LP值
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 让玩家支付宣言的LP值
	Duel.PayLPCost(tp,announce,true)
	e:GetLabelObject():SetLabel(announce)
	e:GetHandler():SetHint(CHINT_NUMBER,announce)
end
-- 判断目标怪兽的攻击力是否小于等于已支付的LP值
function c17078030.atktarget(e,c)
	return c:GetAttack()<=e:GetLabel()
end
