--マリスボラス・フォーク
-- 效果：
-- 自己的主要阶段时，从手卡把这张卡以外的1只恶魔族怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
function c61791132.initial_effect(c)
	-- 自己的主要阶段时，从手卡把这张卡以外的1只恶魔族怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(61791132,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c61791132.spcost)
	e1:SetTarget(c61791132.sptg)
	e1:SetOperation(c61791132.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡中除自身以外的恶魔族怪兽，且能作为发动代价送去墓地
function c61791132.cfilter(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost()
end
-- 发动代价：从手卡把这张卡以外的1只恶魔族怪兽送去墓地
function c61791132.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的恶魔族怪兽可以作为代价送去墓地
	if chk==0 then return Duel.IsExistingMatchingCard(c61791132.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1张除自身以外的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c61791132.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选中的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标：检查自身是否可以特殊召唤，且怪兽区域有空位
function c61791132.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身从手卡特殊召唤
function c61791132.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
