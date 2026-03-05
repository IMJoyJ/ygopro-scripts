--アメイズメント・ファミリーフェイス
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：得到装备怪兽的控制权。
-- ③：装备怪兽只要在自己的怪兽区域存在，攻击力上升500，不能把效果发动，也当作「惊乐」怪兽使用。
function c20989253.initial_effect(c)
	-- ①：以有自己的「游乐设施」陷阱卡装备的对方场上1只怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,20989253+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c20989253.cost)
	e1:SetTarget(c20989253.target)
	e1:SetOperation(c20989253.operation)
	c:RegisterEffect(e1)
	-- ②：得到装备怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SET_CONTROL)
	e2:SetValue(c20989253.cval)
	c:RegisterEffect(e2)
	-- ③：装备怪兽只要在自己的怪兽区域存在，攻击力上升500，不能把效果发动，也当作「惊乐」怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	e3:SetCondition(c20989253.con)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetDescription(aux.Stringid(20989253,0))  --"「惊乐家族脸」效果适用中"
	e5:SetCode(EFFECT_ADD_SETCODE)
	e5:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e5:SetValue(0x15b)
	c:RegisterEffect(e5)
end
-- 发动时支付1点费用，使此卡在发动后不会因连锁被无效而送入墓地
function c20989253.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后不会因连锁被无效而送入墓地
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个连锁被无效时的处理效果，若连锁被无效则取消此卡送入墓地
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c20989253.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时的处理效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，若连锁ID匹配则取消此卡送入墓地
function c20989253.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判断目标是否为「游乐设施」陷阱卡
function c20989253.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x15c) and c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
-- 判断目标是否为有「游乐设施」陷阱卡装备的对方怪兽
function c20989253.filter(c,tp)
	return c:IsFaceup() and c:GetEquipGroup():IsExists(c20989253.cfilter,1,nil,tp) and c:IsControlerCanBeChanged()
end
-- 设置效果目标为对方场上满足条件的怪兽
function c20989253.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c20989253.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 判断是否存在满足条件的对方怪兽
		and Duel.IsExistingTarget(c20989253.filter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的对方怪兽作为目标
	local g=Duel.SelectTarget(tp,c20989253.filter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置效果操作信息为改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 执行装备操作，将此卡装备给目标怪兽
function c20989253.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将此卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 设置装备限制，使此卡只能装备给满足条件的怪兽
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c20989253.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 判断目标是否为装备此卡的怪兽或其控制者为对方且有「游乐设施」陷阱卡装备
function c20989253.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(1-tp) and c:GetEquipGroup():IsExists(c20989253.cfilter,1,nil,tp)
end
-- 返回此卡的持有者作为控制权的拥有者
function c20989253.cval(e,c)
	return e:GetHandlerPlayer()
end
-- 判断装备怪兽是否为己方控制
function c20989253.con(e)
	return e:GetHandler():GetEquipTarget():IsControler(e:GetHandlerPlayer())
end
