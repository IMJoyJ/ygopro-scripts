--身分転換
-- 效果：
-- ①：自己基本分比对方多的场合，双方基本分交换。
function c63875853.initial_effect(c)
	-- ①：自己基本分比对方多的场合，双方基本分交换。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63875853.target)
	e1:SetOperation(c63875853.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的条件检查函数
function c63875853.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己基本分是否比对方多，作为效果发动的条件
	if chk==0 then return Duel.GetLP(tp)>Duel.GetLP(1-tp) end
end
-- 定义效果处理函数，执行双方基本分交换
function c63875853.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己当前的基本分
	local lp1=Duel.GetLP(tp)
	-- 获取对方当前的基本分
	local lp2=Duel.GetLP(1-tp)
	if lp1>lp2 then
		-- 将自己的基本分设置为对方原本的基本分
		Duel.SetLP(tp,lp2)
		-- 将对方的基本分设置为自己原本的基本分
		Duel.SetLP(1-tp,lp1)
	end
end
