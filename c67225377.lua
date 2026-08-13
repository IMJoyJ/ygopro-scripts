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
-- ①效果的发动条件：这张卡不是因为规则（通常抽卡）而加入手卡的场合才能发动
function c67225377.spcon(e,tp,eg,ep,ev,re,r,rp)
	return r~=REASON_RULE
end
-- ①效果的代价检查：确认这张卡尚未向对方公开，以便发动时给对方观看
function c67225377.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的目标检查：确认自己主要怪兽区有空位，且这张卡可以被特殊召唤
function c67225377.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣言效果处理时将把这张卡1只特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若这张卡仍与该效果关联，则将这张卡从手卡以正面表示特殊召唤到自己场上
function c67225377.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以正面表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 丢弃代价的过滤函数：筛选「转生炎兽」系列且可以被丢弃的卡
function c67225377.cfilter(c)
	return c:IsSetCard(0x119) and c:IsDiscardable()
end
-- ②效果的代价：确认手卡存在这张卡以外可被丢弃的「转生炎兽」卡，并让玩家选择其中1张作为代价丢弃
function c67225377.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在至少1张这张卡以外可被丢弃的「转生炎兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67225377.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家从手卡选择1张这张卡以外的「转生炎兽」卡作为代价丢弃
	Duel.DiscardHand(tp,c67225377.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ②效果的目标检查：确认自己主要怪兽区有空位，且这张卡可以被特殊召唤
function c67225377.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：宣言效果处理时将把这张卡1只特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②效果的处理：若这张卡仍与该效果关联，则将这张卡从手卡以正面表示特殊召唤到自己场上
function c67225377.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡以正面表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
