--アルティメット・バースト
-- 效果：
-- ①：以自己场上1只融合召唤的「青眼究极龙」为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作3次攻击，那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
function c43845801.initial_effect(c)
	-- 记录此卡具有「青眼究极龙」的卡片密码，用于后续效果判定
	aux.AddCodeList(c,23995346)
	-- ①：以自己场上1只融合召唤的「青眼究极龙」为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c43845801.condition)
	e1:SetTarget(c43845801.target)
	e1:SetOperation(c43845801.activate)
	c:RegisterEffect(e1)
end
-- 判断当前是否能进入战斗阶段
function c43845801.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 筛选满足条件的融合召唤的「青眼究极龙」怪兽（正面表示、融合召唤、卡片密码为23995346、未拥有额外攻击效果）
function c43845801.filter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_FUSION)
		and c:IsCode(23995346) and not c:IsHasEffect(EFFECT_EXTRA_ATTACK)
end
-- 设置效果目标选择函数，用于选择符合条件的「青眼究极龙」
function c43845801.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43845801.filter(chkc) end
	-- 检查是否满足选择目标的条件，即场上是否存在符合条件的「青眼究极龙」
	if chk==0 then return Duel.IsExistingTarget(c43845801.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的「青眼究极龙」作为效果对象
	Duel.SelectTarget(tp,c43845801.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时执行的操作，为对象怪兽增加攻击次数并设置对方不能发动效果
function c43845801.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽在同1次的战斗阶段中可以作3次攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽攻击的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetLabelObject(tc)
		e2:SetValue(1)
		e2:SetCondition(c43845801.actcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		-- 将效果e2注册给玩家tp，使其生效
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断攻击怪兽是否为当前效果对象
function c43845801.actcon(e)
	-- 判断当前攻击怪兽是否为效果对象怪兽
	return Duel.GetAttacker()==e:GetLabelObject()
end
