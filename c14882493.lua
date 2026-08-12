--極夜の騎士ガイア
-- 效果：
-- 「极夜之骑士 盖亚」的以下效果1回合各能使用1次。
-- ●把这张卡以外的自己场上1只暗属性怪兽解放才能发动。从卡组把1只战士族·光属性·4星怪兽加入手卡，那之后1张手卡送去墓地。
-- ●把自己墓地1只光属性怪兽除外，选择自己场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时上升500。
function c14882493.initial_effect(c)
	-- 把这张卡以外的自己场上1只暗属性怪兽解放才能发动。从卡组把1只战士族·光属性·4星怪兽加入手卡，那之后1张手卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14882493,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14882493)
	e1:SetCost(c14882493.thcost)
	e1:SetTarget(c14882493.thtg)
	e1:SetOperation(c14882493.thop)
	c:RegisterEffect(e1)
	-- 把自己墓地1只光属性怪兽除外，选择自己场上1只怪兽才能发动。选择的怪兽的攻击力直到对方的结束阶段时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14882493,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,14882494)
	e2:SetCost(c14882493.atkcost)
	e2:SetTarget(c14882493.atktg)
	e2:SetOperation(c14882493.atkop)
	c:RegisterEffect(e2)
end
-- cost，把这张卡以外的自己场上1只暗属性怪兽解放
function c14882493.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在这张卡以外的1只暗属性怪兽可以解放
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,e:GetHandler(),ATTRIBUTE_DARK) end
	-- 选择自己场上1只这张卡以外的暗属性怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,e:GetHandler(),ATTRIBUTE_DARK)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：等级为4且种族为战士族且属性为光且可以加入手牌的怪兽
function c14882493.filter(c)
	return c:IsLevel(4) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- target，检查卡组中是否存在符合条件的卡并设置操作信息
function c14882493.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14882493.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- operation，从卡组将战士族·光属性·4星怪兽加入手牌，然后将1张手牌送去墓地
function c14882493.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14882493.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方确认加入手牌的怪兽
		Duel.ConfirmCards(1-tp,g)
		-- 提示玩家选择要送去墓地的一张手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 玩家选择手牌中的1张卡
		local tg=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND,0,1,1,nil)
		-- 洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 中断当前效果，使前后处理不同时进行
		Duel.BreakEffect()
		-- 将所选手牌送去墓地
		Duel.SendtoGrave(tg,REASON_EFFECT)
	end
end
-- 过滤条件：墓地中的光属性且可以作为代价除外的卡
function c14882493.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToRemoveAsCost()
end
-- cost，将墓地1只光属性怪兽除外
function c14882493.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在满足除外条件的光属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14882493.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择需要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地中1张满足条件的光属性怪兽
	local g=Duel.SelectMatchingCard(tp,c14882493.cfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- target，选择场上1只表侧表示的怪兽为效果对象
function c14882493.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- operation，使选择的自己场上怪兽的攻击力上升500
function c14882493.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到对方的结束阶段时上升500
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
	end
end
