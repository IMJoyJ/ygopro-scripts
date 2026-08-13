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
	-- 设置①效果的发动条件：只能在伤害步骤且伤害计算前发动（伤害步骤后不能发动）。
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
-- ①效果的cost处理：实际支付cost为空，但发动时为这张卡附加誓约保护（留在场上），并注册连锁被无效时的回收效果，防止发动被无效时卡片直接送去墓地。
function c13317419.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动的连锁ID，用于标记本次发动，以便在连锁被无效时准确判断。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 对应①效果的发动：以自己场上1只攻击力800以上的攻击表示怪兽为对象才能把这张卡发动。此处为发动时附加的誓约保护，使这张卡在连锁处理完前不会被送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只攻击力800以上的攻击表示怪兽为对象才能把这张卡发动。这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。（含发动被无效时的回收处理）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c13317419.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监听“连锁被无效”事件的辅助效果注册到全场，使本次①效果发动被无效时能回收这张卡。
	Duel.RegisterEffect(e2,tp)
end
-- 辅助操作：当检测到本次发动的连锁被无效且这张卡仍与连锁关联时，取消它被送去墓地的预定，使其不去墓地。
function c13317419.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID，与本次发动时记录的连锁ID比较，确认是否为本次发动被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- ①效果选择对象的过滤条件：表侧攻击表示且攻击力800以上的怪兽。
function c13317419.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttackAbove(800)
end
-- ①效果的发动目标处理：在发动时确认cost已满足且存在合法对象，并校验目标是否符合条件。
function c13317419.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c13317419.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在至少1只满足条件（表侧攻击表示且攻击力800以上）的怪兽。
		and Duel.IsExistingTarget(c13317419.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给玩家显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上选择1只表侧攻击表示且攻击力800以上的怪兽作为装备对象（取对象）。
	Duel.SelectTarget(tp,c13317419.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果将进行装备操作，对象为这张卡自身，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ①效果的解决处理：若这张卡仍在魔陷区且与效果关联，则将它装备给对象怪兽，并赋予攻击力上升800的装备效果；若对象不合法则不去墓地。
function c13317419.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 攻击力上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作攻击力上升800的装备卡使用给那只怪兽装备。（此处为装备限制，使装备卡只能装备给原对象或满足条件的怪兽）
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
-- 装备限制判定：允许装备给当前实际装备的怪兽，或装备给自己场上表侧攻击表示且攻击力800以上的怪兽。
function c13317419.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttackAbove(800)
end
-- ②效果的发动条件：这张卡有装备对象（正装备在怪兽上）。
function c13317419.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end
-- ②效果的发动代价：将装备中的这张卡送去墓地，并记录其原本装备的怪兽。
function c13317419.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 把作为代价的这张卡送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果的目标过滤条件：场上表侧表示的卡。
function c13317419.desfilter(c)
	return c:IsFaceup()
end
-- ②效果的发动目标处理：选择场上1张表侧表示的卡为破坏对象，并设置破坏的操作信息。
function c13317419.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c13317419.desfilter(chkc) end
	-- 检查场上是否存在1张表侧表示的可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(c13317419.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1张表侧表示的卡作为破坏对象（取对象）。
	local g=Duel.SelectTarget(tp,c13317419.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果将进行破坏，数量1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的解决处理：破坏对象；若破坏成功且原装备怪兽仍在场上表侧表示，则将其攻击力变成0，并使其不能改变表示形式。
function c13317419.desop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 获取②效果选择的破坏对象。
	local tc=Duel.GetFirstTarget()
	-- 若破坏对象仍与效果关联，则将其破坏；只有破坏成功才继续后续处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and ec and ec:IsFaceup() and ec:IsLocation(LOCATION_MZONE) then
		-- 中断当前效果，使后续攻击力变更和表示形式限制作为另一次效果处理，避免与时点冲突。
		Duel.BreakEffect()
		-- 这张卡装备过的怪兽攻击力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 不能把表示形式变更。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2)
	end
end
