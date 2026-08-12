--ゲール・ドグラ
-- 效果：
-- ①：支付3000基本分才能发动。从自己的额外卡组把1只怪兽送去墓地。
function c16229315.initial_effect(c)
	-- ①：支付3000基本分才能发动。从自己的额外卡组把1只怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetDescription(aux.Stringid(16229315,0))  --"送墓"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c16229315.cost)
	e1:SetTarget(c16229315.target)
	e1:SetOperation(c16229315.operation)
	c:RegisterEffect(e1)
end
-- 检查玩家是否能支付3000基本分
function c16229315.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付3000基本分
	if chk==0 then return Duel.CheckLPCost(tp,3000) end
	-- 让玩家支付3000基本分
	Duel.PayLPCost(tp,3000)
end
-- 检查自己额外卡组是否存在可送去墓地的怪兽
function c16229315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
end
-- 选择并把1只怪兽送去墓地
function c16229315.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1只可送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
