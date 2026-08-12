--ロケットハンド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只攻击力800以上的攻击表示怪兽为对象才能把这张卡发动。这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。
-- ②：把装备的这张卡送去墓地，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，这张卡装备过的怪兽攻击力变成0，不能把表示形式变更。
function c13317419.initial_effect(c)
	-- ①：以自己场上1只攻击力800以上的攻击表示怪兽为对象才能把这张卡发动。这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,13317419)
	-- 限制效果只能在伤害计算前发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c13317419.cost)
	e1:SetTarget(c13317419.target)
	e1:SetOperation(c13317419.operation)
	c:RegisterEffect(e1)
	-- ②：把装备的这张卡送去墓地，以场上1张表侧表示的卡为对象才能发动。那张卡破坏。那之后，这张卡装备过的怪兽攻击力变成0，不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,13317419)
	e2:SetCondition(c13317419.descon)
	e2:SetCost(c13317419.descost)
	e2:SetTarget(c13317419.destg)
	e2:SetOperation(c13317419.desop)
	c:RegisterEffect(e2)
end
-- 设置效果发动时的费用处理函数
function c13317419.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在发动后不会被送入墓地
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册连锁被无效时的处理函数
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13317419.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果注册给指定玩家
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数
function c13317419.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选攻击力800以上的攻击表示怪兽
function c13317419.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttackAbove(800)
end
-- 设置效果的目标选择函数
function c13317419.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13317419.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c13317419.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择目标怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c13317419.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果操作信息为装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置效果的处理函数
function c13317419.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备卡的攻击力提升800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置装备限制条件
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c13317419.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备限制条件的判断函数
function c13317419.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttackAbove(800)
end
-- 设置效果发动条件函数
function c13317419.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- 设置效果发动时的费用处理函数
function c13317419.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选场上表侧表示的卡
function c13317419.desfilter(c)
	return c:IsFaceup()
end
-- 设置效果的目标选择函数
function c13317419.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c13317419.desfilter(chkc) end
	-- 检查是否存在满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(c13317419.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择要破坏的卡
	local g=Duel.SelectTarget(tp,c13317419.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果的处理函数
function c13317419.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and ec and ec:IsFaceup() and ec:IsLocation(LOCATION_MZONE) then
		-- 中断当前效果处理，使后续效果视为错时点
		Duel.BreakEffect()
		-- 设置装备怪兽的攻击力变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 设置装备怪兽不能改变表示形式
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end
