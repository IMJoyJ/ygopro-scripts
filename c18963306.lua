--銀河眼の光波竜
-- 效果：
-- 8星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，攻击力变成3000，卡名当作「银河眼光波龙」使用。这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
function c18963306.initial_effect(c)
	-- 为银河眼光波龙添加XYZ召唤手续：需要2只等级8的怪兽作为超量素材（8星怪兽×2）。
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetDescription(aux.Stringid(18963306,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c18963306.cost)
	e1:SetTarget(c18963306.target)
	e1:SetOperation(c18963306.operation)
	c:RegisterEffect(e1)
end
-- 代价处理：检查是否可以移除这张卡的1个超量素材作为代价；可以则移除1个超量素材（REASON_COST），对应“把这张卡1个超量素材取除”。
function c18963306.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数：选择对方场上表侧表示且控制权可以变更的怪兽作为可取得控制权的对象。
function c18963306.filter(c)
	return c:IsFaceup() and c:IsControlerCanBeChanged()
end
-- 目标选择：确认对象必须是对方怪兽区表侧表示且控制权可变更的怪兽；在发动时选择1只，并登记为改变控制权的操作信息。
function c18963306.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c18963306.filter(chkc) end
	-- 发动条件判断：检查对方场上是否存在至少1只满足条件的表侧表示怪兽可选作对象。
	if chk==0 then return Duel.IsExistingTarget(c18963306.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示框，提示玩家选择“要改变控制权的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家选择一只对方场上符合条件的怪兽作为效果对象，并自动登记为连锁对象。
	local g=Duel.SelectTarget(tp,c18963306.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本连锁为改变控制权效果，对象为g，数量1。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：先给这张卡以外的自己怪兽附加不能直接攻击的限制（直到结束阶段）；再取得对象怪兽，若对象仍与效果关联、不免疫且控制权可转移，则将对象怪兽的效果无效化、攻击力变成3000、卡名当作「银河眼光波龙」，并直到结束阶段获得其控制权。
function c18963306.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时这张卡以外的自己怪兽不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c18963306.atktg)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不能直接攻击”的永续效果注册到当前玩家，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	-- 取出效果发动时选择的对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) and tc:IsControlerCanBeChanged() then
		if tc:IsFaceup() then
			-- 使与对象怪兽相关的连锁无效化，配合后续将其效果无效化的处理。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
			-- 攻击力变成3000。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetCode(EFFECT_SET_ATTACK_FINAL)
			e4:SetValue(3000)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e4)
			-- 卡名当作「银河眼光波龙」使用。
			local e5=Effect.CreateEffect(c)
			e5:SetType(EFFECT_TYPE_SINGLE)
			e5:SetCode(EFFECT_CHANGE_CODE)
			e5:SetValue(18963306)
			e5:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e5)
		end
		-- 直到结束阶段获得对象怪兽的控制权。
		Duel.GetControl(tc,tp,PHASE_END,1)
	end
end
-- 禁止直接攻击效果的过滤函数：e的Label记录发动效果的这张卡（银河眼光波龙）的FieldID，若被检测怪兽的FieldID不同，则视为“这张卡以外的自己怪兽”，禁止其直接攻击。
function c18963306.atktg(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
