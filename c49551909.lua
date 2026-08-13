--ヒロイック・リベンジ・ソード
-- 效果：
-- 发动后这张卡变成装备卡，给自己场上1只名字带有「英豪」的怪兽装备。装备怪兽的战斗发生的对自己的战斗伤害让对方也承受。此外，和装备怪兽进行战斗的对方怪兽在伤害计算后破坏。
function c49551909.initial_effect(c)
	-- 发动后这张卡变成装备卡，给自己场上1只名字带有「英豪」的怪兽装备。
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
-- 发动代价处理：检查无实际代价；记录本卡的发动连锁ID，并给本卡附加连锁处理期间留在场上的誓约效果，同时注册一个在连锁被无效时取消本卡送去墓地的保护效果。
function c49551909.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于后续标记本卡的发动连锁，以便在连锁被无效时识别。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 给自己场上1只名字带有「英豪」的怪兽装备。装备怪兽的战斗发生的对自己的战斗伤害让对方也承受。此外，和装备怪兽进行战斗的对方怪兽在伤害计算后破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c49551909.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将用于在连锁被无效时保护本卡的效果e2注册到场上，监督全场连锁无效事件。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的补救处理：若被无效的连锁ID与本卡发动时记录的ID一致，且本卡仍与该连锁关联，则取消本卡因发动无效被送去墓地的处理，使其留在场上。
function c49551909.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效连锁的ID，用于与保存的本卡发动连锁ID进行比对。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 装备对象过滤条件：对象必须是表侧表示且名字带有「英豪」的怪兽。
function c49551909.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x6f)
end
-- 发动目标判定：确认代价已检查且自己场上有满足条件的表侧「英豪」怪兽可选；若指定了对象chkc，则进一步校验该对象是否合法。
function c49551909.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c49551909.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件的表侧「英豪」怪兽，以确定效果能否发动。
		and Duel.IsExistingTarget(c49551909.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示选择提示文字“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让发动者从自己场上选择1只表侧「英豪」怪兽作为装备对象，并将其设置为当前连锁的对象卡。
	Duel.SelectTarget(tp,c49551909.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本卡自身将成为装备卡（CATEGORY_EQUIP），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：若本卡仍在魔陷区且与效果关联、目标仍有效，则将本卡装备给目标，并注册战斗破坏、伤害转移和装备限制效果；否则取消本卡本次送去墓地的处理。
function c49551909.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将本卡作为装备魔法卡装备给选中的「英豪」怪兽。
		Duel.Equip(tp,c,tc)
		-- 此外，和装备怪兽进行战斗的对方怪兽在伤害计算后破坏。
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
		-- 装备怪兽的战斗发生的对自己的战斗伤害让对方也承受。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_ALSO_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给自己场上1只名字带有「英豪」的怪兽装备。
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
-- 装备限制条件：允许装备给自己场上名字带有「英豪」的怪兽，或者当前已经装备的怪兽。
function c49551909.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0x6f)
end
-- 破坏效果的发动条件：装备怪兽参与了战斗（作为攻击目标或攻击者并存在攻击目标）。
function c49551909.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 具体判断：装备怪兽是被攻击的怪兽，或者装备怪兽是攻击者且存在被攻击的怪兽。
	return Duel.GetAttackTarget()==ec or (Duel.GetAttacker()==ec and Duel.GetAttackTarget())
end
-- 破坏效果的target设置：设置操作信息，将破坏与装备怪兽战斗的对方怪兽。
function c49551909.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：以效果破坏对象为与装备怪兽进行战斗的对方怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetEquipTarget():GetBattleTarget(),1,0,0)
end
-- 破坏效果处理：取得与装备怪兽战斗的对方怪兽，若它仍与本次战斗相关，则将其破坏。
function c49551909.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 用效果破坏该对方怪兽，送去墓地。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
