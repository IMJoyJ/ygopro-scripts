--星遺物の守護竜メロダーク
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把2只通常怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降自己场上的龙族怪兽数量×500。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己墓地选和这张卡是原本的种族·属性不同的1只9星怪兽加入手卡。
function c35183584.initial_effect(c)
	-- ①：从自己的手卡·墓地把2只通常怪兽除外才能发动。这张卡从手卡特殊召唤。
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
-- 过滤函数，用于判断手卡或墓地的通常怪兽是否可以作为除外的代价
function c35183584.cfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemoveAsCost()
end
-- 效果处理时检查是否满足除外2只通常怪兽的条件，并选择除外这些怪兽
function c35183584.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地是否存在至少2只通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35183584.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡作为除外对象
	local g=Duel.SelectMatchingCard(tp,c35183584.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的卡以除外形式移除
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 判断特殊召唤的条件是否满足
function c35183584.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c35183584.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，用于判断场上正面表示的龙族怪兽
function c35183584.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 计算攻击力下降值，为场上龙族怪兽数量乘以500
function c35183584.atkval(e,c)
	-- 获取场上正面表示的龙族怪兽数量并乘以-500作为攻击力下降值
	return Duel.GetMatchingGroupCount(c35183584.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)*-500
end
-- 判断此卡被破坏时是否满足发动条件
function c35183584.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于判断墓地中的9星怪兽是否满足加入手牌的条件
function c35183584.thfilter(c,ec)
	return c:IsLevel(9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and not c:IsRace(ec:GetRace()) and not c:IsAttribute(ec:GetAttribute())
end
-- 设置发动效果时的处理信息，包括选择目标和处理对象
function c35183584.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查墓地是否存在满足条件的9星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35183584.thfilter,tp,LOCATION_GRAVE,0,1,nil,e:GetHandler()) end
	-- 设置将怪兽加入手牌的处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	-- 设置怪兽离开墓地的处理信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- 执行效果处理，选择并加入手牌
function c35183584.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c35183584.thfilter,tp,LOCATION_GRAVE,0,1,1,nil,e:GetHandler())
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
