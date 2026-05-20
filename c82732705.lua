--スキルドレイン
-- 效果：
-- 支付1000基本分才能把这张卡发动。
-- ①：只要这张卡在魔法与陷阱区域存在，场上的表侧表示怪兽的效果无效化。
function c82732705.initial_effect(c)
	-- 支付1000基本分才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c82732705.cost)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，场上的表侧表示怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c82732705.disable)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
end
-- 判断目标卡片是否为效果怪兽（或原本是效果怪兽），以此作为效果无效的对象
function c82732705.disable(e,c)
	return c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0
end
-- 处理这张卡发动时支付1000基本分Cost的检测与扣除
function c82732705.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查玩家是否能够支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000点基本分
	Duel.PayLPCost(tp,1000)
end
