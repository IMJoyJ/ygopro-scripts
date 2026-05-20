--ユーフォロイド
-- 效果：
-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的机械族怪兽表侧攻击表示特殊召唤，那之后卡组洗切。
function c7602840.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，可以从卡组把1只攻击力1500以下的机械族怪兽表侧攻击表示特殊召唤，那之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7602840,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c7602840.condition)
	e1:SetTarget(c7602840.target)
	e1:SetOperation(c7602840.operation)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：自身因战斗破坏被送去墓地时。
function c7602840.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 定义过滤条件：攻击力1500以下的机械族怪兽，且能以表侧攻击表示特殊召唤。
function c7602840.filter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 定义效果发动目标：检查己方场上是否有空怪兽位，以及卡组中是否存在满足条件的怪兽。
function c7602840.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽。
		and Duel.IsExistingMatchingCard(c7602840.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果处理：从卡组选择1只满足条件的怪兽表侧攻击表示特殊召唤。
function c7602840.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c7602840.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到己方场上（特殊召唤成功后，系统会自动洗切卡组）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
