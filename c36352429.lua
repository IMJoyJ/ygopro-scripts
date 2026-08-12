--ヴァンパイア・ドラゴン
-- 效果：
-- 上级召唤的这张卡从场上送去墓地时，可以从卡组把1只4星以下的怪兽加入手卡。
function c36352429.initial_effect(c)
	-- 上级召唤的这张卡从场上送去墓地时，可以从卡组把1只4星以下的怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36352429,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c36352429.condition)
	e1:SetTarget(c36352429.target)
	e1:SetOperation(c36352429.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡是从场上送去墓地且为上级召唤
function c36352429.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 效果处理准备：检查卡组是否存在满足条件的怪兽
function c36352429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：卡组中是否存在1只4星以下的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36352429.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：准备从卡组检索1只怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索过滤条件：等级不超过4的怪兽且能加入手牌
function c36352429.filter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理执行：选择并把符合条件的怪兽加入手牌
function c36352429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c36352429.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
