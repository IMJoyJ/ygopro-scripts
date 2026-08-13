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
-- 该效果为诱发必发效果，需要在这张卡以表侧表示存在期间发生表示形式变更时才能发动；这里通过检查变化前是否为表侧表示来满足“场上表侧表示存在的这张卡的表示形式变更时”这一触发条件。
function c14771222.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 定义检索（选择）送墓对象的过滤条件：必须是水属性怪兽，并且当前可以被送去墓地。
function c14771222.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToGrave()
end
-- 发动时点合法性检查：若处于连锁串中则不能发动（避免在连锁处理中因表示形式变更而诱发误发）；通过后将本次效果预定为从卡组送1张卡去墓地。
function c14771222.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置本连锁的处理信息：宣告这是一个将1张卡送去墓地的效果，目标区域为对方玩家视角下的卡组（实际是发动者tp的卡组），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时从发动者的卡组中选出1只满足条件的水属性怪兽送去墓地；若选到卡则将其以效果原因送去墓地。
function c14771222.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，要求发动者选择1张要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从发动者的卡组中筛选出1只满足条件的水属性怪兽（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c14771222.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的那只水属性怪兽以效果原因送入墓地，完成“从卡组把1只水属性怪兽送去墓地”。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
