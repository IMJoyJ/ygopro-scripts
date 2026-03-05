--デーモンの杖
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降装备怪兽的攻击力一半数值。
-- ②：给怪兽装备的这张卡被送去墓地的场合，支付1000基本分才能发动。这张卡回到手卡。
function c21438286.initial_effect(c)
	-- ①：自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c21438286.target)
	e1:SetOperation(c21438286.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c21438286.eqlimit)
	c:RegisterEffect(e2)
	-- ①：自己主要阶段才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降装备怪兽的攻击力一半数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21438286,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,21438286)
	e3:SetTarget(c21438286.cftg)
	e3:SetOperation(c21438286.cfop)
	c:RegisterEffect(e3)
	-- ②：给怪兽装备的这张卡被送去墓地的场合，支付1000基本分才能发动。这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21438286,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,21438287)
	e4:SetCondition(c21438286.thcon)
	e4:SetCost(c21438286.thcost)
	e4:SetTarget(c21438286.thtg)
	e4:SetOperation(c21438286.thop)
	c:RegisterEffect(e4)
end
-- 装备对象必须是自己场上的怪兽
function c21438286.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 选择装备对象，要求自己场上存在表侧表示的怪兽
function c21438286.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡牌效果的执行函数
function c21438286.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ①效果的发动条件判断
function c21438286.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽攻击力大于等于1且对方场上存在表侧表示怪兽
	if chk==0 then return ec and ec:IsAttackAbove(1) and Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)>0 end
end
-- ①效果的执行函数
function c21438286.cfop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local d=c:GetEquipTarget():GetAttack()
		d=math.ceil(d/2)
		local sc=g:GetFirst()
		while sc do
			-- 给对方场上怪兽添加攻击力下降效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-d)
			sc:RegisterEffect(e1)
			sc=g:GetNext()
		end
	end
end
-- ②效果的发动条件判断
function c21438286.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- ②效果的发动费用支付函数
function c21438286.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- ②效果的发动目标设定
function c21438286.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置将卡牌送入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的执行函数
function c21438286.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将装备卡送入手牌
		Duel.SendtoHand(e:GetHandler(),nil,REASON_EFFECT)
	end
end
