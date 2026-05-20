--泣き神の石像
-- 效果：
-- 把自己墓地存在的1只调整从游戏中除外发动。这张卡从手卡特殊召唤。
function c5763020.initial_effect(c)
	-- 把自己墓地存在的1只调整从游戏中除外发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5763020,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c5763020.spcost)
	e1:SetTarget(c5763020.sptg)
	e1:SetOperation(c5763020.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中可以作为代价除外的调整怪兽
function c5763020.costfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的发动代价：将自己墓地的一只调整怪兽除外
function c5763020.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己墓地是否存在至少1只满足过滤条件的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5763020.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足过滤条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c5763020.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽表侧表示除外，作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的目标检查：检查自身是否可以特殊召唤，以及怪兽区域是否有空位
function c5763020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若此卡仍存在于手牌中，则将其特殊召唤
function c5763020.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
