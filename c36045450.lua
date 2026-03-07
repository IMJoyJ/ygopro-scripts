--マジシャンズ・クロス
-- 效果：
-- ①：自己场上有攻击表示的魔法师族怪兽2只以上存在的场合，以那之内的1只为对象才能发动。那只怪兽的攻击力直到回合结束时变成3000。这张卡的发动后，直到回合结束时那只怪兽以外的魔法师族怪兽不能攻击。
function c36045450.initial_effect(c)
	-- 效果原文内容：①：自己场上有攻击表示的魔法师族怪兽2只以上存在的场合，以那之内的1只为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c36045450.condition)
	e1:SetTarget(c36045450.target)
	e1:SetOperation(c36045450.operation)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选表侧攻击表示的魔法师族怪兽
function c36045450.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsRace(RACE_SPELLCASTER)
end
-- 规则层面作用：判断自己场上有至少2只表侧攻击表示的魔法师族怪兽
function c36045450.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查满足条件的魔法师族怪兽数量是否不少于2只
	return Duel.IsExistingMatchingCard(c36045450.filter,tp,LOCATION_MZONE,0,2,nil)
end
-- 规则层面作用：设置效果的目标选择函数，用于选择1只表侧攻击表示的魔法师族怪兽
function c36045450.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36045450.filter(chkc) end
	-- 规则层面作用：检查是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(c36045450.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 规则层面作用：向玩家提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面作用：选择1只表侧攻击表示的魔法师族怪兽作为效果对象
	Duel.SelectTarget(tp,c36045450.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 规则层面作用：执行效果的处理流程，包括改变目标怪兽攻击力和禁止其他魔法师族怪兽攻击
function c36045450.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 效果原文内容：那只怪兽的攻击力直到回合结束时变成3000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(3000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 效果原文内容：这张卡的发动后，直到回合结束时那只怪兽以外的魔法师族怪兽不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c36045450.ftarget)
	e1:SetLabel(tc:GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面作用：将效果注册给指定玩家
	Duel.RegisterEffect(e1,tp)
end
-- 规则层面作用：定义用于判断是否禁止攻击的目标怪兽的过滤函数
function c36045450.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID() and c:IsRace(RACE_SPELLCASTER)
end
