--聖剣クラレント
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「圣剑 克拉伦特」在自己场上只能有1张表侧表示存在。
-- ②：1回合1次，支付500基本分才能发动。这个回合，装备怪兽可以直接攻击。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
function c41359411.initial_effect(c)
	c:SetUniqueOnField(1,0,41359411)
	-- ①：「圣剑 克拉伦特」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c41359411.target)
	e1:SetOperation(c41359411.operation)
	c:RegisterEffect(e1)
	-- 战士族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c41359411.eqlimit)
	c:RegisterEffect(e2)
	-- ②：1回合1次，支付500基本分才能发动。这个回合，装备怪兽可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(41359411,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c41359411.dircon)
	e3:SetCost(c41359411.dircost)
	e3:SetOperation(c41359411.dirop)
	c:RegisterEffect(e3)
	-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(41359411,1))
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,41359411)
	e4:SetCondition(c41359411.eqcon)
	e4:SetTarget(c41359411.eqtg)
	e4:SetOperation(c41359411.operation2)
	c:RegisterEffect(e4)
end
-- 限制装备怪兽必须为战士族
function c41359411.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 筛选场上正面表示的战士族怪兽作为装备对象
function c41359411.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 选择装备对象并设置装备效果的处理信息
function c41359411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c41359411.eqfilter1(chkc) end
	-- 判断是否存在符合条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c41359411.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象
	Duel.SelectTarget(tp,c41359411.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c41359411.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否能进入战斗阶段
function c41359411.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 支付500基本分作为发动费用
function c41359411.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 使装备怪兽获得直接攻击能力
function c41359411.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 装备怪兽获得直接攻击能力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 判断装备卡是否因破坏而进入墓地且满足使用条件
function c41359411.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 筛选场上正面表示的战士族「圣骑士」怪兽作为装备对象
function c41359411.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 选择装备对象并设置装备效果的处理信息
function c41359411.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41359411.eqfilter2(chkc) end
	-- 判断装备卡是否存在于场上的同时判断场上是否有装备空间
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否存在符合条件的装备对象
		and Duel.IsExistingTarget(c41359411.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象
	Duel.SelectTarget(tp,c41359411.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置装备卡离开墓地的处理信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function c41359411.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备对象
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c41359411.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
