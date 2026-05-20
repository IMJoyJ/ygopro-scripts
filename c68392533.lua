--念動増幅装置
-- 效果：
-- 念动力族怪兽才能装备。为装备怪兽的效果发动而支付的基本分变成不需要。装备怪兽被破坏让这张卡送去墓地时，可以支付1000基本分让这张卡回到手卡。
function c68392533.initial_effect(c)
	-- 念动力族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c68392533.target)
	e1:SetOperation(c68392533.operation)
	c:RegisterEffect(e1)
	-- 为装备怪兽的效果发动而支付的基本分变成不需要。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LPCOST_CHANGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c68392533.costchange)
	c:RegisterEffect(e2)
	-- 念动力族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c68392533.eqlimit)
	c:RegisterEffect(e3)
	-- 装备怪兽被破坏让这张卡送去墓地时，可以支付1000基本分让这张卡回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(68392533,0))  --"返回手牌"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c68392533.thcon)
	e4:SetCost(c68392533.thcost)
	e4:SetTarget(c68392533.thtg)
	e4:SetOperation(c68392533.thop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备于念动力族怪兽
function c68392533.eqlimit(e,c)
	return c:IsRace(RACE_PSYCHO)
end
-- 过滤条件：场上表侧表示的念动力族怪兽
function c68392533.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 装备魔法卡发动时的效果去对象与操作信息设置
function c68392533.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68392533.filter(chkc) end
	-- 检查场上是否存在可以装备的表侧表示念动力族怪兽
	if chk==0 then return Duel.IsExistingTarget(c68392533.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示的念动力族怪兽作为装备对象
	Duel.SelectTarget(tp,c68392533.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理：将此卡装备给目标怪兽
function c68392533.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 改变基本分代价：若发动效果的是装备怪兽，则将所需支付的基本分变为0
function c68392533.costchange(e,re,rp,val)
	if re and re:IsActivated() and re:GetHandler()==e:GetHandler():GetEquipTarget() then
		return 0
	else return val end
end
-- 触发条件：装备怪兽被破坏导致这张卡失去装备对象而送去墓地
function c68392533.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY)
end
-- 发动代价：检查并支付1000基本分
function c68392533.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果目标：检查此卡是否能加入手卡，并设置回收的操作信息
function c68392533.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为将这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡加入手卡并给对方确认
function c68392533.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
