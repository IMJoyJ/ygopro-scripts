--破天荒な風
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。选择的怪兽的攻击力·守备力直到下次的自己的准备阶段时上升1000。
function c22346472.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c22346472.target)
	e1:SetOperation(c22346472.activate)
	c:RegisterEffect(e1)
end
-- 发动时的目标选择函数：验证连锁时对象合法性，在发动时确认可选择的表侧表示怪兽，并让玩家选择1只作为对象。
function c22346472.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在至少1只自己场上表侧表示怪兽，若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示，告知玩家需要选择一张表侧表示的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上表侧表示怪兽中选择1只，并设置为其效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象卡，若对象仍与该效果相关且表侧表示，则给它赋予攻击力·守备力上升1000直到下次自己准备阶段的持续效果（攻击力与守备力分别处理）。
function c22346472.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这个效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的攻击力·守备力直到下次的自己的准备阶段时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
