--白夜の騎士ガイア
-- 效果：
-- 「白夜之骑士 盖亚」的以下效果1回合各能使用1次。
-- ●把这张卡以外的自己场上1只光属性怪兽解放才能发动。从卡组把1只战士族·暗属性·4星怪兽加入手卡，那之后1张手卡送去墓地。
-- ●把自己墓地1只暗属性怪兽除外，选择场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时下降500。
function c40371092.initial_effect(c)
	-- 「白夜之骑士 盖亚」的以下效果1回合各能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40371092,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,40371092)
	e1:SetCost(c40371092.thcost)
	e1:SetTarget(c40371092.thtg)
	e1:SetOperation(c40371092.thop)
	c:RegisterEffect(e1)
	-- ●把自己墓地1只暗属性怪兽除外，选择场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40371092,1))  --"攻击力下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,40371093)
	e2:SetCost(c40371092.atkcost)
	e2:SetTarget(c40371092.atktg)
	e2:SetOperation(c40371092.atkop)
	c:RegisterEffect(e2)
end
-- 检查玩家场上是否存在至少1张满足条件的光属性怪兽并且不等于自身，用于判断是否可以发动效果
function c40371092.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的光属性怪兽并且不等于自身，用于判断是否可以发动效果
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_LIGHT) end
	-- 让玩家选择1张满足条件的光属性怪兽并且不等于自身，用于发动效果
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_LIGHT)
	-- 以REASON_COST原因解放选择的怪兽，用于支付效果的代价
	Duel.Release(g,REASON_COST)
end
-- 定义检索卡牌的过滤条件：4星战士族暗属性怪兽
function c40371092.filter(c)
	return c:IsLevel(4) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 设置效果处理时需要确认的卡组检索和手牌丢弃操作信息
function c40371092.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在至少1张满足条件的怪兽，用于判断是否可以发动效果
	if chk==0 then return Duel.IsExistingMatchingCard(c40371092.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时需要确认的卡组检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时需要确认的手牌丢弃操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
-- 处理效果的执行逻辑：检索满足条件的卡并丢弃手牌
function c40371092.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组中的1张卡
	local g=Duel.SelectMatchingCard(tp,c40371092.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 以REASON_EFFECT原因将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切玩家的手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 以REASON_EFFECT原因丢弃玩家手牌1张
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT)
	end
end
-- 定义支付代价的过滤条件：墓地中的暗属性怪兽
function c40371092.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 处理效果的执行逻辑：支付代价并选择目标
function c40371092.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家墓地中是否存在至少1张满足条件的怪兽，用于判断是否可以发动效果
	if chk==0 then return Duel.IsExistingMatchingCard(c40371092.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的墓地中的1张卡
	local g=Duel.SelectMatchingCard(tp,c40371092.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 以REASON_COST原因将选择的卡除外，用于支付效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 处理效果的执行逻辑：选择目标怪兽
function c40371092.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查玩家场上是否存在至少1张满足条件的表侧表示怪兽，用于判断是否可以发动效果
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上1张怪兽作为目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的执行逻辑：给目标怪兽攻击力下降500
function c40371092.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 创建一个攻击力下降500的效果并注册到目标怪兽上，持续到对方结束阶段
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
