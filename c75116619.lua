--真六武衆－エニシ
-- 效果：
-- 自己场上有「真六武众-缘」以外的名字带有「六武众」的怪兽表侧表示存在的场合，1回合1次，可以把自己墓地存在的2只名字带有「六武众」的怪兽从游戏中除外，选择场上表侧表示存在的1只怪兽回到手卡。这个效果在对方回合也能发动。此外，自己场上有「真六武众-缘」以外的名字带有「六武众」的怪兽表侧表示2只以上存在的场合，这张卡的攻击力·守备力上升500。
function c75116619.initial_effect(c)
	-- 自己场上有「真六武众-缘」以外的名字带有「六武众」的怪兽表侧表示存在的场合，1回合1次，可以把自己墓地存在的2只名字带有「六武众」的怪兽从游戏中除外，选择场上表侧表示存在的1只怪兽回到手卡。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75116619,0))  --"返回手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(c75116619.thcon)
	e1:SetCost(c75116619.thcost)
	e1:SetTarget(c75116619.thtg)
	e1:SetOperation(c75116619.thop)
	c:RegisterEffect(e1)
	-- 此外，自己场上有「真六武众-缘」以外的名字带有「六武众」的怪兽表侧表示2只以上存在的场合，这张卡的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c75116619.valcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「真六武众-缘」以外的「六武众」怪兽
function c75116619.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(75116619)
end
-- 发动条件：自己场上存在「真六武众-缘」以外的「六武众」怪兽
function c75116619.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只「真六武众-缘」以外的表侧表示「六武众」怪兽
	return Duel.IsExistingMatchingCard(c75116619.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中可以作为代价除外的「六武众」怪兽
function c75116619.costfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：将自己墓地2只「六武众」怪兽除外
function c75116619.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己墓地是否存在至少2只可以除外的「六武众」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75116619.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择2只满足条件的「六武众」怪兽
	local g=Duel.SelectMatchingCard(tp,c75116619.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：场上表侧表示且可以返回手牌的怪兽
function c75116619.filter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果目标：选择场上表侧表示存在的1只怪兽
function c75116619.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c75116619.filter(chkc) end
	-- 在发动时，检查场上是否存在至少1只可以返回手牌的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c75116619.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75116619.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：使选中的对象怪兽回到手牌
function c75116619.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e)
		-- 在效果处理时，检查自己场上是否仍存在「真六武众-缘」以外的「六武众」怪兽
		and Duel.IsExistingMatchingCard(c75116619.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 将该对象怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：场上表侧表示的「真六武众-缘」以外的「六武众」怪兽
function c75116619.vfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(75116619)
end
-- 攻击力·守备力上升效果的适用条件：自己场上有「真六武众-缘」以外的「六武众」怪兽2只以上存在
function c75116619.valcon(e)
	local c=e:GetHandler()
	-- 检查自己场上是否存在至少2只「真六武众-缘」以外的表侧表示「六武众」怪兽
	return Duel.IsExistingMatchingCard(c75116619.vfilter,c:GetControler(),LOCATION_MZONE,0,2,c)
end
