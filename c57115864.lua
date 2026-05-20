--光子化
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，自己场上表侧表示存在的1只光属性怪兽的攻击力直到下次的自己的结束阶段时上升那只对方怪兽的攻击力数值。
function c57115864.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。把1只对方怪兽的攻击无效，自己场上表侧表示存在的1只光属性怪兽的攻击力直到下次的自己的结束阶段时上升那只对方怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c57115864.condition)
	e1:SetTarget(c57115864.target)
	e1:SetOperation(c57115864.activate)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件函数
function c57115864.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方（即对方怪兽攻击宣言时）
	return tp~=Duel.GetTurnPlayer()
end
-- 定义效果的目标选择与发动合法性检查函数
function c57115864.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e)
		-- 并且自己场上存在至少1只表侧表示的光属性怪兽
		and Duel.IsExistingMatchingCard(c57115864.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 将攻击怪兽设置为效果处理的对象
	Duel.SetTargetCard(tg)
end
-- 过滤条件：自己场上表侧表示的光属性怪兽
function c57115864.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 定义效果处理（发动）函数
function c57115864.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该怪兽的攻击
	Duel.NegateAttack()
	-- 获取作为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 向玩家发送提示信息，要求选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 让玩家从自己场上选择1只表侧表示的光属性怪兽
		local g=Duel.SelectMatchingCard(tp,c57115864.filter,tp,LOCATION_MZONE,0,1,1,nil)
		local ac=g:GetFirst()
		if ac then
			-- 自己场上表侧表示存在的1只光属性怪兽的攻击力直到下次的自己的结束阶段时上升那只对方怪兽的攻击力数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(tc:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
			ac:RegisterEffect(e1)
		end
	end
end
