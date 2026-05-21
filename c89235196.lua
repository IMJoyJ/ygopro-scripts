--ビッグ・ワン・ウォリアー
-- 效果：
-- 自己的主要阶段时，把这张卡以外的手卡1只1星怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c89235196.initial_effect(c)
	-- 自己的主要阶段时，把这张卡以外的手卡1只1星怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89235196,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c89235196.spcost)
	e1:SetTarget(c89235196.sptg)
	e1:SetOperation(c89235196.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：等级为1且能作为代价送去墓地的卡
function c89235196.cfilter(c)
	return c:IsLevel(1) and c:IsAbleToGraveAsCost()
end
-- 发动代价：把这张卡以外的手卡1只1星怪兽送去墓地
function c89235196.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的1只1星怪兽可以作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c89235196.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡中除这张卡以外的1只满足条件的1星怪兽
	local g=Duel.SelectMatchingCard(tp,c89235196.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标检查与操作信息设置
function c89235196.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身是否可以特殊召唤，且场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将手牌中的这张卡特殊召唤
function c89235196.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
