--星遺物の守護竜メロダーク
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把2只通常怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的龙族怪兽数量×500。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己墓地选和这张卡是原本的种族·属性不同的1只9星怪兽加入手卡。
function c35183584.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：从自己的手卡·墓地把2只通常怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35183584,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,35183584)
	e1:SetCost(c35183584.spcost)
	e1:SetTarget(c35183584.sptg)
	e1:SetOperation(c35183584.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的龙族怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c35183584.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己墓地选和这张卡是原本的种族·属性不同的1只9星怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(35183584,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,35183585)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c35183584.thcon)
	e4:SetTarget(c35183584.thtg)
	e4:SetOperation(c35183584.thop)
	c:RegisterEffect(e4)
end
-- 定义①效果代价的筛选函数：该卡必须是通常怪兽，并且可以作为代价从手卡·墓地除外。
function c35183584.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：先确认手卡·墓地存在至少2只符合条件的通常怪兽，再让玩家选择2只，以表侧表示除外作为发动代价。
function c35183584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查自己的手卡·墓地是否存在至少2只满足cfilter条件的通常怪兽，作为①效果能否发动的代价条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c35183584.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	-- 向玩家显示“请选择要除外的卡”的提示，用于后续选择代价的交互。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的手卡·墓地精确选择2张符合cfilter条件的通常怪兽，作为①效果发动要除外的代价。
	local g=Duel.SelectMatchingCard(tp,c35183584.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的2张通常怪兽以表侧表示除外，代价原因记为REASON_COST，完成①效果的cost支付。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义①效果的发动目标判定函数：在chk==0时，确认自己主要怪兽区有空位，且这张卡自身可以被特殊召唤，只有满足这些条件才能发动。
function c35183584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区空格，用于判断这张卡能否通过①效果特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置①效果处理时含特殊召唤的操作信息：将这张卡特殊召唤，数量为1，目标玩家为发动者。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理的最终操作：先确认这张卡仍未与效果失去联系，然后将其以表侧表示特殊召唤到自己场上。
function c35183584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以表侧表示将这张卡特殊召唤到自己场上，召唤类型为0（普通效果特殊召唤），不检查召唤条件与苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义②效果下降数值的统计过滤器：筛选自己场上表侧表示且种族为龙的怪兽。
function c35183584.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- ②效果的数值计算函数：统计自己场上表侧表示龙族怪兽的数量，乘以-500作为攻守下降值；该函数同时供攻击力下降效果和守备力下降效果使用。
function c35183584.atkval(e,c)
	-- 获取自己场上表侧表示龙族怪兽的数量，并乘以-500，返回负值表示对方场上怪兽攻击力/守备力下降的数值。
	return Duel.GetMatchingGroupCount(c35183584.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-500
end
-- ③效果的发动条件：这张卡被战斗或效果破坏，且破坏前存在于场上时，才能发动。
function c35183584.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- ③效果检索墓地卡的筛选函数：该卡必须是9星怪兽卡、能够加入手牌，并且其种族和属性均与这张卡原本的种族·属性不同。
function c35183584.thfilter(c,ec)
	return c:IsLevel(9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and not c:IsRace(ec:GetRace()) and not c:IsAttribute(ec:GetAttribute())
end
-- ③效果的发动目标判定：墓地存在至少1只符合thfilter条件的9星怪兽，并设置后续回手牌及离开墓地的操作信息。
function c35183584.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在③效果发动时检查自己墓地是否存在至少1只符合条件的9星怪兽（等级9、可加入手牌、原本种族/属性与本卡不同），作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c35183584.thfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 设置③效果处理后“加入手卡”的操作信息：预计从墓地选1张卡加入手牌，持卡者为发动者tp。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置③效果处理中涉及“从墓地离开”的操作信息，用于与王家长眠之谷等墓地相关效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理时的操作：从自己墓地选择1只符合条件的9星怪兽，将其加入手卡。
function c35183584.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要加入手牌的卡”的提示，用于选择回手牌的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只符合thfilter条件的9星怪兽，作为③效果加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c35183584.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的怪兽加入其持有者的手卡（player为nil表示返回持有者手卡），处理原因记为REASON_EFFECT。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
