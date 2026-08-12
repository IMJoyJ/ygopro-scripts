--絶海の騎士
-- 效果：
-- 场上表侧表示存在的这张卡的表示形式变更时，从卡组把1只水属性怪兽送去墓地。这个效果1回合只能使用1次。
function c14771222.initial_effect(c)
	-- 场上表侧表示存在的这张卡的表示形式变更时，从卡组把1只水属性怪兽送去墓地。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14771222,0))  --"卡组送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHANGE_POS)
	e1:SetCountLimit(1)
	e1:SetCondition(c14771222.condition)
	e1:SetTarget(c14771222.target)
	e1:SetOperation(c14771222.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：这张卡在表示形式变更前是正面表示
function c14771222.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 过滤函数：选择满足条件的水属性怪兽
function c14771222.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
-- 效果的处理目标设定：从卡组选择1只水属性怪兽送去墓地
function c14771222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置连锁处理信息：将要从卡组送去墓地的卡数量设为1
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理流程：选择并把符合条件的水属性怪兽送去墓地
function c14771222.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组选择1只满足条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c14771222.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地，原因是由效果造成
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
