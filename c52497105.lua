--蛮勇鱗粉
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力上升1000，这个回合不能向对方玩家直接攻击。这个回合的结束阶段时，选择的怪兽的攻击力下降2000。
function c52497105.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽才能发动。选择的怪兽的攻击力上升1000，这个回合不能向对方玩家直接攻击。这个回合的结束阶段时，选择的怪兽的攻击力下降2000。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为伤害步骤且尚未进行伤害计算时才能发动（防止在伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c52497105.target)
	e1:SetOperation(c52497105.activate)
	c:RegisterEffect(e1)
end
-- 定义可选择的怪兽过滤函数：必须为表侧表示，并且在伤害步骤中不能选择没有攻击对象的攻击怪兽（若存在攻击对象则允许）。
function c52497105.filter(c)
	-- 过滤条件具体为：怪兽表侧表示，且当前不在伤害步骤，或该怪兽不是攻击者，或此时存在攻击目标。
	return c:IsFaceup() and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or c~=Duel.GetAttacker() or Duel.GetAttackTarget())
end
-- 目标选择函数：在效果发动时进行取对象，从自己场上表侧表示怪兽中选择1只，并检查是否能选择。
function c52497105.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c52497105.filter(chkc) end
	-- 发动合法性检查：若在检查发动条件阶段（chk==0），确认自己场上是否存在至少1只符合条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c52497105.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上的表侧表示怪兽中选择1只，并将其登记为效果处理时的对象。
	Duel.SelectTarget(tp,c52497105.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数：若对象怪兽仍与效果相关且表侧表示，则赋予其攻击力上升1000、不能直接攻击，并在结束阶段攻击力下降的效果。
function c52497105.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		-- 这个回合不能向对方玩家直接攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 这个回合的结束阶段时，选择的怪兽的攻击力下降2000。
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetOperation(c52497105.atkdown)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
-- 结束阶段时执行的下降攻效果：给对象施加-1000攻击力（配合此前的上升效果在结束阶段失效，最终使攻击力比原始值下降1000）。
function c52497105.atkdown(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合的结束阶段时，选择的怪兽的攻击力下降2000。
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1,true)
end
