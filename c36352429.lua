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
-- 效果发动条件：这张卡之前位于场上，并且是以上级召唤方式出场的；两者同时满足才允许发动。
function c36352429.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 发动时检查卡组中是否存在符合条件的怪兽，并设置本次效果的操作信息，明确为将卡组中的卡加入手卡的检索效果。
function c36352429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时点（chk==0）检查卡组中是否存在至少1张满足c36352429.filter的怪兽卡，作为效果能否发动的合法性条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c36352429.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：效果处理时将把1张卡从己方卡组加入手卡（CATEGORY_TOHAND），供其他卡片或效果进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义检索对象的过滤条件：等级4以下、是怪兽卡、并且可以被加入手卡。
function c36352429.filter(c)
	return c:IsLevelBelow(4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理：让玩家从自己卡组选择1张满足条件的怪兽卡加入手卡，并让对手确认该卡。
function c36352429.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家“请选择要加入手牌的卡”，用于引导后续的选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己卡组中筛选并选择1张满足c36352429.filter的怪兽卡，作为本次要加入手卡的对象。
	local g=Duel.SelectMatchingCard(tp,c36352429.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对手（1-tp）确认，保证信息透明。
		Duel.ConfirmCards(1-tp,g)
	end
end
