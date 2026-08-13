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
-- 定义卡组内候选卡的过滤条件：必须是怪兽、暗属性且可以送去墓地。
function c28985331.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 效果发动前的目标判定函数：检查是否满足发动条件并登记处理时送墓的操作信息。
function c28985331.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点（chk==0）检查卡组中是否存在至少1张符合tgfilter过滤条件的暗属性怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c28985331.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次效果处理的信息登记为“从卡组把1张卡送去墓地”，用于后续时点及连锁的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时的执行函数：从卡组选择符合条件的暗属性怪兽并将其送去墓地。
function c28985331.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己的卡组中选出1张符合tgfilter过滤条件的暗属性怪兽（必选1张）。
	local g=Duel.SelectMatchingCard(tp,c28985331.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去墓地，完成卡片实际送入墓地的操作。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
