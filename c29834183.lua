--グレイドル・イーグル
-- 效果：
-- ①：自己的怪兽区域的这张卡被战斗或者怪兽的效果破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只对方怪兽装备。
-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。这张卡从场上离开时装备怪兽破坏。
function c29834183.initial_effect(c)
	-- ①：自己的怪兽区域的这张卡被战斗或者怪兽的效果破坏送去墓地的场合，以对方场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只对方怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP+CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c29834183.eqcon)
	e1:SetTarget(c29834183.eqtg)
	e1:SetOperation(c29834183.eqop)
	c:RegisterEffect(e1)
end
-- 判定①的诱发条件：这张卡必须是被战斗破坏，或被怪兽效果破坏后送去墓地，且破坏前控制权属于我方、位于我方怪兽区域，才满足发动条件。
function c29834183.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and re:IsActiveType(TYPE_MONSTER)))
		and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 选择装备对象时的过滤函数：对象必须是对方场上的表侧表示怪兽，且我方魔陷区有空位可放置装备卡；若对象是陷阱怪兽，还需额外检查魔陷区的剩余空格。
function c29834183.eqfilter(c,tp)
	if c:IsFacedown() then return false end
	-- 对象为陷阱怪兽时，额外要求我方魔陷区在控制权变更判定与常规判定下均有足够空格（至少分别>0和>=2），以保证装备卡能成功装备。
	if c:IsType(TYPE_TRAPMONSTER) then return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,LOCATION_REASON_CONTROL)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE,tp,0)>=2 end
	return true
end
-- ①效果的发动条件与取对象处理：先检查我方魔陷区是否有空位，且对方场上有满足条件的表侧表示怪兽；再从中选择1只作为装备对象。
function c29834183.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c29834183.eqfilter(chkc,tp) end
	-- 发动条件检查：我方魔陷区必须至少存在1个空格，用于之后放置这张装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：确认对方场上存在至少1只满足eqfilter条件的表侧表示怪兽，可以作为装备对象。
		and Duel.IsExistingTarget(c29834183.eqfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 发送UI提示信息，让操作者选择要装备的卡（显示'请选择要装备的卡'）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从对方场上选择1只符合条件的表侧表示怪兽作为装备对象，并将其设置为当前连锁的对象。
	Duel.SelectTarget(tp,c29834183.eqfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：声明这张卡将从墓地离开（涉及墓地效果），供其他卡进行联动或响应。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 装备限制函数：将这张装备卡的目标限定为发动时选择的那只怪兽（用LabelObject保存），只能装备给它。
function c29834183.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ①效果的处理：若魔陷区仍有空位且对象合法，把这张卡当作装备卡装备给对象怪兽，同时注册②所需的获得控制权与离场破坏效果。
function c29834183.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认魔陷区有空位；若没有空位则直接终止本次装备处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 取得发动时选择的对象怪兽（装备目标）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 将这张卡作为装备卡，以我方控制者的身份装备给目标怪兽。
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只对方怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c29834183.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		-- ②：这张卡的效果让这张卡装备中的场合，得到装备怪兽的控制权。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 这张卡从场上离开时
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EVENT_LEAVE_FIELD_P)
		e3:SetOperation(c29834183.checkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
		-- 这张卡从场上离开时装备怪兽破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
		e4:SetCode(EVENT_LEAVE_FIELD)
		e4:SetOperation(c29834183.desop)
		e4:SetReset(RESET_EVENT+RESET_OVERLAY+RESET_TOFIELD)
		e4:SetLabelObject(e3)
		c:RegisterEffect(e4)
	end
end
-- 离场前记录这张装备卡是否处于效果无效状态：无效则标记为1，否则为0；该标记供离场破坏处理判断是否执行破坏。
function c29834183.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 离场时的破坏处理：重置自身效果后，若离场前未被无效化，则破坏装备怪兽；若已被无效化则跳过破坏。
function c29834183.desop(e,tp,eg,ep,ev,re,r,rp)
	e:Reset()
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetEquipTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏装备怪兽（对应②的‘装备怪兽破坏’）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
