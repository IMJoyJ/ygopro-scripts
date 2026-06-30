--転生炎獣ミーア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用通常抽卡以外的方法加入手卡的场合，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：从手卡把这张卡以外的1张「转生炎兽」卡丢弃才能发动。这张卡从手卡特殊召唤。
function c67225377.initial_effect(c)
	-- ①：这张卡用通常抽卡以外的方法加入手卡的场合，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67225377,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,67225377)
	e1:SetCondition(c67225377.spcon)
	e1:SetCost(c67225377.spcost1)
	e1:SetTarget(c67225377.sptg1)
	e1:SetOperation(c67225377.spop1)
	c:RegisterEffect(e1)
	-- ②：从手卡把这张卡以外的1张「转生炎兽」卡丢弃才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67225377,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,67225378)
	e2:SetCost(c67225377.spcost2)
	e2:SetTarget(c67225377.sptg2)
	e2:SetOperation(c67225377.spop2)
	c:RegisterEffect(e2)
end
-- 判定加入手牌的原因是否非规则抽卡（用于判定“用通常抽卡以外的方法加入手卡”的条件）
function c67225377.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_RULE
end
-- 检测自身是否处于未公开状态（用于发动时代价的“把这张卡给对方观看”的操作）
function c67225377.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 效果①（特殊召唤自身）的发动检测与效果分类设置
function c67225377.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动准备阶段检测己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①（特殊召唤自身）的效果处理函数
function c67225377.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤手牌中除了自身以外的「转生炎兽」卡片
function c67225377.cfilter(c)
	return c:IsSetCard(0x119) and c:IsDiscardable()
end
-- 效果②的发动代价：从手牌将这张卡以外的1张「转生炎兽」卡丢弃
function c67225377.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测手牌中是否存在其他可用于丢弃的「转生炎兽」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c67225377.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌中选择并丢弃1张「转生炎兽」卡片作为发动代价
	Duel.DiscardHand(tp,c67225377.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 效果②（特殊召唤自身）的发动检测与效果分类设置
function c67225377.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段检测己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②（特殊召唤自身）的效果处理函数
function c67225377.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡表侧表示特殊召唤到己方场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
