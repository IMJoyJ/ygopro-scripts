--墓守の使徒
-- 效果：
-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以从卡组把「守墓的使徒」以外的1只名字带有「守墓」的怪兽里侧守备表示特殊召唤。
function c85646474.initial_effect(c)
	-- 这张卡被对方怪兽的攻击破坏送去墓地时，可以从卡组把「守墓的使徒」以外的1只名字带有「守墓」的怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85646474,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c85646474.condition)
	e1:SetTarget(c85646474.target)
	e1:SetOperation(c85646474.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：此卡在墓地、因战斗破坏，且是被对方怪兽攻击破坏。
function c85646474.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		-- 检查此卡原本由自己控制、此卡是攻击对象，且攻击怪兽由对方控制（即被对方怪兽攻击破坏）。
		and c:IsPreviousControler(tp) and c==Duel.GetAttackTarget() and Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：卡组中「守墓的使徒」以外的名字带有「守墓」且可以里侧守备表示特殊召唤的怪兽。
function c85646474.filter(c,e,tp)
	return c:IsSetCard(0x2e) and not c:IsCode(85646474) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果发动时的可行性检测与操作信息设置。
function c85646474.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c85646474.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息为：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只符合条件的「守墓」怪兽里侧守备表示特殊召唤，并向对方确认。
function c85646474.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，检查自己场上是否仍有可用的怪兽区域空格，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c85646474.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧怪兽。
		Duel.ConfirmCards(1-tp,g)
	end
end
