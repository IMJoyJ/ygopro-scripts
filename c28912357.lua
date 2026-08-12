--ギアギガント X
-- 效果：
-- 机械族4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以下的机械族怪兽加入手卡。
-- ②：表侧表示的这张卡从场上离开时，以自己墓地1只3星以下的「齿轮齿轮」怪兽为对象才能发动。那只怪兽特殊召唤。
function c28912357.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，要求使用满足种族为机械的4星怪兽作为2个叠放素材
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从自己的卡组·墓地选1只4星以下的机械族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(28912357,0))  --"加入手卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28912357.cost)
	e1:SetTarget(c28912357.target)
	e1:SetOperation(c28912357.operation)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡从场上离开时，以自己墓地1只3星以下的「齿轮齿轮」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28912357,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c28912357.spcon)
	e2:SetTarget(c28912357.sptg)
	e2:SetOperation(c28912357.spop)
	c:RegisterEffect(e2)
end
-- 效果发动时，检查是否能从场上移除1个超量素材作为费用
function c28912357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足等级不超过4星、种族为机械且能加入手牌的怪兽
function c28912357.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果发动时，检查场上是否存在满足条件的怪兽
function c28912357.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c28912357.filter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理时，提示玩家选择要加入手牌的卡，并将卡加入手牌
function c28912357.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28912357.filter),tp,LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果发动时，检查该卡是否从场上离开且处于表侧表示
function c28912357.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足等级不超过3星、卡包为齿轮齿轮且能特殊召唤的怪兽
function c28912357.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsSetCard(0x72) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时，检查是否能选择满足条件的墓地怪兽作为对象
function c28912357.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28912357.spfilter(chkc,e,tp) end
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的墓地怪兽
		and Duel.IsExistingTarget(c28912357.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为对象
	local g=Duel.SelectTarget(tp,c28912357.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时，将选中的怪兽特殊召唤
function c28912357.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
