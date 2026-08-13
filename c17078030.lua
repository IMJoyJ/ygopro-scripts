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
-- 实现效果发动时的代价处理：先检查能否支付最低1000基本分；再根据当前LP生成所有不超过LP且为1000倍数的候选值（最多255个）；让玩家选择其中一个作为支付值；支付后将该值存入e2的标签，作为后续攻击力限制的判断阈值，并给卡加上数值提示。
function c17078030.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：确认玩家当前基本分足以支付1000点（即至少能支付1000的倍数）；若不能则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,1000,true) end
	-- 获取玩家当前基本分，用于计算可以支付的1000的倍数的候选数值范围。
	local lp=Duel.GetLP(tp)
	local t={}
	local f=math.floor((lp)/1000)
	local l=1
	while l<=f and l<=255 do
		t[l]=l*1000
		l=l+1
	end
	-- 向玩家显示“请选择支付的基本分”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17078030,0))  --"请选择支付的基本分"
	-- 让玩家从1000的倍数候选数值中宣言/选择一个数值，作为实际要支付的基本分。
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 扣除玩家所选择数值的基本分，完成代价支付。
	Duel.PayLPCost(tp,announce,true)
	e:GetLabelObject():SetLabel(announce)
	e:GetHandler():SetHint(CHINT_NUMBER,announce)
end
-- 判断对方怪兽是否因攻击力不超过记录的支付数值而受到“不能攻击”的限制；若满足条件则禁止该怪兽攻击。
function c17078030.atktarget(e,c)
	return c:GetAttack()<=e:GetLabel()
end
