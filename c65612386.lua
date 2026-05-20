--魔帝アングマール
-- 效果：
-- ①：这张卡上级召唤成功时，把自己墓地1张魔法卡除外才能发动。把1张除外的那张魔法卡的同名卡从卡组加入手卡。
function c65612386.initial_effect(c)
	-- ①：这张卡上级召唤成功时，把自己墓地1张魔法卡除外才能发动。把1张除外的那张魔法卡的同名卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65612386,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c65612386.condition)
	e1:SetCost(c65612386.cost)
	e1:SetTarget(c65612386.target)
	e1:SetOperation(c65612386.operation)
	c:RegisterEffect(e1)
end
-- 判定此卡是否通过上级召唤成功
function c65612386.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤条件：自己墓地中可以作为发动代价除外，且卡组中存在同名卡的魔法卡
function c65612386.cfilter(c,tp)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
		-- 检查卡组中是否存在与该卡同名且可以加入手牌的卡
		and Duel.IsExistingMatchingCard(c65612386.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 过滤条件：卡组中与指定卡号相同且可以加入手牌的卡
function c65612386.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
-- 发动代价处理：从自己墓地将1张魔法卡除外，并记录其卡号
function c65612386.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己墓地是否存在满足条件的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65612386.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1张满足过滤条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c65612386.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 将选择的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果的目标处理：设置效果处理时的操作信息为从卡组将1张卡加入手牌
function c65612386.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表示该效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理：从卡组将1张与除外卡同名的卡加入手牌并向对方确认
function c65612386.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张与作为代价除外的魔法卡同名的卡
	local g=Duel.SelectMatchingCard(tp,c65612386.thfilter,tp,LOCATION_DECK,0,1,1,nil,e:GetLabel())
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
