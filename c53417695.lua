--破械唱導
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「破械」怪兽和场上1张卡为对象才能发动。那2张卡破坏。
-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
function c53417695.initial_effect(c)
	-- ①：以自己场上1只「破械」怪兽和场上1张卡为对象才能发动。那2张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53417695,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,53417695)
	e1:SetTarget(c53417695.target)
	e1:SetOperation(c53417695.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被效果破坏的场合才能发动。从卡组把1只「破械」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53417695,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,53417696)
	e2:SetCondition(c53417695.spcon)
	e2:SetTarget(c53417695.sptg)
	e2:SetOperation(c53417695.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否满足破坏效果的对象条件（场上「破械」怪兽且能选择对象）
function c53417695.desfilter(c,tp,ec)
	return c:IsFaceup() and c:IsSetCard(0x130)
		-- 检查是否存在满足条件的对象卡片（即场上的任意一张卡）
		and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 处理效果的发动选择阶段，选择破坏对象
function c53417695.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查是否满足发动条件（场上存在符合条件的「破械」怪兽）
	if chk==0 then return Duel.IsExistingTarget(c53417695.desfilter,tp,LOCATION_MZONE,0,1,nil,tp,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的「破械」怪兽作为第一个目标
	local g1=Duel.SelectTarget(tp,c53417695.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp,c)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的任意一张卡作为第二个目标
	local g2=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,Group.FromCards(g1:GetFirst(),c))
	g1:Merge(g2)
	-- 设置操作信息，确定将要破坏的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
end
-- 处理效果发动后的破坏操作
function c53417695.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被指定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 执行破坏操作，将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断是否满足特殊召唤条件（被效果破坏且盖放状态）
function c53417695.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤函数，用于选择可以特殊召唤的「破械」怪兽
function c53417695.spfilter(c,e,tp)
	return c:IsSetCard(0x130) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 处理特殊召唤效果的发动选择阶段
function c53417695.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「破械」怪兽
		and Duel.IsExistingMatchingCard(c53417695.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果的发动后操作
function c53417695.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的「破械」怪兽
	local g=Duel.SelectMatchingCard(tp,c53417695.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤操作，将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
