--騎竜ドラコバック
-- 效果：
-- 自己场上的怪兽才能装备。这个卡名的②③的效果1回合各能使用1次。
-- ①：「骑龙 驮龙」在自己场上只能有1张表侧表示存在。
-- ②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
function c38745520.initial_effect(c)
	-- 记录该卡牌效果中涉及的其他卡牌编号
	aux.AddCodeList(c,3285552)
	c:SetUniqueOnField(1,0,38745520)
	-- ①：「骑龙 驮龙」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c38745520.target)
	e1:SetOperation(c38745520.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡给效果怪兽以外的怪兽装备中的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c38745520.eqlimit)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以自己场上1只「勇者衍生物」为对象才能发动。那只自己怪兽把这张卡装备。
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
	-- 效果作用
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
-- 选择装备对象
function c38745520.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择装备目标
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 装备卡牌
function c38745520.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备对象限制
function c38745520.eqlimit(e,c)
	return c:IsControler(e:GetHandlerPlayer())
end
-- 判断装备目标是否为效果怪兽
function c38745520.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():GetEquipTarget():IsType(TYPE_EFFECT)
end
-- 选择返回手牌的目标
function c38745520.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 判断是否满足返回手牌条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示选择返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择返回手牌的目标
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置返回手牌效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行返回手牌操作
function c38745520.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡返回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 筛选勇者衍生物
function c38745520.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 选择装备目标
function c38745520.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c38745520.cfilter(chkc) and chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	local c=e:GetHandler()
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c38745520.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断装备区域是否充足及唯一性
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and c:CheckUniqueOnField(tp) end
	-- 提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	local g=Duel.SelectTarget(tp,c38745520.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
	-- 设置离开墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 装备卡牌
function c38745520.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断装备区域是否充足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and c:IsRelateToEffect(e) and c:CheckUniqueOnField(tp) then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
