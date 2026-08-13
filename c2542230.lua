--スカーレッド・コクーン
-- 效果：
-- ①：以自己场上1只龙族同调怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的场合，直到那次伤害步骤结束时对方场上的全部表侧表示怪兽的效果无效化。
-- ③：这张卡被送去墓地的回合的结束阶段，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
function c2542230.initial_effect(c)
	-- 将卡号70902743（红莲魔龙）登记为这张卡上记载的卡名，用于获取卡名关联信息。
	aux.AddCodeList(c,70902743)
	-- ①：以自己场上1只龙族同调怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c2542230.cost)
	e1:SetTarget(c2542230.target)
	e1:SetOperation(c2542230.activate)
	c:RegisterEffect(e1)
	-- ③：这张卡被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c2542230.regop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合的结束阶段，以自己墓地1只「红莲魔龙」为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2542230,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetHintTiming(TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(c2542230.spcon)
	e3:SetTarget(c2542230.sptg)
	e3:SetOperation(c2542230.spop)
	c:RegisterEffect(e3)
end
-- 发动时无实际代价的cost处理：记录当前连锁ID，给自己附加本次连锁内留在场上的誓约效果，并注册一个连锁被无效时取消本卡送去墓地处理的辅助效果。
function c2542230.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的连锁ID，用于在后续连锁被无效时识别是否为本连锁。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只龙族同调怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c2542230.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 把该辅助效果注册到当前玩家场上，以监听本连锁被无效的事件。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：若被无效的连锁ID与本次发动一致，且这张卡仍与该连锁关联，则取消这张卡被送去墓地的处理，使其留在场上。
function c2542230.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得被无效的连锁的连锁ID，与之前记录的本次发动连锁ID进行比较。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选条件是表侧表示、龙族、同调怪兽的卡片，作为这张卡的装备对象。
function c2542230.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 目标处理：检查对象是否合法；若为回应用户选择对象则验证是否为符合条件且位于自己主要怪兽区的龙族同调怪兽，若为发动确认则确认存在至少1个可选对象。
function c2542230.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2542230.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 确认自己场上存在至少1只满足条件的龙族同调怪兽可作为装备对象。
		and Duel.IsExistingTarget(c2542230.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只符合条件的龙族同调怪兽，将其设为这张卡装备效果的对象。
	Duel.SelectTarget(tp,c2542230.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 向系统登记本次连锁含有装备卡操作，操作目标为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍在魔陷区且与发动连锁关联，则获取装备对象；对象仍关联且表侧表示时，将这张卡装备给对象，并注册装备限制效果与战斗时无效对方怪兽效果的永续效果，随后刷新无效状态；若对象不合法则取消这张卡送去墓地的处理。
function c2542230.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 取得发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c2542230.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ②：用这张卡的效果把这张卡装备的怪兽和对方怪兽进行战斗的场合，直到那次伤害步骤结束时对方场上的全部表侧表示怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetRange(LOCATION_SZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetCondition(c2542230.discon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 手动刷新场上卡的无效状态，使新注册的无效对方怪兽效果立即生效。
		Duel.AdjustInstantly(c)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制的判定：这张卡只能装备给当前装备对象，或装备给这张卡的持有者场上的龙族同调怪兽。
function c2542230.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_SYNCHRO)
end
-- 无效效果的条件：这张卡装备的怪兽是攻击怪兽或攻击对象时，即装备怪兽正在参与战斗。
function c2542230.discon(e)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判断装备怪兽是否为本次战斗的攻击方或被攻击方，若是则满足②的无效条件。
	return Duel.GetAttacker()==ec or Duel.GetAttackTarget()==ec
end
-- 这张卡被送去墓地时，给自己打上标记2542230，该标记持续到结束阶段重置，用于记录“这张卡被送去墓地的回合”。
function c2542230.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(2542230,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ③的发动条件：这张卡本回合有被送去墓地的标记，且当前是结束阶段。
function c2542230.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认存在被送去墓地标记且当前阶段为结束阶段。
	return c:GetFlagEffect(2542230)~=0 and Duel.GetCurrentPhase()==PHASE_END
end
-- 筛选墓地中卡名为「红莲魔龙」且可以被特殊召唤的怪兽作为对象。
function c2542230.spfilter(c,e,tp)
	return c:IsCode(70902743) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的目标处理：检查自己主要怪兽区是否有空位，且墓地存在满足条件的「红莲魔龙」；同时处理对象选择合法性。
function c2542230.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2542230.spfilter(chkc,e,tp) end
	-- 发动条件确认：自己场上存在至少1个可用的主要怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地存在至少1只满足特殊召唤条件的「红莲魔龙」可作为对象。
		and Duel.IsExistingTarget(c2542230.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只「红莲魔龙」，将其登记为特殊召唤的对象。
	local g=Duel.SelectTarget(tp,c2542230.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本次连锁含有特殊召唤操作，对象为所选的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理：若对象仍与效果关联，则将对象以表侧攻击表示特殊召唤到自己的场上。
function c2542230.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③选择的对象卡（墓地中的「红莲魔龙」）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象「红莲魔龙」特殊召唤到发动者场上，表示形式为表侧攻击表示，并正常检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
