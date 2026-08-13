--電脳増幅器
-- 效果：
-- 「人造人-念力震慑者」才能装备。这张卡的发动和效果不会被无效化。
-- ①：装备怪兽持有的「双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化」效果作为「对方不能把场上的陷阱卡的效果发动，对方场上的陷阱卡的效果无效化」适用。
-- ②：这张卡从场上离开时装备怪兽破坏。
function c303660.initial_effect(c)
	-- 将卡号77585513（人造人-念力震慑者）登记到这张卡的代码列表中，用于标记本卡效果文本涉及该卡名，方便系统关联识别。
	aux.AddCodeList(c,77585513)
	-- 「人造人-念力震慑者」才能装备。这张卡的发动和效果不会被无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetTarget(c303660.target)
	e1:SetOperation(c303660.operation)
	c:RegisterEffect(e1)
	-- 「人造人-念力震慑者」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c303660.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽持有的「双方不能把场上的陷阱卡的效果发动，场上的陷阱卡的效果无效化」效果作为「对方不能把场上的陷阱卡的效果发动，对方场上的陷阱卡的效果无效化」适用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(303660)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
	-- ②：这张卡从场上离开时装备怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetOperation(c303660.desop)
	c:RegisterEffect(e4)
	-- 这张卡的发动和效果不会被无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_DISABLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e5)
end
-- 装备限制函数：判定装备对象只能是卡号为77585513的「人造人-念力震慑者」。
function c303660.eqlimit(e,c)
	return c:IsCode(77585513)
end
-- 过滤函数：判定卡是表侧表示且卡号为77585513，即表侧表示的「人造人-念力震慑者」。
function c303660.filter(c)
	return c:IsFaceup() and c:IsCode(77585513)
end
-- 发动时的目标选择处理：若chkc为指定对象则检查其是否符合对象条件；发动合法时从双方怪兽区域中选择1只满足条件的怪兽作为装备对象，并设置操作信息为装备。
function c303660.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c303660.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在至少1只表侧表示的「人造人-念力震慑者」可以作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c303660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择装备对象，显示“请选择要装备的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域中选择1只满足条件的表侧表示「人造人-念力震慑者」作为装备对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c303660.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表明本连锁的处理将进行装备，涉及对象为这张装备卡自身，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理：若这张卡和目标怪兽均仍与效果关联且目标怪兽表侧表示，则将这张卡装备给目标怪兽。
function c303660.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡以玩家tp的名义装备给目标怪兽tc。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 离场破坏处理：这张卡从场上离开时，获取其装备的怪兽；若该怪兽仍在怪兽区域，则将其破坏。
function c303660.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因将装备怪兽tc破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
