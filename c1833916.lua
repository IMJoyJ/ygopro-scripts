--H・C サウザンド・ブレード
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，从手卡丢弃1张「英豪」卡才能发动。从卡组把1只「英豪」怪兽特殊召唤，这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。
-- ②：这张卡在墓地存在，战斗·效果让自己受到伤害时才能发动。这张卡攻击表示特殊召唤。
function c1833916.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1张「英豪」卡才能发动。从卡组把1只「英豪」怪兽特殊召唤，这张卡变成守备表示。这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1833916,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c1833916.spcon)
	e1:SetCost(c1833916.spcost)
	e1:SetTarget(c1833916.sptg)
	e1:SetOperation(c1833916.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，战斗·效果让自己受到伤害时才能发动。这张卡攻击表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1833916,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,1833916)
	e2:SetCondition(c1833916.spcon2)
	e2:SetTarget(c1833916.sptg2)
	e2:SetOperation(c1833916.spop2)
	c:RegisterEffect(e2)
end
-- ①的发动条件之一：这张卡必须在自己场上以攻击表示存在。
function c1833916.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 过滤可作为代价丢弃的「英豪」卡：手卡中的「英豪」卡且可以丢弃。
function c1833916.cfilter(c)
	return c:IsSetCard(0x6f) and c:IsDiscardable()
end
-- ①的代价处理：从手卡选择并丢弃1张「英豪」卡作为发动代价，丢弃原因同时为代价和丢弃。
function c1833916.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认手卡中是否存在至少1张可作为代价丢弃的「英豪」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c1833916.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行代价：从手卡选择1张「英豪」卡，以代价+丢弃的理由送去墓地。
	Duel.DiscardHand(tp,c1833916.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤对象过滤：卡组中的「英豪」怪兽，且能够被本次效果特殊召唤。
function c1833916.filter(c,e,tp)
	return c:IsSetCard(0x6f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①的发动目标合法性检查：自己场上有可用怪兽区，且卡组中存在可以特殊召唤的「英豪」怪兽。
function c1833916.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有可用的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「英豪」怪兽。
		and Duel.IsExistingMatchingCard(c1833916.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：预登记本次效果会从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：场上仍有空位时，从卡组选1只「英豪」怪兽表侧表示特殊召唤；若这张卡仍与效果关联，则将其变成表侧守备表示，并在结束阶段前给自己附加不能特殊召唤非「英豪」怪兽的自肃。
function c1833916.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己场上仍有可用怪兽区才进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只符合条件的「英豪」怪兽。
		local g=Duel.SelectMatchingCard(tp,c1833916.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选出的「英豪」怪兽特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			if c:IsRelateToEffect(e) then
				-- 将发动效果的这张卡变成表侧守备表示。
				Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是「英豪」怪兽不能特殊召唤。②：这张卡在墓地存在，战斗·效果让自己受到伤害时才能发动。这张卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c1833916.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能特殊召唤非「英豪」怪兽的自肃效果注册到场上，只影响当前玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的条件：只有不是「英豪」的怪兽才会被禁止特殊召唤。
function c1833916.splimit(e,c)
	return not c:IsSetCard(0x6f)
end
-- ②的发动条件：自己受到战斗或效果伤害（伤害对象是这张卡的持有者/控制者方）。
function c1833916.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- ②的发动可行条件：自己场上有可用怪兽区，且墓地的这张卡可以表侧攻击表示特殊召唤。
function c1833916.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置操作信息：本次效果将把墓地的这张卡以攻击表示特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的效果处理：若这张卡仍与效果关联，则将其从墓地特殊召唤到自己场上。
function c1833916.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
