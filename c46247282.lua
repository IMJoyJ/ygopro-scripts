--鉄騎龍ティアマトン
-- 效果：
-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：3张以上的卡在相同纵列存在的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
-- ②：这张卡特殊召唤成功的场合发动。和这张卡相同纵列的其他卡全部破坏。
-- ③：只要这张卡在怪兽区域存在，和这张卡相同纵列的没有使用的区域不能使用。
function c46247282.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：3张以上的卡在相同纵列存在的场合才能发动。这张卡从手卡特殊召唤。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合发动。和这张卡相同纵列的其他卡全部破坏。
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
	-- ③：只要这张卡在怪兽区域存在，和这张卡相同纵列的没有使用的区域不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46247282,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c46247282.destg)
	e3:SetOperation(c46247282.desop)
	c:RegisterEffect(e3)
	-- 这张卡不能通常召唤，用这张卡的①的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_DISABLE_FIELD)
	e4:SetValue(c46247282.disval)
	c:RegisterEffect(e4)
end
-- 检查场上是否存在至少2张以上在同一纵列的卡
function c46247282.cfilter(c)
	return c:GetColumnGroupCount()>1
end
-- 判断是否满足①效果的发动条件：场上有3张或以上卡在同一纵列
function c46247282.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 场上有3张或以上卡在同一纵列
	return Duel.IsExistingMatchingCard(c46247282.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 设置特殊召唤的发动条件和目标
function c46247282.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,true) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c46247282.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡可以被特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,true,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 用于筛选与当前卡在同一纵列的卡
function c46247282.desfilter(c,g)
	return g:IsContains(c)
end
-- 设置破坏效果的目标和操作信息
function c46247282.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local cg=e:GetHandler():GetColumnGroup()
	-- 获取所有与当前卡在同一纵列的场上卡
	local g=Duel.GetMatchingGroup(c46247282.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,cg)
	-- 设置操作信息，表示将要破坏这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏操作
function c46247282.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cg=c:GetColumnGroup()
	if c:IsRelateToEffect(e) then
		-- 获取所有与当前卡在同一纵列的场上卡
		local g=Duel.GetMatchingGroup(c46247282.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,cg)
		if g:GetCount()>0 then
			-- 将这些卡全部破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
-- 返回当前卡所在纵列的所有可用区域
function c46247282.disval(e)
	local c=e:GetHandler()
	return c:GetColumnZone(LOCATION_ONFIELD,0)
end
