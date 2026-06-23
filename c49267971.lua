--死角からの一撃
-- 效果：
-- 选择对方场上表侧守备表示存在的1只怪兽和自己场上表侧攻击表示存在的1只怪兽发动。选择的自己怪兽的攻击力直到结束阶段时上升选择的对方怪兽的守备力数值。
function c49267971.initial_effect(c)
	-- 效果发动条件：选择对方场上表侧守备表示存在的1只怪兽和自己场上表侧攻击表示存在的1只怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c49267971.target)
	e1:SetOperation(c49267971.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件，即对方场上有表侧守备表示的怪兽，且自己场上有表侧攻击表示的怪兽。
function c49267971.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在表侧守备表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsPosition,tp,0,LOCATION_MZONE,1,nil,POS_FACEUP_DEFENSE)
		-- 检查自己场上是否存在表侧攻击表示的怪兽。
		and Duel.IsExistingTarget(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_ATTACK) end
	-- 提示玩家选择对方场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上表侧守备表示的1只怪兽作为目标。
	local g1=Duel.SelectTarget(tp,Card.IsPosition,tp,0,LOCATION_MZONE,1,1,nil,POS_FACEUP_DEFENSE)
	-- 提示玩家选择自己场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上表侧攻击表示的1只怪兽作为目标。
	local g2=Duel.SelectTarget(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_ATTACK)
	e:SetLabelObject(g1:GetFirst())
end
-- 处理效果的发动，将选择的对方怪兽的守备力数值加到己方怪兽的攻击力上。
function c49267971.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc1=e:GetLabelObject()
	-- 获取当前连锁中的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc2=g:GetFirst()
	if tc1==tc2 then tc2=g:GetNext() end
	if tc1:IsRelateToEffect(e) and tc1:IsFaceup() and tc2:IsRelateToEffect(e) and tc2:IsFaceup() then
		-- 使己方怪兽的攻击力上升对方怪兽的守备力数值直到结束阶段。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc1:GetDefense())
		tc2:RegisterEffect(e1)
	end
end
