--アルティメット・バースト
-- 效果：
-- ①：以自己场上1只融合召唤的「青眼究极龙」为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作3次攻击，那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c43845801.initial_effect(c)
	-- 将卡号23995346（青眼究极龙）登记到本卡的代码列表，用于识别效果描述中涉及的「青眼究极龙」卡名。
	aux.AddCodeList(c,23995346)
	-- ①：以自己场上1只融合召唤的「青眼究极龙」为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作3次攻击，那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c43845801.condition)
	e1:SetTarget(c43845801.target)
	e1:SetOperation(c43845801.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件：当前回合玩家必须能够进入战斗阶段才能发动此卡。
function c43845801.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否能够进入战斗阶段，若不能则无法发动。
	return Duel.IsAbleToEnterBP()
end
-- 定义可选择对象：满足表侧表示、融合召唤、卡号为23995346（青眼究极龙）且未受额外攻击次数效果影响的我方怪兽。
function c43845801.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsCode(23995346) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 效果发动时的目标处理：先校验连锁对象是否合法，再确认存在合法对象并让玩家选择1只符合条件的青眼究极龙作为效果对象。
function c43845801.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43845801.filter(chkc) end
	-- 发动时点确认自己场上存在至少1只符合条件的「青眼究极龙」，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c43845801.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作玩家显示选择提示，提示内容为“请选择效果的对象”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作玩家从自己场上选择1只符合条件的「青眼究极龙」设为效果对象，并记录为当前连锁对象。
	Duel.SelectTarget(tp,c43845801.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象后，为该青眼究极龙附加本回合可额外攻击2次的效果，并为对手附加“该怪兽攻击时不能发动魔法·陷阱·怪兽效果”的限制。
function c43845801.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选定的对象怪兽（青眼究极龙）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作3次攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetLabelObject(tc)
		e2:SetValue(1)
		e2:SetCondition(c43845801.actcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 将对手玩家不能发动魔法·陷阱·怪兽效果的领域效果注册到场上，持续至回合结束。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义限制效果的发动条件：仅当当前攻击怪兽是本效果选定的对象时，才对对手适用不能发动效果的限制。
function c43845801.actcon(e)
	-- 判断当前进行攻击的怪兽是否就是被选择为对象的「青眼究极龙」。
	return Duel.GetAttacker()==e:GetLabelObject()
end
