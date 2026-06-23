--THE・スターハム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，丢弃1张手卡才能发动。那1只作为同调素材的怪兽从自己墓地特殊召唤。这个效果特殊召唤的怪兽当作调整使用。
-- ②：这张卡在墓地存在的场合，丢弃2张手卡才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤程序并启用复活限制，注册两个效果
function s.initial_effect(c)
	-- 为该卡添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 设置效果①，为诱发选发效果，触发条件为特殊召唤成功，可丢弃1张手卡将作为同调素材的墓地怪兽特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤素材"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 设置效果②，为起动效果，位于墓地时可丢弃2张手卡将自身特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 判断该卡是否为同调召唤成功
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 检查是否能丢弃1张手卡作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能丢弃1张手卡作为代价
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义特殊召唤过滤器，用于筛选满足条件的墓地怪兽
function s.spfilter(c,e,tp,sync)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE)
		and bit.band(c:GetReason(),0x80008)==0x80008 and c:GetReasonCard()==sync
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果①的目标，检查是否有满足条件的墓地怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	if chk==0 then return mg:GetCount()>0 and mg:FilterCount(s.spfilter,nil,e,tp,c)
		-- 检查场上是否有足够的空间
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁对象为同调素材怪兽
	Duel.SetTargetCard(mg)
	-- 设置操作信息为特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,mg,1,0,0)
end
-- 执行效果①的操作，将符合条件的墓地怪兽特殊召唤并赋予调整属性
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡片组
	local mg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=mg:Filter(Card.IsRelateToChain,nil)
	-- 检查场上是否有足够的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	-- 从符合条件的卡片中选择1张
	local sg=g:FilterSelect(tp,aux.NecroValleyFilter(s.spfilter),1,1,nil,e,tp,e:GetHandler())
	local tc=sg:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 为特殊召唤的怪兽添加调整属性
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 检查是否能丢弃2张手卡作为代价
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能丢弃2张手卡作为代价
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil) end
	-- 执行丢弃2张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
end
-- 设置效果②的目标，检查是否可以特殊召唤自身
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤自身
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果②的操作，将自身特殊召唤并设置离开场时除外
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤并满足条件
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置效果②特殊召唤后离开场时除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
