--ギミック・パペット－シザー・アーム
-- 效果：
-- ①：这张卡召唤时才能发动。从卡组把1只「机关傀儡」怪兽送去墓地。
function c29216967.initial_effect(c)
	-- ①：这张卡召唤时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29216967,0))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c29216967.target)
	e1:SetOperation(c29216967.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的「机关傀儡」怪兽
function c29216967.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1083) and c:IsAbleToGrave()
end
-- 效果处理时的条件判断与操作信息设置
function c29216967.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，即卡组中是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c29216967.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要处理送去墓地的效果
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时执行的操作，包括选择并送去墓地
function c29216967.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c29216967.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
