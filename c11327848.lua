--修士号ディプロマン
-- 效果：
-- ①：这张卡上级召唤成功的场合，以自己墓地1只怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只墓地的怪兽当作装备卡使用给那只对方怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力下降那个攻击力数值。
-- ②：只要这张卡在怪兽区域存在，有自己的魔法与陷阱区域的装备卡装备的对方怪兽的效果不能发动。
function c11327848.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，以自己墓地1只怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只墓地的怪兽当作装备卡使用给那只对方怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力下降那个攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11327848,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c11327848.eqcon)
	e1:SetTarget(c11327848.eqtg)
	e1:SetOperation(c11327848.eqop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，有自己的魔法与陷阱区域的装备卡装备的对方怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c11327848.aclimit)
	c:RegisterEffect(e2)
end
-- 判断触发条件：这张卡是否以表侧表示上级召唤成功（召唤类型为上级召唤），满足时效果才能发动。
function c11327848.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 筛选自己墓地中可作为装备卡的怪兽：必须为怪兽且未被禁止作为装备卡使用。
function c11327848.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 筛选对方场上表侧表示怪兽，作为装备卡装备的对象。
function c11327848.tgfilter(c)
	return c:IsFaceup()
end
-- 效果发动条件和取对象的检查：拒绝非连锁发动时的对象检查；在发动可行性check时，需确认自己墓地存在可选怪兽且对方场上有表侧表示怪兽。
function c11327848.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少1只满足装备卡选择条件的怪兽（可作为装备卡的怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c11327848.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方场上是否存在至少1只表侧表示怪兽可作为装备对象。
		and Duel.IsExistingTarget(c11327848.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在玩家选择墓地装备卡前，显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象，并设为装备卡候选。
	local g1=Duel.SelectTarget(tp,c11327848.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 在玩家选择对方怪兽前，显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从对方场上选择1只表侧表示怪兽作为装备对象（效果对象）。
	local g2=Duel.SelectTarget(tp,c11327848.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：标记有卡将离开墓地（用于响应墓地被移动的相关效果）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
end
-- 效果处理：获取连锁对象中的墓地怪兽和对方怪兽；若双方均存在且对方怪兽仍表侧表示，则记录墓地怪兽攻击力，将其装备给对方怪兽，并赋予装备限制和攻击力下降的永续效果。
function c11327848.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁所选择的对象卡，并筛选出仍与本次效果相关的卡片（未离场或未被无效）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc1 and tc2 and tc2:IsFaceup() then
		local atk=tc1:GetAttack()
		-- 执行装备操作，将墓地怪兽装备给对方怪兽；若装备失败则终止后续处理。
		if not Duel.Equip(tp,tc1,tc2,false) then return end
		-- 那只墓地的怪兽当作装备卡使用给那只对方怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc2)
		e1:SetValue(c11327848.eqlimit)
		tc1:RegisterEffect(e1)
		-- 只要这个效果把怪兽装备中，装备怪兽的攻击力下降那个攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(-atk)
		tc1:RegisterEffect(e2)
	end
end
-- 装备限制判定：仅允许该装备卡装备在当初指定的那只对方怪兽身上。
function c11327848.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果判定：对方发动的效果必须是怪兽效果，且该怪兽装备有自己控制的装备卡（即自己魔法与陷阱区域的装备卡装备的对方怪兽）。
function c11327848.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetEquipGroup():IsExists(Card.IsControler,1,nil,e:GetHandlerPlayer())
end
