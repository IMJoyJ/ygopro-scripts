--骸の魔妖－夜叉
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把这张卡以外的1只「魔妖」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
function c77714963.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡把这张卡以外的1只「魔妖」怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77714963,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,77714963)
	e1:SetCost(c77714963.spcost)
	e1:SetTarget(c77714963.sptg)
	e1:SetOperation(c77714963.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己不是「魔妖」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c77714963.sslimit)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的「魔妖」怪兽且可以丢弃
function c77714963.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x121) and c:IsDiscardable()
end
-- ①效果的代价值：从手卡将这张卡以外的一只「魔妖」怪兽丢弃
function c77714963.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查手卡中是否存在除这张卡以外的「魔妖」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77714963.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡选择1张除这张卡以外的「魔妖」怪兽丢弃送去墓地
	Duel.DiscardHand(tp,c77714963.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果的发动准备：检查怪兽区域空位以及自身是否可以特殊召唤
function c77714963.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段（chk==0）检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的效果处理：将手卡的这张卡特殊召唤
function c77714963.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制条件：从额外卡组特殊召唤的怪兽必须是「魔妖」怪兽
function c77714963.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x121)
end
