--鉄騎龍ティアマトン
-- 效果：
-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：3张以上的卡在相同纵列存在的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡特殊召唤成功的场合发动。和这张卡相同纵列的其他卡全部破坏。
-- ③：只要这张卡在怪兽区域存在，和这张卡相同纵列的没有使用的区域不能使用。
function c46247282.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：3张以上的卡在相同纵列存在的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46247282,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,46247282)
	e2:SetCondition(c46247282.spcon)
	e2:SetTarget(c46247282.sptg)
	e2:SetOperation(c46247282.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合发动。和这张卡相同纵列的其他卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46247282,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c46247282.destg)
	e3:SetOperation(c46247282.desop)
	c:RegisterEffect(e3)
	-- ③：只要这张卡在怪兽区域存在，和这张卡相同纵列的没有使用的区域不能使用。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DISABLE_FIELD)
	e4:SetValue(c46247282.disval)
	c:RegisterEffect(e4)
end
-- 判断某卡所在纵列除自身外是否还有2张以上其他卡，即该纵列合计是否达到3张以上的卡。
function c46247282.cfilter(c)
	return c:GetColumnGroupCount()>1
end
-- ①效果的发动条件：场上（双方怪兽区·魔法陷阱区）存在至少1个满足“所在纵列有3张以上卡”的卡。
function c46247282.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足上述纵列条件的卡。
	return Duel.IsExistingMatchingCard(c46247282.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①效果的发动合法性检测：己方主要怪兽区有空位，且手牌中的这张卡能够被特殊召唤（无视召唤条件与苏生限制）。
function c46247282.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认己方主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息：本次连锁将要特殊召唤的对象是这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与该效果关联，则将其表侧表示特殊召唤到己方场上；召唤成功后完成正规召唤手续，以解除苏生限制。
function c46247282.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍可与效果关联并成功特殊召唤（返回值不为0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 筛选函数：判断卡片c是否属于同一纵列卡片组g，用于选出位于本卡同一纵列的卡。
function c46247282.desfilter(c,g)
	return g:IsContains(c)
end
-- ②效果的发动目标阶段：必发效果直接通过；获取这张卡当前同一纵列的其他卡，作为可能被破坏的卡组，并设置破坏的操作信息。
function c46247282.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetColumnGroup()
	-- 取得当前与这张卡同一纵列的其他所有卡（不包含自身）。
	local g=Duel.GetMatchingGroup(c46247282.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,cg)
	-- 设置操作信息：确定将要破坏的卡组为其数量，供连锁信息记录和后续检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则重新获取当前同一纵列的其他卡并全部破坏。
function c46247282.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) then
		-- 处理阶段重新获取这张卡当前同一纵列的其他卡。
		local g=Duel.GetMatchingGroup(c46247282.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,cg)
		if g:GetCount()>0 then
			-- 将这些卡以效果原因全部破坏。
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- ③永续效果取值：返回这张卡所在纵列的场上全部区域（怪兽区和魔法陷阱区），使这些未使用区域不能使用。
function c46247282.disval(e)
	local c=e:GetHandler()
	return c:GetColumnZone(LOCATION_ONFIELD,0)
end
