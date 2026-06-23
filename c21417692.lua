--ダーク・エルフ
-- 效果：
-- 这张卡不支付1000基本分不能攻击。
function c21417692.initial_effect(c)
	-- 这张卡不支付1000基本分不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_COST)
	e1:SetCost(c21417692.atcost)
	e1:SetOperation(c21417692.atop)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付1000基本分作为攻击代价
function c21417692.atcost(e,c,tp)
	-- 检查玩家是否能支付1000基本分
	return Duel.CheckLPCost(tp,1000)
end
-- 支付1000基本分作为攻击代价
function c21417692.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家支付1000基本分
	Duel.PayLPCost(tp,1000)
end
