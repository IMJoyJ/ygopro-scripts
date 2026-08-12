--フィッシュボーグ－ガンナー
-- 效果：
-- 自己场上有3星以下的水属性怪兽表侧表示存在的场合，丢弃1张手卡才能发动。墓地存在的这张卡在自己场上特殊召唤。把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是水属性怪兽。
function c93369354.initial_effect(c)
	-- 自己场上有3星以下的水属性怪兽表侧表示存在的场合，丢弃1张手卡才能发动。墓地存在的这张卡在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93369354,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(c93369354.spcon)
	e1:SetCost(c93369354.spcost)
	e1:SetTarget(c93369354.sptg)
	e1:SetOperation(c93369354.spop)
	c:RegisterEffect(e1)
	-- 把这张卡作为同调素材的场合，其他的同调素材怪兽必须全部是水属性怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TUNER_MATERIAL_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetTarget(c93369354.synlimit)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的3星以下的水属性怪兽
function c93369354.filter(c)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 特殊召唤效果的发动条件：检查自己场上是否存在满足过滤条件的怪兽
function c93369354.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件的卡
	return Duel.IsExistingMatchingCard(c93369354.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动代价：丢弃1张手卡
function c93369354.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤效果的目标处理：检查怪兽区域空位及自身是否能特殊召唤，并设置操作信息
function c93369354.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的效果处理：将墓地的这张卡特殊召唤
function c93369354.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 同调素材限制：其他的同调素材怪兽必须是水属性
function c93369354.synlimit(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
