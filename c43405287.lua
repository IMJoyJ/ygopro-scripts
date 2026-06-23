--D－チェーン
-- 效果：
-- ①：以自己场上1只「命运英雄」怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
-- ②：装备怪兽战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
function c43405287.initial_effect(c)
	-- ①：以自己场上1只「命运英雄」怪兽为对象才能把这张卡发动。这张卡当作攻击力上升500的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c43405287.cost)
	e1:SetTarget(c43405287.target)
	e1:SetOperation(c43405287.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽战斗破坏对方怪兽送去墓地的场合发动。给与对方500伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43405287,0))  --"伤害"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c43405287.damcon)
	e2:SetTarget(c43405287.damtg)
	e2:SetOperation(c43405287.damop)
	c:RegisterEffect(e2)
end
-- 设置效果的发动条件为在伤害步骤中发动。
function c43405287.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 设置此卡在发动后会留在场上。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 注册一个连锁被无效时的处理效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c43405287.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将效果e2注册给玩家tp。
	Duel.RegisterEffect(e2,tp)
end
-- 当连锁被无效时，取消此卡进入墓地。
function c43405287.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 判断目标怪兽是否为「命运英雄」卡组。
function c43405287.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc008)
end
-- 设置效果的目标为己方场上的「命运英雄」怪兽。
function c43405287.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c43405287.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查是否存在满足条件的目标怪兽。
		and Duel.IsExistingTarget(c43405287.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的目标怪兽。
	Duel.SelectTarget(tp,c43405287.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时的操作信息为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 设置效果的处理流程为装备卡并增加攻击力。
function c43405287.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将此卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 设置装备卡的攻击力增加500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 设置装备卡的装备限制条件。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c43405287.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 设置装备卡只能装备给「命运英雄」怪兽或自身。
function c43405287.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsSetCard(0xc008)
end
-- 判断墓地中的卡是否为战斗破坏的。
function c43405287.damfilter(c,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc
end
-- 判断是否满足发动效果的条件。
function c43405287.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	return tc and eg:IsExists(c43405287.damfilter,1,nil,tc)
end
-- 设置效果的目标为对方玩家。
function c43405287.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的目标参数为500。
	Duel.SetTargetParam(500)
	-- 设置效果处理时的操作信息为造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 设置效果的处理流程为造成伤害。
function c43405287.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成500点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
