--極星獣タングニョースト
-- 效果：
-- 自己场上存在的怪兽被战斗破坏送去墓地时，这张卡可以从手卡特殊召唤。1回合1次，场上守备表示存在的这张卡变成表侧攻击表示时，可以从自己卡组把「极星兽 坦格乔斯特」以外的1只名字带有「极星兽」的怪兽表侧守备表示特殊召唤。
function c14677495.initial_effect(c)
	-- 自己场上存在的怪兽被战斗破坏送去墓地时，这张卡可以从手卡特殊召唤。
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
	-- 1回合1次，场上守备表示存在的这张卡变成表侧攻击表示时，可以从自己卡组把「极星兽 坦格乔斯特」以外的1只名字带有「极星兽」的怪兽表侧守备表示特殊召唤。
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
-- 筛选出因为战斗被破坏并送去墓地、且上一个控制者是己方玩家的怪兽，作为触发条件的事件对象。
function c14677495.cfilter(c,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsPreviousControler(tp)
end
-- 发动条件：本次被战斗破坏送去墓地的怪兽中存在至少1只满足cfilter筛选条件的己方怪兽。
function c14677495.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14677495.cfilter,1,nil,tp)
end
-- 发动时的合法性检查：己方主要怪兽区有空位，且这张卡在手牌中可以被特殊召唤。
function c14677495.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上可用的主要怪兽区数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：将这张卡本身作为本次特殊召唤的处理对象，用于后续连锁/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：获取效果所属的这张卡，若这张卡仍与效果关联（没有离场或失效），则将其特殊召唤。
function c14677495.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到其持有者（己方）的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 特殊召唤触发条件：这张卡当前为攻击表示，且在表示形式变更之前为守备表示，即从表侧守备表示变为了表侧攻击表示。
function c14677495.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos() and e:GetHandler():IsPreviousPosition(POS_DEFENSE)
end
-- 筛选卡组中满足条件的卡片：卡名带有「极星兽」字段、不是「极星兽 坦格乔斯特」自身、并且可以以表侧守备表示特殊召唤。
function c14677495.filter(c,e,tp)
	return c:IsSetCard(0x6042) and not c:IsCode(14677495) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动时的合法性检查：己方主要怪兽区有空位，且卡组中存在至少1张满足filter筛选条件的怪兽。
function c14677495.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上可用的主要怪兽区数量是否大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足filter筛选条件的卡片。
		and Duel.IsExistingMatchingCard(c14677495.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记操作信息：本次特殊召唤的处理对象来自卡组，预计处理数量为1，持有者为己方。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若己方主要怪兽区有空位，则提示玩家选择要特殊召唤的卡，从卡组选出1张满足条件的怪兽，并以其表侧守备表示特殊召唤到己方场上。
function c14677495.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有可用空位，则无法进行特殊召唤，直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选出1张满足filter条件的卡，作为要特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c14677495.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的卡以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
