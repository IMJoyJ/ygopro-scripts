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
	-- ②：这张卡给与对方战斗伤害时，以对方场上1只6星以下的怪兽为对象才能发动。那只怪兽的控制权直到结束阶段得到。这个效果得到控制权的怪兽的效果无效化，不能攻击宣言。
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
-- 效果发动条件：造成战斗伤害的玩家不是自己
function c17679043.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 筛选条件：对方场上满足等级不超过6且可以改变控制权的怪兽
function c17679043.ctrfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(6) and c:IsControlerCanBeChanged()
end
-- 选择对象：选择对方场上满足条件的1只怪兽作为目标
function c17679043.ctrtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c17679043.ctrfilter(chkc) end
	-- 确认是否有满足条件的怪兽可选
	if chk==0 then return Duel.IsExistingTarget(c17679043.ctrfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c17679043.ctrfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将目标怪兽的控制权变更作为效果处理内容
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 效果处理：将目标怪兽的控制权交给玩家，使其效果无效化并禁止攻击宣言
function c17679043.ctrop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且控制权变更成功
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp,PHASE_END,1)~=0 then
		if tc:IsFaceup() then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使目标怪兽的效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽的效果无效化
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
		-- 使目标怪兽不能攻击宣言
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 效果发动条件：本次战斗攻击的怪兽是自己且自己参与了战斗
function c17679043.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认本次战斗攻击的怪兽是自己且自己参与了战斗
	return Duel.GetAttacker()==e:GetHandler() and e:GetHandler():IsRelateToBattle()
end
-- 设置操作信息：将自己破坏作为效果处理内容
function c17679043.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将自己破坏作为效果处理内容
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：将自己破坏
function c17679043.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() then
		-- 将自己破坏
		Duel.Destroy(c,REASON_EFFECT)
	end
end
