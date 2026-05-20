--竜の尖兵
-- 效果：
-- ①：从手卡把1只龙族怪兽送去墓地才能发动。这张卡的攻击力上升300。
-- ②：场上的这张卡被对方的效果送去墓地时，以自己或者对方的墓地1只龙族通常怪兽为对象才能发动。那只龙族怪兽特殊召唤。
function c77135531.initial_effect(c)
	-- ①：从手卡把1只龙族怪兽送去墓地才能发动。这张卡的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77135531,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c77135531.cost)
	e1:SetOperation(c77135531.atkop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被对方的效果送去墓地时，以自己或者对方的墓地1只龙族通常怪兽为对象才能发动。那只龙族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77135531,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c77135531.spcon)
	e2:SetTarget(c77135531.sptg)
	e2:SetOperation(c77135531.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为发动代价送去墓地的龙族怪兽
function c77135531.cfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToGraveAsCost()
end
-- ①号效果的代价：从手卡把1只龙族怪兽送去墓地
function c77135531.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只满足条件的龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77135531.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1只龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c77135531.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①号效果的处理：使这张卡的攻击力上升300
function c77135531.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 检查是否满足②号效果的发动条件：场上的这张卡被对方的效果送去墓地
function c77135531.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤自己或对方墓地中可以特殊召唤的龙族通常怪兽
function c77135531.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备（检查怪兽区域空位、墓地中是否存在合法的龙族通常怪兽，并选择对象）
function c77135531.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c77135531.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己或对方的墓地中是否存在至少1只龙族通常怪兽
		and Duel.IsExistingTarget(c77135531.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己或对方墓地中1只龙族通常怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77135531.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选中的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的处理：将作为对象的龙族通常怪兽特殊召唤
function c77135531.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
