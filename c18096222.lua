--デュアル・ブースター
-- 效果：
-- ①：以自己场上1只二重怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
-- ②：当作装备卡使用的这张卡被破坏送去墓地的场合，以场上1只二重怪兽为对象发动。那只二重怪兽变成再1次召唤的状态。
function c18096222.initial_effect(c)
	-- 效果①：以自己场上1只二重怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c18096222.cost)
	e1:SetTarget(c18096222.target)
	e1:SetOperation(c18096222.operation)
	c:RegisterEffect(e1)
	-- 效果②：当作装备卡使用的这张卡被破坏送去墓地的场合，以场上1只二重怪兽为对象发动。那只二重怪兽变成再1次召唤的状态。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18096222,0))  --"变成再度召唤状态"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c18096222.dacon)
	e2:SetTarget(c18096222.datg)
	e2:SetOperation(c18096222.daop)
	c:RegisterEffect(e2)
end
c18096222.has_text_type=TYPE_DUAL
-- 设置效果成本函数，用于处理发动时的连锁相关逻辑
function c18096222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在场上停留
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 创建一个连锁被无效时触发的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c18096222.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，用于取消将卡送入墓地
function c18096222.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤函数：筛选场上表侧表示的二重怪兽
function c18096222.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 设置效果目标选择函数，用于选择场上一只二重怪兽
function c18096222.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18096222.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c18096222.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上一只二重怪兽作为装备对象
	Duel.SelectTarget(tp,c18096222.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息，表示将要进行装备操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置效果的处理函数，用于执行装备操作
function c18096222.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备卡效果：使装备怪兽攻击力上升700
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 装备卡效果：限制只能装备给特定怪兽
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c18096222.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制函数：判断是否可以装备给目标怪兽
function c18096222.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_DUAL)
end
-- 效果②的触发条件函数：判断装备卡是否因破坏而离场
function c18096222.dacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if c:IsReason(REASON_LOST_TARGET) then
		ec=c:GetPreviousEquipTarget()
	end
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_DESTROY) and ec~=nil
end
-- 过滤函数：筛选场上表侧表示且未处于再度召唤状态的二重怪兽
function c18096222.dafilter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
-- 效果②的目标选择函数，用于选择场上一只二重怪兽
function c18096222.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18096222.dafilter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上一只二重怪兽作为目标
	Duel.SelectTarget(tp,c18096222.dafilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理函数，使目标怪兽变为再度召唤状态
function c18096222.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c18096222.dafilter(tc) then
		tc:EnableDualState()
	end
end
