--ペンギン魚雷
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡可以直接攻击。
-- ②：这张卡给与对方战斗伤害时，以对方场上1只6星以下的怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，不能攻击宣言。
-- ③：这张卡攻击的伤害步骤结束时发动。这张卡破坏。
function c17679043.initial_effect(c)
	-- ①：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡给与对方战斗伤害时，以对方场上1只6星以下的怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17679043,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,17679043)
	e2:SetCondition(c17679043.ctrcon)
	e2:SetTarget(c17679043.ctrtg)
	e2:SetOperation(c17679043.ctrop)
	c:RegisterEffect(e2)
	-- ③：这张卡攻击的伤害步骤结束时发动。这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17679043,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c17679043.descon)
	e3:SetTarget(c17679043.destg)
	e3:SetOperation(c17679043.desop)
	c:RegisterEffect(e3)
end
-- 发动条件判断：企鹅鱼雷造成战斗伤害的玩家必须是对方（即ep为对方，而不是自己）。
function c17679043.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 对象筛选条件：对方的表侧表示怪兽，等级6以下，且控制权可以被改变。
function c17679043.ctrfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsControlerCanBeChanged()
end
-- 效果发动时的取对象处理：从对方场上选择1只符合条件的6星以下表侧表示怪兽，并登记改变控制权的操作信息。
function c17679043.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c17679043.ctrfilter(chkc) end
	-- 发动时检查对方场上是否存在至少1只符合条件的可选取对象怪兽。
	if chk==0 then return Duel.IsExistingTarget(c17679043.ctrfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要改变控制权的怪兽”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 让玩家从对方场上选择1只符合条件的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c17679043.ctrfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记本次操作为改变1只怪兽的控制权，供连锁处理和相关判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：获得对象怪兽的控制权直到结束阶段；若对象为表侧表示则将其效果无效化，并使其不能攻击宣言。
function c17679043.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对方场上那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果处理相关且成功获得其控制权直到结束阶段。
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		if tc:IsFaceup() then
			-- 使与该对象怪兽相关的连锁效果无效化，并在其变里侧时重置。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 这个效果得到控制权的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 不能攻击宣言。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- ③效果的发动条件：本次攻击的怪兽是企鹅鱼雷自身，且它仍与战斗关联（即伤害步骤结束时触发）。
function c17679043.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前攻击怪兽为企鹅鱼雷自身，且自身仍与本次战斗关联。
	return Duel.GetAttacker()==e:GetHandler() and e:GetHandler():IsRelateToBattle()
end
-- ③效果的目标处理：无需选择对象，必定发动，并登记破坏自身的操作信息。
function c17679043.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记将企鹅鱼雷自身破坏的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ③效果处理：若企鹅鱼雷仍与本次战斗关联，则将其破坏。
function c17679043.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 以效果原因将企鹅鱼雷自身破坏。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
