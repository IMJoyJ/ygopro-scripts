--沈黙の邪悪霊
-- 效果：
-- 对方的战斗阶段才可以发动。1只攻击怪兽的攻击无效化，改为对方的其他的表侧表示的1只怪兽攻击。（对象是守备表示的场合变攻击表示）
function c93599951.initial_effect(c)
	-- 对方的战斗阶段才可以发动。1只攻击怪兽的攻击无效化，改为对方的其他的表侧表示的1只怪兽攻击。（对象是守备表示的场合变攻击表示）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c93599951.condition)
	e1:SetTarget(c93599951.target)
	e1:SetOperation(c93599951.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：当前回合玩家为对方（对方回合）
function c93599951.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为对方
	return tp~=Duel.GetTurnPlayer()
end
-- 效果的目标选择与合法性检查
function c93599951.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取当前进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 在发动阶段（chk==0）检查是否存在合法的攻击怪兽作为对象，以及对方场上是否存在除该攻击怪兽以外的表侧表示怪兽
	if chk==0 then return a and a:IsCanBeEffectTarget(e) and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,a) end
	-- 将当前的攻击怪兽设为效果的对象
	Duel.SetTargetCard(a)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上除当前攻击怪兽以外的1只表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,a)
	e:SetLabelObject(g:GetFirst())
end
-- 效果处理（改变攻击怪兽）
function c93599951.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		if tc:IsDefensePos() then
			-- 将守备表示的对象怪兽变为表侧攻击表示
			Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		end
		-- 将攻击怪兽变更为选定的对象怪兽（原攻击怪兽的攻击无效化）
		Duel.ChangeAttacker(tc)
	end
end
