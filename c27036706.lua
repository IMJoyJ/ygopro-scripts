--ホーリーナイツ・シエル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，让「圣夜骑士团·西耶勒」以外的自己场上1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽回到持有者手卡才能发动。这张卡特殊召唤。
-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
function c27036706.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，让「圣夜骑士团·西耶勒」以外的自己场上1只「圣夜骑士」怪兽或者龙族·光属性·7星怪兽回到持有者手卡才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27036706,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,27036706)
	e1:SetCost(c27036706.spcost1)
	e1:SetTarget(c27036706.sptg1)
	e1:SetOperation(c27036706.spop1)
	c:RegisterEffect(e1)
	-- ②：自己场上没有怪兽存在的场合，把墓地的这张卡除外才能发动。从手卡把1只龙族·光属性·7星怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27036706,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27036707)
	e2:SetCondition(c27036706.spcon2)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27036706.sptg2)
	e2:SetOperation(c27036706.spop2)
	c:RegisterEffect(e2)
end
-- 满足条件的怪兽必须能回到手牌且场上存在可用怪兽区
function c27036706.cfilter(c,tp)
	-- 满足条件的怪兽必须能回到手牌且场上存在可用怪兽区
	return c:IsAbleToHandAsCost() and Duel.GetMZoneCount(tp,c)>0
		and (c:IsSetCard(0x159) and not c:IsCode(27036706) or c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT))
end
-- 选择满足条件的1只怪兽返回手牌作为此效果的cost
function c27036706.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27036706.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的1只怪兽返回手牌作为此效果的cost
	local g=Duel.SelectMatchingCard(tp,c27036706.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将所选怪兽返回手牌作为此效果的cost
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- 判断此卡是否可以特殊召唤
function c27036706.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置此效果的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行此卡的特殊召唤处理
function c27036706.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断自己场上是否没有怪兽
function c27036706.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 满足条件的怪兽必须为龙族·光属性·7星且可以特殊召唤
function c27036706.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断手牌中是否存在满足条件的怪兽且场上存在可用怪兽区
function c27036706.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在可用怪兽区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c27036706.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置此效果的处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行此卡的特殊召唤处理
function c27036706.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c27036706.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将所选怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
