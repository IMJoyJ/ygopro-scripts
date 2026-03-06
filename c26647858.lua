--ヒーロー・ヘイロー
-- 效果：
-- 发动后这张卡变成装备卡，攻击力1500以下的1只战士族怪兽装备。对方的攻击力1900以上的怪兽不能攻击装备怪兽。
function c26647858.initial_effect(c)
	-- 发动后这张卡变成装备卡，攻击力1500以下的1只战士族怪兽装备。对方的攻击力1900以上的怪兽不能攻击装备怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c26647858.cost)
	e1:SetTarget(c26647858.target)
	e1:SetOperation(c26647858.operation)
	c:RegisterEffect(e1)
end
-- 设置此卡发动时的费用处理函数为c26647858.cost
function c26647858.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 使此卡在发动后留在场上
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 设置连锁被无效时的处理函数为c26647858.tgop
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c26647858.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理函数，若连锁ID匹配则取消送入墓地
function c26647858.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 定义筛选条件：场上表侧表示、攻击力1500以下、战士族怪兽
function c26647858.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsRace(RACE_WARRIOR)
end
-- 设置此卡发动时的目标选择函数为c26647858.target
function c26647858.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26647858.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否满足发动条件：存在满足条件的目标怪兽
		and Duel.IsExistingTarget(c26647858.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的1只怪兽作为装备对象
	Duel.SelectTarget(tp,c26647858.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置发动效果的操作信息为装备效果
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置此卡发动时的处理函数为c26647858.operation
function c26647858.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备怪兽不能成为攻击对象
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
		e1:SetValue(c26647858.atval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 设置此卡只能装备给满足条件的怪兽
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(c26647858.eqlimit)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制条件：只能装备给自身装备的怪兽或攻击力1500以下的战士族怪兽
function c26647858.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsAttackBelow(1500) and c:IsRace(RACE_WARRIOR)
end
-- 攻击对象条件：攻击力1900以上的怪兽不能攻击装备怪兽
function c26647858.atval(e,c)
	return c:IsAttackAbove(1900) and not c:IsImmuneToEffect(e)
end
