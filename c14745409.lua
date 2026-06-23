--聖剣ガラティーン
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「圣剑 加拉廷」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽的攻击力上升1000，每次自己准备阶段下降200。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
function c14745409.initial_effect(c)
	c:SetUniqueOnField(1,0,14745409)
	-- ①：「圣剑 加拉廷」在自己场上只能有1张表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c14745409.target)
	e1:SetOperation(c14745409.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽的攻击力上升1000，每次自己准备阶段下降200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c14745409.eqlimit)
	c:RegisterEffect(e3)
	-- 每次自己准备阶段，装备怪兽的攻击力下降200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c14745409.atkcon)
	e4:SetOperation(c14745409.atkop)
	c:RegisterEffect(e4)
	-- 场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14745409,0))  --"装备"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,14745409)
	e5:SetCondition(c14745409.eqcon)
	e5:SetTarget(c14745409.eqtg)
	e5:SetOperation(c14745409.operation2)
	c:RegisterEffect(e5)
end
-- 限制装备对象必须为战士族
function c14745409.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 筛选场上正面表示的战士族怪兽作为装备对象
function c14745409.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 设置装备效果的处理目标
function c14745409.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14745409.eqfilter1(chkc) end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(c14745409.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备对象
	Duel.SelectTarget(tp,c14745409.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果的处理函数
function c14745409.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否为自己的准备阶段
function c14745409.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段攻击力下降效果的处理函数
function c14745409.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(14745409)==0 then
		-- 装备怪兽的攻击力下降200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(14745409,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(e1)
		e:SetLabel(2)
	else
		local pe=e:GetLabelObject()
		local ct=e:GetLabel()
		e:SetLabel(ct+1)
		pe:SetValue(ct*-200)
	end
end
-- 判断装备卡被破坏送入墓地的条件
function c14745409.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 筛选场上正面表示的战士族「圣骑士」怪兽
function c14745409.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 设置装备卡送入墓地后发动效果的目标选择
function c14745409.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14745409.eqfilter2(chkc) end
	-- 判断装备卡送入墓地后发动效果是否满足条件
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足装备卡送入墓地后发动效果的条件
		and Duel.IsExistingTarget(c14745409.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择装备对象
	Duel.SelectTarget(tp,c14745409.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置装备卡送入墓地后发动效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备卡送入墓地后发动效果的处理函数
function c14745409.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备卡送入墓地后发动效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c14745409.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
