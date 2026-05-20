--ガオドレイクのタテガミ
-- 效果：
-- 选择自己场上表侧表示存在的1只名字带有「自然」的怪兽发动。选择的怪兽的攻击力直到结束阶段时变成3000，效果无效化。
function c57201737.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只名字带有「自然」的怪兽发动。选择的怪兽的攻击力直到结束阶段时变成3000，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c57201737.target)
	e1:SetOperation(c57201737.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「自然」的怪兽
function c57201737.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 效果发动的靶向与合法性检测（Target阶段）
function c57201737.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c57201737.filter(chkc) end
	-- 在发动阶段，检查自己场上是否存在至少1只符合过滤条件的怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c57201737.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 发送提示信息，要求玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的名字带有「自然」的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57201737.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，表示该连锁包含无效化卡片效果的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理阶段（Resolution阶段），对目标怪兽适用攻击力变化和效果无效化
function c57201737.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力直到结束阶段时变成3000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(3000)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
	end
end
