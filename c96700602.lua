--波動障壁
-- 效果：
-- 对方怪兽的攻击宣言时，把自己场上存在的1只同调怪兽解放发动。对方场上攻击表示存在的怪兽全部变成守备表示。那之后，给与对方基本分攻击宣言的怪兽的守备力数值的伤害。
function c96700602.initial_effect(c)
	-- 对方怪兽的攻击宣言时，把自己场上存在的1只同调怪兽解放发动。对方场上攻击表示存在的怪兽全部变成守备表示。那之后，给与对方基本分攻击宣言的怪兽的守备力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c96700602.condition)
	e1:SetCost(c96700602.cost)
	e1:SetTarget(c96700602.target)
	e1:SetOperation(c96700602.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件（对方怪兽的攻击宣言时）
function c96700602.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 支付发动代价（解放自己场上1只同调怪兽）
function c96700602.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的同调怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsType,1,nil,TYPE_SYNCHRO) end
	-- 玩家选择自己场上1只同调怪兽解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsType,1,1,nil,TYPE_SYNCHRO)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 过滤对方场上可以改变表示形式的攻击表示怪兽
function c96700602.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 效果发动时的目标确认与操作信息设置
function c96700602.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只可以改变表示形式的攻击表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96700602.filter,tp,0,LOCATION_MZONE,1,nil) end
	local tc=eg:GetFirst()
	if tc:IsLocation(LOCATION_MZONE) then
		-- 将攻击宣言的怪兽设为效果处理的对象
		Duel.SetTargetCard(tc)
		-- 设置给与对方攻击宣言怪兽守备力数值伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetDefense())
	end
end
-- 效果处理（改变表示形式，之后给与伤害）
function c96700602.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽（即之前设置的对象卡）
	local tc=Duel.GetFirstTarget()
	-- 获取对方场上所有可以改变表示形式的攻击表示怪兽
	local g=Duel.GetMatchingGroup(c96700602.filter,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽全部变成守备表示，并检查是否成功改变了表示形式
	if Duel.ChangePosition(g,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)~=0 then
		if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetDefense()>0 then
			-- 中断当前效果处理，使后续的伤害处理不与改变表示形式同时进行（用于“那之后”的时点处理）
			Duel.BreakEffect()
			-- 给与对方攻击宣言怪兽守备力数值的伤害
			Duel.Damage(1-tp,tc:GetDefense(),REASON_EFFECT)
		end
	end
end
