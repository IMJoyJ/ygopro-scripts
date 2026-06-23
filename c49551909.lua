--ヒロイック・リベンジ・ソード
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上1只名字带有「英豪」的怪兽装备。装备怪兽的战斗发生的对自己的战斗伤害让对方也承受。此外，和装备怪兽进行战斗的对方怪兽在伤害计算后破坏。
function c49551909.initial_effect(c)
	-- 创建此卡的发动效果，设置为自由时点，需要选择对象，发动时支付费用，处理目标和操作
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c49551909.cost)
	e1:SetTarget(c49551909.target)
	e1:SetOperation(c49551909.operation)
	c:RegisterEffect(e1)
end
-- 此函数用于处理发动时的费用，使此卡在连锁处理期间留在场上，并注册一个连锁被无效时的处理效果
function c49551909.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前正在处理的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在发动后于场上停留（不送入墓地）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个当此卡的连锁被无效时，取消其送去墓地的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c49551909.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁无效时的处理效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
-- 此函数用于处理连锁被无效时的操作，如果该连锁是当前卡的连锁，则取消其送去墓地
function c49551909.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选场上正面表示且名字带有「英豪」的怪兽
function c49551909.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 设置发动效果的目标选择条件为己方场上的名字带有「英豪」的怪兽
function c49551909.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49551909.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否满足目标选择条件，即己方场上是否存在名字带有「英豪」的怪兽
		and Duel.IsExistingTarget(c49551909.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个己方场上的名字带有「英豪」的怪兽作为装备对象
	Duel.SelectTarget(tp,c49551909.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置发动效果的操作信息为装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 此函数用于处理发动效果的操作，将此卡装备给目标怪兽并注册后续效果
function c49551909.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 注册一个当装备怪兽战斗时触发的效果，用于破坏对方怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCategory(CATEGORY_DESTROY)
		e1:SetDescription(aux.Stringid(49551909,0))
		e1:SetCode(EVENT_BATTLED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c49551909.descon)
		e1:SetTarget(c49551909.destg)
		e1:SetOperation(c49551909.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 注册一个使装备怪兽在战斗中受到的伤害也由对方承受的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 注册一个限制此卡只能装备给名字带有「英豪」的怪兽的效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c49551909.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备限制条件为只能装备给此卡的装备对象或己方场上的名字带有「英豪」的怪兽
function c49551909.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x6f)
end
-- 设置破坏效果的触发条件，当装备怪兽参与战斗时触发
function c49551909.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断是否为装备怪兽参与战斗的情况
	return Duel.GetAttackTarget()==ec or (Duel.GetAttacker()==ec and Duel.GetAttackTarget())
end
-- 设置破坏效果的目标为与装备怪兽战斗的对方怪兽
function c49551909.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetEquipTarget():GetBattleTarget(),1,0,0)
end
-- 此函数用于处理破坏效果的操作，将与装备怪兽战斗的对方怪兽破坏
function c49551909.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 将目标怪兽以效果原因破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
