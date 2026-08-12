--A・∀・RR
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：可以把装备怪兽的控制者对应的以下效果发动。
-- ●自己：以对方墓地1张卡为对象才能发动。装备怪兽的表示形式变更，作为对象的卡回到卡组。
-- ●对方：装备怪兽的等级直到回合结束时上升1星，表示形式变更。
function c55262310.initial_effect(c)
	-- ①：以1只自己场上的「惊乐」怪兽或者对方场上的表侧表示怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(c55262310.cost)
	e1:SetTarget(c55262310.target)
	e1:SetOperation(c55262310.operation)
	c:RegisterEffect(e1)
	-- ②：可以把装备怪兽的控制者对应的以下效果发动。●自己：以对方墓地1张卡为对象才能发动。装备怪兽的表示形式变更，作为对象的卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55262310,0))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,55262310)
	e2:SetCondition(c55262310.tdcon)
	e2:SetTarget(c55262310.tdtg)
	e2:SetOperation(c55262310.tdop)
	c:RegisterEffect(e2)
	-- ②：可以把装备怪兽的控制者对应的以下效果发动。●对方：装备怪兽的等级直到回合结束时上升1星，表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55262310,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,55262310)
	e3:SetCondition(c55262310.poscon)
	e3:SetTarget(c55262310.postg)
	e3:SetOperation(c55262310.posop)
	c:RegisterEffect(e3)
end
-- 发动时的代价：设置陷阱卡发动后留在场上的效果，并注册连锁被无效时送去墓地的辅助效果
function c55262310.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c55262310.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 在全局注册连锁无效时送去墓地的效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理：如果该卡仍在连锁中，则取消送去墓地的状态并正常送去墓地
function c55262310.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：场上表侧表示的自己场上的「惊乐」怪兽或者对方场上的怪兽
function c55262310.filter(c,tp)
	return c:IsFaceup() and (c:IsSetCard(0x15b) or c:IsControler(1-tp))
end
-- 发动时的效果对象选择与合法性检查
function c55262310.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c55262310.filter(chkc,tp) end
	if chk==0 then return e:IsCostChecked()
		-- 检查场上是否存在可以作为装备对象的合法怪兽
		and Duel.IsExistingTarget(c55262310.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只符合条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c55262310.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动时的效果处理：将这张卡装备给目标怪兽，并设置装备限制
function c55262310.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			-- 将这张卡装备给目标怪兽
			Duel.Equip(tp,c,tc)
			-- 这张卡当作装备卡使用给那只怪兽装备。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(c55262310.eqlimit)
			c:RegisterEffect(e1)
		end
	elseif c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
		c:CancelToGrave(false)
	end
end
-- 装备限制：只能装备给该卡装备的目标怪兽，或自己场上的「惊乐」怪兽，或对方场上的怪兽
function c55262310.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x15b)
		or c:IsControler(1-e:GetHandlerPlayer())
end
-- 效果②（自己控制）的发动条件：装备怪兽的控制者是自己
function c55262310.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(tp)
end
-- 效果②（自己控制）的对象选择与合法性检查
function c55262310.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToDeck() end
	-- 检查装备怪兽是否能改变表示形式，且对方墓地是否存在可以回到卡组的卡
	if chk==0 then return ec and ec:IsCanChangePosition() and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地1张卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置效果处理信息为变更装备怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
	-- 设置效果处理信息为将对象卡回到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果②（自己控制）的效果处理：变更装备怪兽的表示形式，并将对象卡回到卡组
function c55262310.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为对象的对方墓地的卡
	local tc=Duel.GetFirstTarget()
	local ec=c:GetEquipTarget()
	-- 如果装备怪兽存在且成功变更表示形式，并且墓地的对象卡仍合法
	if ec and c:IsRelateToEffect(e) and Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 and tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回持有者卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果②（对方控制）的发动条件：装备怪兽的控制者是对方
function c55262310.poscon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsControler(1-tp)
end
-- 效果②（对方控制）的合法性检查与效果处理信息设置
function c55262310.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetEquipTarget()
	if chk==0 then return ec and ec:IsLevelAbove(1) and ec:IsCanChangePosition() end
	-- 设置效果处理信息为变更装备怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,ec,1,0,0)
end
-- 效果②（对方控制）的效果处理：装备怪兽等级上升1星，并变更表示形式
function c55262310.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- ●对方：装备怪兽的等级直到回合结束时上升1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		ec:RegisterEffect(e1)
		-- 变更装备怪兽的表示形式
		Duel.ChangePosition(ec,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
