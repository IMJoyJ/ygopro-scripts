--財宝への隠し通路
-- 效果：
-- 选择自己场上的1只表侧表示存在的攻击力1000以下的怪兽。这个回合，选择的怪兽可以直接攻击对方玩家。
function c77876207.initial_effect(c)
	-- 选择自己场上的1只表侧表示存在的攻击力1000以下的怪兽。这个回合，选择的怪兽可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c77876207.target)
	e1:SetOperation(c77876207.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且攻击力在1000以下的怪兽
function c77876207.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
-- 效果发动的靶向检测与对象选择处理
function c77876207.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c77876207.filter(chkc) end
	-- 在发动阶段，检测自己场上是否存在符合条件的、可作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(c77876207.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c77876207.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使选择的对象怪兽在当前回合可以直接攻击
function c77876207.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，选择的怪兽可以直接攻击对方玩家。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
