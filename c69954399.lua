--疫病ウィルス ブラックダスト
-- 效果：
-- 装备这张卡的怪兽不能攻击。装备怪兽的控制者的第2次回合结束时，装备怪兽破坏。这个效果成功的场合，这张卡回到持有者的手卡。
function c69954399.initial_effect(c)
	-- （卡片的发动与装备）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c69954399.target)
	e1:SetOperation(c69954399.operation)
	c:RegisterEffect(e1)
	-- 装备这张卡的怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	c:RegisterEffect(e2)
	-- （装备限制）
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 装备怪兽的控制者的第2次回合结束时
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c69954399.turncon)
	e4:SetOperation(c69954399.turnop)
	c:RegisterEffect(e4)
	-- 装备怪兽的控制者的第2次回合结束时，装备怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(69954399,0))  --"破坏"
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCountLimit(1)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(c69954399.descon)
	e5:SetTarget(c69954399.destg)
	e5:SetOperation(c69954399.desop)
	c:RegisterEffect(e5)
	-- 这个效果成功的场合，这张卡回到持有者的手卡。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(69954399,1))  --"返回手牌"
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_CUSTOM+69954400)
	e6:SetTarget(c69954399.rettg)
	e6:SetOperation(c69954399.retop)
	c:RegisterEffect(e6)
end
-- 卡片发动时的对象选择与效果处理准备
function c69954399.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为装备对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的效果处理，将此卡装备给目标怪兽并初始化回合计数器
function c69954399.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡片发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
		e:GetHandler():SetTurnCounter(0)
	end
end
-- 回合结束时，检查当前回合玩家是否为装备怪兽的控制者
function c69954399.turncon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断当前回合玩家是否是装备怪兽的控制者
	return ec:GetControler()==Duel.GetTurnPlayer()
end
-- 在装备怪兽控制者的回合结束时，将这张卡的回合计数器加1
function c69954399.turnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	c:SetTurnCounter(ct+1)
end
-- 检查这张卡的回合计数器是否达到2次（即第2次回合结束时）
function c69954399.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetTurnCounter()==2
end
-- 破坏效果的发动准备，确认装备怪兽并设置破坏操作信息
function c69954399.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ec=e:GetHandler():GetEquipTarget()
	ec:CreateEffectRelation(e)
	-- 设置效果处理信息为破坏装备怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,ec,1,0,0)
end
-- 执行破坏装备怪兽的操作，并在破坏成功时触发自定义事件
function c69954399.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 如果装备怪兽存在且成功被效果破坏
	if ec and ec:IsRelateToEffect(e) and Duel.Destroy(ec,REASON_EFFECT)~=0 then
		-- 触发自定义事件，用于后续处理这张卡回到手卡的效果
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+69954400,e,0,0,0,0)
	end
end
-- 返回手卡效果的发动准备，设置回手卡操作信息
function c69954399.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为将这张卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 执行将这张卡送回持有者手卡并给对方确认的操作
function c69954399.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡送回持有者的手卡
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,e:GetHandler())
	end
end
