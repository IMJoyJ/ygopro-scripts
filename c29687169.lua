--魔装戦士 アルニス
-- 效果：
-- ①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的魔法师族怪兽攻击表示特殊召唤。
function c29687169.initial_effect(c)
	-- 效果原文内容：①：这张卡被对方怪兽的攻击破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的魔法师族怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29687169,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c29687169.condition)
	e1:SetTarget(c29687169.target)
	e1:SetOperation(c29687169.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断此卡是否因战斗破坏被送入墓地且攻击怪兽为对方控制
function c29687169.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
		-- 规则层面作用：判断攻击怪兽是否为对方控制
		and Duel.GetAttacker():IsControler(1-tp)
end
-- 规则层面作用：过滤满足攻击力1500以下、魔法师族且可特殊召唤的怪兽
function c29687169.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 规则层面作用：判断是否满足发动条件，包括场上是否有空位及卡组是否存在符合条件的怪兽
function c29687169.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c29687169.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面作用：执行特殊召唤操作，包括检查空位、选择怪兽并进行特殊召唤
function c29687169.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查场上是否有空位以进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c29687169.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面作用：将选中的怪兽以攻击表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
