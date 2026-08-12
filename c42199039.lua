--妖刀竹光
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升0。
-- ②：以自己场上1张其他的「竹光」卡为对象才能发动。那张卡回到手卡，装备怪兽在这个回合可以直接攻击。
-- ③：这张卡被送去墓地的场合才能发动。从卡组把「妖刀竹光」以外的1张「竹光」卡加入手卡。
function c42199039.initial_effect(c)
	-- ①：装备怪兽的攻击力上升0。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c42199039.target)
	e1:SetOperation(c42199039.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：以自己场上1张其他的「竹光」卡为对象才能发动。那张卡回到手卡，装备怪兽在这个回合可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(42199039,0))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,42199039)
	e3:SetTarget(c42199039.dttg)
	e3:SetOperation(c42199039.dtop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合才能发动。从卡组把「妖刀竹光」以外的1张「竹光」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(42199039,1))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetTarget(c42199039.thtg)
	e4:SetOperation(c42199039.thop)
	c:RegisterEffect(e4)
end
-- 选择装备怪兽，检查场上是否存在至少1只表侧表示的怪兽
function c42199039.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只场上表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡生效，将装备卡装备给目标怪兽
function c42199039.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 过滤函数，筛选场上表侧表示的「竹光」卡
function c42199039.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x60) and c:IsAbleToHand()
end
-- 选择要返回手卡的「竹光」卡，检查是否存在满足条件的卡
function c42199039.dttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c42199039.filter(chkc) and chkc~=e:GetHandler() end
	local eq=e:GetHandler():GetEquipTarget()
	-- 检查是否存在满足条件的「竹光」卡
	if chk==0 then return eq and not eq:IsHasEffect(EFFECT_DIRECT_ATTACK) and Duel.IsExistingTarget(c42199039.filter,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1张满足条件的「竹光」卡作为返回手卡的对象
	local g=Duel.SelectTarget(tp,c42199039.filter,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 设置效果处理信息，将目标卡返回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果，将目标卡返回手卡并赋予装备怪兽直接攻击能力
function c42199039.dtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡是否有效且成功返回手卡
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 向对方确认目标卡
		Duel.ConfirmCards(1-tp,tc)
		local ec=c:GetEquipTarget()
		-- 赋予装备怪兽直接攻击能力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetCondition(c42199039.dircon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
	end
end
-- 判断装备怪兽是否为当前玩家控制
function c42199039.dircon(e)
	return e:GetHandler():GetControler()==e:GetOwnerPlayer()
end
-- 过滤函数，筛选卡组中非妖刀竹光的「竹光」卡
function c42199039.thfilter(c)
	return c:IsSetCard(0x60) and not c:IsCode(42199039) and c:IsAbleToHand()
end
-- 检索卡组中的「竹光」卡，检查是否存在满足条件的卡
function c42199039.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「竹光」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c42199039.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，准备从卡组检索卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行卡组检索效果，选择1张「竹光」卡加入手卡
function c42199039.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「竹光」卡
	local g=Duel.SelectMatchingCard(tp,c42199039.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
