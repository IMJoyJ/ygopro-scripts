--極星獣タングニョースト
-- 效果：
-- 自己场上存在的怪兽被战斗破坏送去墓地时，这张卡可以从手卡特殊召唤。1回合1次，场上守备表示存在的这张卡变成表侧攻击表示时，可以从自己卡组把「极星兽 坦格乔斯特」以外的1只名字带有「极星兽」的怪兽表侧守备表示特殊召唤。
function c14677495.initial_effect(c)
	-- 效果原文：自己场上存在的怪兽被战斗破坏送去墓地时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14677495,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c14677495.spcon1)
	e1:SetTarget(c14677495.sptg1)
	e1:SetOperation(c14677495.spop1)
	c:RegisterEffect(e1)
	-- 效果原文：1回合1次，场上守备表示存在的这张卡变成表侧攻击表示时，可以从自己卡组把「极星兽 坦格乔斯特」以外的1只名字带有「极星兽」的怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14677495,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCountLimit(1)
	e2:SetCondition(c14677495.spcon2)
	e2:SetTarget(c14677495.sptg2)
	e2:SetOperation(c14677495.spop2)
	c:RegisterEffect(e2)
end
-- 规则层面：用于过滤被战斗破坏且在自己场上的怪兽
function c14677495.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 规则层面：判断是否有满足条件的怪兽被战斗破坏
function c14677495.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14677495.cfilter,1,nil,tp)
end
-- 规则层面：设置特殊召唤的处理目标
function c14677495.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面：设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c14677495.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：将此卡从手卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 规则层面：判断此卡是否为攻击表示且之前为守备表示
function c14677495.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos() and e:GetHandler():IsPreviousPosition(POS_DEFENSE)
end
-- 规则层面：用于过滤卡组中名字带有「极星兽」且不是此卡的怪兽
function c14677495.filter(c,e,tp)
	return c:IsSetCard(0x6042) and not c:IsCode(14677495) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面：设置第二效果的处理目标
function c14677495.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查是否满足第二效果的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面：检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c14677495.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面：设置连锁操作信息，表示将要从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面：执行第二效果的处理操作
function c14677495.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面：提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 规则层面：从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14677495.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面：将选中的怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
