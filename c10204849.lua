--フルール・ド・フルーレ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的③的效果1回合只能使用1次。
-- ①：以自己墓地1只2星以下的怪兽为对象才能把这张卡发动。那只怪兽效果无效特殊召唤，把这张卡装备。这张卡从场上离开时那只怪兽破坏。
-- ②：装备怪兽的攻击力上升700。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。选自己场上1只同调怪兽把这张卡装备。
function c10204849.initial_effect(c)
	-- 作为一张卡的发动：以自己墓地1只2星以下的怪兽为对象才能发动。那只怪兽效果无效特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,10204849+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c10204849.target)
	e1:SetOperation(c10204849.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升700。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(700)
	c:RegisterEffect(e3)
	-- 这张卡从魔法与陷阱区域送去墓地的场合可以发动。选自己场上1只同调怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,10204849)
	e4:SetCondition(c10204849.eqcon)
	e4:SetTarget(c10204849.eqtg)
	e4:SetOperation(c10204849.eqop)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地2星以下且可以特殊召唤的怪兽。
function c10204849.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动时的对象选择与效果处理准备。
function c10204849.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10204849.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的2星以下怪兽。
		and Duel.IsExistingTarget(c10204849.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示语：选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只符合条件的2星以下怪兽为对象选择。
	local g=Duel.SelectTarget(tp,c10204849.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置装备卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 卡片发动时的特殊召唤与装备处理逻辑。
function c10204849.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选择为特殊召唤对象的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试将目标怪兽以表侧表示特殊召唤到场上（进入特殊召唤步骤）。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		-- 将这张卡装备给该怪兽。
		Duel.Equip(tp,c,tc)
		-- 为装备卡添加装备限制，使其只能装备于该怪兽。
		local e3=Effect.CreateEffect(tc)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c10204849.eqlimit)
		c:RegisterEffect(e3)
		-- 在这张卡离场前，检查其是否处于效果被无效的状态。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EVENT_LEAVE_FIELD_P)
		e4:SetOperation(c10204849.checkop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e4)
		-- 在这张卡离开场上时，若其离场前未被无效，则触发破坏装备怪兽的逻辑。
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e5:SetCode(EVENT_LEAVE_FIELD)
		e5:SetOperation(c10204849.desop)
		e5:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e5:SetLabelObject(e4)
		c:RegisterEffect(e5)
	end
	-- 完成特殊召唤的后续流程处理。
	Duel.SpecialSummonComplete()
end
-- 装备限制的条件判断函数：仅当装备卡所有者为该卡时才可装备。
function c10204849.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 在装备卡离开场上时，记录其是否在效果无效状态下离场。
function c10204849.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 执行装备卡离场时破坏装备怪兽的逻辑。
function c10204849.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 将装备怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断这张卡是否是从魔法与陷阱区域送去墓地。
function c10204849.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤自己场上表侧表示的同调怪兽。
function c10204849.eqfilter(c)
	return c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 送墓后重新装备效果的启动与对象确认逻辑。
function c10204849.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上的魔法与陷阱区域是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以被装备的同调怪兽。
		and Duel.IsExistingMatchingCard(c10204849.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置装备自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置此卡离开墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行将此卡重新装备给场上同调怪兽的操作。
function c10204849.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 提示语：选择要装备的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上的1只同调怪兽为装备对象。
	local g=Duel.SelectMatchingCard(tp,c10204849.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡装备给被选中的同调怪兽。
		Duel.Equip(tp,c,tc)
		-- 为重新装备的卡添加装备限制。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c10204849.eqlimit)
		c:RegisterEffect(e1)
	end
end
