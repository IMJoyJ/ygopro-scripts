--終末の騎士
-- 效果：
-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把1只暗属性怪兽送去墓地。
function c28985331.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤成功时才能发动。从卡组把1只暗属性怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28985331,0))  --"从卡组把1只暗属性怪兽送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c28985331.target)
	e1:SetOperation(c28985331.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的暗属性怪兽（可送去墓地）
function c28985331.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 效果处理时的判断与设置，检查是否满足发动条件并设置操作信息
function c28985331.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断在卡组中是否存在至少1张满足条件的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28985331.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将从卡组选择1张暗属性怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行将符合条件的暗属性怪兽从卡组送去墓地的操作
function c28985331.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张满足条件的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c28985331.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
