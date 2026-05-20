--サテライト・シンクロン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
-- ②：原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽在自己的场上或墓地存在的场合才能发动。这张卡的等级直到回合结束时变成4星。
function c57458399.initial_effect(c)
	-- ①：从自己墓地有怪兽特殊召唤的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57458399,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,57458399)
	e1:SetCondition(c57458399.spcon)
	e1:SetTarget(c57458399.sptg)
	e1:SetOperation(c57458399.spop)
	c:RegisterEffect(e1)
	-- ②：原本卡名包含「战士」、「同调士」、「星尘」之内任意种的同调怪兽在自己的场上或墓地存在的场合才能发动。这张卡的等级直到回合结束时变成4星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57458399,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,57458400)
	e2:SetCondition(c57458399.lvcon)
	e2:SetTarget(c57458399.lvtg)
	e2:SetOperation(c57458399.lvop)
	c:RegisterEffect(e2)
end
-- 过滤从自己墓地特殊召唤的怪兽
function c57458399.spfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
end
-- 检查是否有怪兽从自己墓地特殊召唤，作为效果①的发动条件
function c57458399.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c57458399.spfilter,1,nil,tp)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息）
function c57458399.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张卡（自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若此卡仍在手卡，则将其特殊召唤
function c57458399.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示或墓地中，原本卡名包含「战士」、「同调士」或「星尘」的同调怪兽
function c57458399.lvfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsOriginalSetCard(0x66,0x1017,0xa3) and c:IsType(TYPE_SYNCHRO)
end
-- 检查自己场上或墓地是否存在满足条件的同调怪兽，作为效果②的发动条件
function c57458399.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（表侧表示）或墓地是否存在至少1张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c57458399.lvfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
end
-- 效果②的发动准备与合法性检测（检查自身等级是否大于等于1且不等于4）
function c57458399.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLevelAbove(1) and not c:IsLevel(4) end
end
-- 效果②的处理：若此卡在场上表侧表示存在，则将其等级直到回合结束时变成4星
function c57458399.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级直到回合结束时变成4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
