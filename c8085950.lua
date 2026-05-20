--バーニング・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，对方场上有怪兽2只以上存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1张魔法卡才能发动。场上的魔法·陷阱卡全部破坏。
function c8085950.initial_effect(c)
	-- ①：这张卡在手卡存在，对方场上有怪兽2只以上存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,8085950)
	e1:SetCondition(c8085950.spcon)
	e1:SetTarget(c8085950.sptg)
	e1:SetOperation(c8085950.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，从手卡丢弃1张魔法卡才能发动。场上的魔法·陷阱卡全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,8085951)
	e2:SetCost(c8085950.descost)
	e2:SetTarget(c8085950.destg)
	e2:SetOperation(c8085950.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 特殊召唤效果的发动条件判断
function c8085950.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否在2只以上
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
-- 特殊召唤效果的发动准备与可行性检测
function c8085950.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的执行函数
function c8085950.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手卡中可以丢弃的魔法卡
function c8085950.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 破坏效果的发动代价处理函数
function c8085950.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8085950.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张魔法卡作为发动代价
	Duel.DiscardHand(tp,c8085950.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上的魔法·陷阱卡
function c8085950.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的发动准备与可行性检测
function c8085950.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c8085950.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c8085950.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置当前连锁的操作信息为破坏场上所有的魔法·陷阱卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c8085950.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c8085950.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 破坏获取到的魔法·陷阱卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
