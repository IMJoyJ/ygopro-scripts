--デュアル・ブースター
-- 效果：
-- ①：以自己场上1只二重怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
-- ②：当作装备卡使用的这张卡被破坏送去墓地的场合，以场上1只二重怪兽为对象发动。那只二重怪兽变成再1次召唤的状态。
function c18096222.initial_effect(c)
	-- ①：以自己场上1只二重怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果①的发动条件：仅限伤害步骤且尚未进行伤害计算时才能发动（配合EFFECT_FLAG_DAMAGE_STEP，保证伤害步骤中只能在伤害计算前发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c18096222.cost)
	e1:SetTarget(c18096222.target)
	e1:SetOperation(c18096222.operation)
	c:RegisterEffect(e1)
	-- ②：当作装备卡使用的这张卡被破坏送去墓地的场合，以场上1只二重怪兽为对象发动。那只二重怪兽变成再1次召唤的状态。
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
-- 效果①的cost处理：实际无cost；为发动中的这张卡附加“连锁处理结束前留在场上”的誓约效果，并注册当本次连锁被无效时的回调，防止卡片因发动被无效而错误离场。
function c18096222.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于标记本次发动的连锁，后续判断该连锁是否被无效。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 以自己场上1只二重怪兽为对象才能把这张卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只二重怪兽为对象才能把这张卡发动。这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c18096222.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将监视“连锁被无效”的持续效果注册到当前玩家，若本次发动被无效则执行对应补救处理。
	Duel.RegisterEffect(e2,tp)
end
-- 当本次发动的连锁被无效时，若这张装备卡仍与连锁关联，则取消它被送去墓地的处理，使其保持在场上（配合EFFECT_REMAIN_FIELD实现发动被无效时不入墓地）。
function c18096222.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的ID，与之前记录的本次连锁ID比较，以确认是否为本卡的连锁被无效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：表侧表示的二重怪兽，用作效果①的装备对象候选。
function c18096222.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 效果①的取对象判定：若为连锁处理中的重选目标，则检查目标是否满足条件；若为发动时点，则确认自己场上存在表侧二重怪兽可作为对象，且cost已被检查。
function c18096222.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c18096222.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己怪兽区是否存在至少1只表侧二重怪兽可作为这张卡的装备对象。
		and Duel.IsExistingTarget(c18096222.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向当前玩家显示“请选择要装备的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只满足条件的表侧二重怪兽，将其设为这张卡装备的对象。
	Duel.SelectTarget(tp,c18096222.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：声明本连锁处理包含装备卡的装备操作，供后续时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的解决处理：若这张卡仍在魔陷区且与效果关联，则将这张卡装备给对象怪兽，并赋予攻击力上升700和装备限制效果；若装备条件不满足，则取消将其送去墓地的处理。
function c18096222.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得效果①选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 将这张卡作为装备卡装备给目标怪兽（装备成功后该卡进入魔陷区）。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(700)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 这张卡当作攻击力上升700的装备卡使用给那只自己怪兽装备。
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
-- 装备限制判定：当目标为该装备卡当前装备对象，或是装备卡控制者场上的二重怪兽时，允许装备。
function c18096222.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_DUAL)
end
-- 效果②的触发条件：这张卡作为装备卡被破坏送去墓地，且破坏前有装备对象（包括因装备对象离场导致失去装备对象而被破坏的情况）。
function c18096222.dacon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if c:IsReason(REASON_LOST_TARGET) then
		ec=c:GetPreviousEquipTarget()
	end
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_DESTROY) and ec~=nil
end
-- 过滤条件：场上表侧表示的二重怪兽，且尚未处于再度召唤状态（可以被变为再度召唤状态）。
function c18096222.dafilter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL) and not c:IsDualState()
end
-- 效果②的目标选择：选择场上1只表侧表示且非再度召唤状态的二重怪兽作为对象（可选择双方场上的怪兽）。
function c18096222.datg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18096222.dafilter(chkc) end
	if chk==0 then return true end
	-- 提示当前玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择双方场上1只满足条件的二重怪兽作为效果②的对象。
	Duel.SelectTarget(tp,c18096222.dafilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的解决处理：将对象二重怪兽变为再度召唤状态（EnableDualState）。
function c18096222.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果②选择的对象二重怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c18096222.dafilter(tc) then
		tc:EnableDualState()
	end
end
