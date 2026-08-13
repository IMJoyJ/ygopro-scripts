--捕食接ぎ木
-- 效果：
-- ①：以自己墓地1只「捕食植物」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
function c14463695.initial_effect(c)
	-- ①：以自己墓地1只「捕食植物」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c14463695.target)
	e1:SetOperation(c14463695.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c14463695.checkop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c14463695.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否属于「捕食植物」系列，并且是否可以被当前效果特殊召唤。
function c14463695.spfilter(c,e,tp)
	return c:IsSetCard(0x10f3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的目标选择与条件检查：确认存在可供选择的对象（墓地「捕食植物」怪兽），并确认场上可特殊召唤。
function c14463695.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14463695.spfilter(chkc,e,tp) end
	-- 发动条件：自己主要怪兽区存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件：墓地存在至少1只符合特殊召唤条件的「捕食植物」怪兽可作为效果对象。
		and Duel.IsExistingTarget(c14463695.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「捕食植物」怪兽，并设置为效果对象。
	local g=Duel.SelectTarget(tp,c14463695.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：本次效果将把这张卡装备给对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与效果关联，则将对象怪兽表侧表示特殊召唤，并把这张卡装备给它；随后为这张卡设置只能装备给该怪兽的限制。
function c14463695.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 将对象怪兽以表侧表示加入特殊召唤流程（若成功才能继续装备）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 把这张卡作为装备卡装备给对象怪兽。（如果特殊召唤不成功，装备不会执行。）
		Duel.Equip(tp,c,tc)
		-- 把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c14463695.eqlimit)
		c:RegisterEffect(e1)
	end
	-- 完成整个特殊召唤流程，确保特殊召唤成功或失败的结果被正确结算（之后才进行装备）。
	Duel.SpecialSummonComplete()
end
-- 装备限制函数：只有效果创建者（那只被特殊召唤的怪兽）才能成为这张卡的装备对象。
function c14463695.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 离场前记录：若这张卡处于无效状态则标记为1，否则标记为0，供离场破坏效果判断。
function c14463695.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场时处理：若离场前未标记无效，则获取这张卡当前装备的对象，若其还在场上则将其破坏。
function c14463695.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏该怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
