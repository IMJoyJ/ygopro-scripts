--ホーリージャベリン
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。自己基本分回复那1只攻击怪兽的攻击力的数值。
function c96355986.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。自己基本分回复那1只攻击怪兽的攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c96355986.condition)
	e1:SetTarget(c96355986.target)
	e1:SetOperation(c96355986.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数：检查是否在对方回合的攻击宣言时
function c96355986.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return tp~=Duel.GetTurnPlayer()
end
-- 效果目标选择与参数设置函数：确认攻击怪兽并将其设为效果对象，记录其攻击力作为回复数值
function c96355986.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前进行攻击宣言的怪兽
	local tg=Duel.GetAttacker()
	if chkc then return chkc==tg end
	if chk==0 then return tg:IsOnField() and tg:IsCanBeEffectTarget(e) end
	-- 将该攻击怪兽设定为效果的处理对象
	Duel.SetTargetCard(tg)
	local rec=tg:GetAttack()
	-- 将回复数值参数设定为该怪兽的攻击力
	Duel.SetTargetParam(rec)
	-- 设置效果处理信息为回复自己对应数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理执行函数：使自己回复目标怪兽攻击力数值的基本分
function c96355986.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的攻击怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local rec=tc:GetAttack()
		-- 使玩家回复对应数值的基本分
		Duel.Recover(tp,rec,REASON_EFFECT)
	end
end
