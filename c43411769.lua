--守護竜ガルミデス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：通常怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在墓地存在的场合，从手卡把1只龙族怪兽送去墓地才能发动。这张卡加入手卡。
function c43411769.initial_effect(c)
	-- ①：通常怪兽被送去自己墓地的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43411769,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,43411769)
	e1:SetCondition(c43411769.spcon)
	e1:SetTarget(c43411769.sptg)
	e1:SetOperation(c43411769.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，从手卡把1只龙族怪兽送去墓地才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43411769,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,43411770)
	e2:SetCost(c43411769.thcost)
	e2:SetTarget(c43411769.thtg)
	e2:SetOperation(c43411769.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断一张卡是否为通常怪兽，且其控制者为发动玩家tp，用于确定“通常怪兽被送去自己墓地”事件中的被送去墓地的卡。
function c43411769.cfilter(c,tp)
	return c:IsType(TYPE_NORMAL) and c:IsControler(tp)
end
-- 发动条件：本组被送去墓地的卡eg中，存在至少1张满足cfilter（即自己场上的通常怪兽）的卡。
function c43411769.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43411769.cfilter,1,nil,tp)
end
-- 发动目标条件的检查：自己场上主要怪兽区有空位，且手卡的这张卡自身可以被特殊召唤，满足才可发动。
function c43411769.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区是否有空位可用，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理将把这张卡特殊召唤，数量为1，用于给其他效果（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理①效果：以效果持有者这张卡为对象，若它仍在手牌且与效果关联，则将其表侧攻击表示特殊召唤到自己场上。
function c43411769.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动玩家tp的场上，参数false表示需要检查召唤条件和苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- cost筛选函数：判断一张卡是否为龙族怪兽，且可以作为代价送去墓地，用于②效果从手卡丢弃龙族怪兽的cost。
function c43411769.costfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- ②效果的发动cost处理：先验证手卡存在可丢弃的龙族怪兽，然后提示玩家选择1张手卡龙族怪兽，将其作为cost送去墓地。
function c43411769.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost支付检查：手卡中是否存在至少1张满足costfilter的龙族怪兽，作为cost能否支付的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c43411769.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向玩家显示选择提示信息，提示内容为“请选择要送去墓地的卡”，为接下来的卡片选择作准备。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让发动玩家tp从手卡选择1张满足costfilter条件的龙族怪兽，结果为选中的卡片组g。
	local g=Duel.SelectMatchingCard(tp,c43411769.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的龙族怪兽以代价（REASON_COST）送去墓地，完成cost支付。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果的目标检查与操作信息设置：若墓地的这张卡可以加入手卡，则设置效果处理时将其回手的操作信息。
function c43411769.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本次效果处理将把这张卡加入持有者手卡，分类为CATEGORY_TOHAND。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理②效果：获取效果持有者这张卡，若它仍与效果关联（未离开墓地），则将其加入手卡。
function c43411769.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡送去其持有者的手卡，原因是效果（REASON_EFFECT）。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
