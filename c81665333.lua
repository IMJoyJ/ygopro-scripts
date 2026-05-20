--撤収命令
-- 效果：
-- 自己场上存在的怪兽全部回到持有者手卡。
function c81665333.initial_effect(c)
	-- 自己场上存在的怪兽全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81665333.target)
	e1:SetOperation(c81665333.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的目标检测与准备
function c81665333.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在至少1只可以回到手卡的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,nil) end
	-- 获取自己场上所有可以回到手卡的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息，为将这些怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理的执行
function c81665333.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有可以回到手卡的怪兽
	local sg=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,0,nil)
	-- 将这些怪兽全部送回持有者的手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
