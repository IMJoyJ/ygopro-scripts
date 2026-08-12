--ジェネクス・サーチャー
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的「次世代」怪兽攻击表示特殊召唤。
function c67483216.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只攻击力1500以下的「次世代」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67483216,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c67483216.condition)
	e1:SetTarget(c67483216.target)
	e1:SetOperation(c67483216.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：这张卡因战斗破坏被送去墓地。
function c67483216.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义过滤条件：攻击力1500以下、属于「次世代」系列且可以攻击表示特殊召唤的怪兽。
function c67483216.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsSetCard(0x2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 定义效果发动目标：检查怪兽区域空位以及卡组中是否存在可特殊召唤的怪兽。
function c67483216.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动阶段，检查卡组中是否存在至少1只满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c67483216.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示该效果包含从卡组特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理：从卡组选择1只满足条件的「次世代」怪兽以表侧攻击表示特殊召唤。
function c67483216.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，若己方场上已无可用怪兽区域，则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中筛选并让玩家选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c67483216.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
