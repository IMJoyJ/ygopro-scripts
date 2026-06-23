--騎竜ドラコバック
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：「骑龙 驮龙」在自己场上只能有1张表侧表示存在。
-- ②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
function c38745520.initial_effect(c)
	-- 记录该卡记载了「勇者衍生物」的卡片密码。
	aux.AddCodeList(c,3285552)
	c:SetUniqueOnField(1,0,38745520)
	-- 自己场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c38745520.target)
	e1:SetOperation(c38745520.activate)
	c:RegisterEffect(e1)
	-- 自己场上的怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c38745520.eqlimit)
	c:RegisterEffect(e2)
	-- ②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,38745520)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c38745520.thcon)
	e3:SetTarget(c38745520.thtg)
	e3:SetOperation(c38745520.thop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,38745521)
	e4:SetTarget(c38745520.eqtg)
	e4:SetOperation(c38745520.eqop)
	c:RegisterEffect(e4)
end
-- 装备魔法卡发动时的对象选择处理函数。
function c38745520.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以装备的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择自己场上1只表侧表示怪兽作为装备对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备操作信息，包含目标怪兽组。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备魔法卡发动后的效果处理函数。
function c38745520.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 限制装备对象只能是自己场上的怪兽。
function c38745520.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 检查装备怪兽是否为效果怪兽以外的怪兽。
function c38745520.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
-- 效果②的发动准备：检查并选择对方场上的卡作为对象。
function c38745520.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 检查对方场上是否存在可以返回手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1张可以返回手牌的卡作为对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置返回手牌的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理：将目标卡片送回持有者手牌。
function c38745520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取要返回手牌的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行将目标卡片送回手牌的操作。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：卡名为「勇者衍生物」且在场上表侧表示。
function c38745520.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 效果③的发动准备：检查墓地此卡是否可装备及场上是否有「勇者衍生物」。
function c38745520.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c38745520.cfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	-- 检查自己场上是否存在表侧表示的「勇者衍生物」。
	if chk==0 then return Duel.IsExistingTarget(c38745520.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查魔法陷阱区是否有空位以及是否满足场上只能存在1张的限制。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) end
	-- 提示玩家选择要装备的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「勇者衍生物」作为装备对象。
	local g=Duel.SelectTarget(tp,c38745520.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备操作信息，包含此卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置此卡离开墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果③的处理：将墓地的此卡装备给目标「勇者衍生物」。
function c38745520.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法陷阱区是否仍有空位。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取要装备的目标「勇者衍生物」。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		-- 执行装备操作，将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
