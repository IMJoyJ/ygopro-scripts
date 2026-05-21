--ラスト・リゾート
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。从自己卡组选择1张「虹之古代都市」发动。这个时候，对方的场地魔法在发动的场合，对方玩家可以抽1张卡。
function c97970833.initial_effect(c)
	-- 在卡片中注册其记有「虹之古代都市」的卡片密码
	aux.AddCodeList(c,34487429)
	-- 对方怪兽的攻击宣言时才能发动。从自己卡组选择1张「虹之古代都市」发动。这个时候，对方的场地魔法在发动的场合，对方玩家可以抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c97970833.condition)
	e1:SetTarget(c97970833.target)
	e1:SetOperation(c97970833.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数
function c97970833.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为对方回合（即对方怪兽进行攻击宣言）
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤卡组中可以发动的「虹之古代都市」
function c97970833.filter(c,tp)
	return c:IsCode(34487429) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 定义发动目标与合法性检查函数
function c97970833.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己卡组是否存在可发动的「虹之古代都市」
	if chk==0 then return Duel.IsExistingMatchingCard(c97970833.filter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 定义效果处理（发动）函数
function c97970833.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组获取第一张满足条件的「虹之古代都市」
	local tc=Duel.GetFirstMatchingCard(c97970833.filter,tp,LOCATION_DECK,0,nil,tp)
	if tc then
		-- 获取自己场地区域当前存在的卡
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			-- 将自己场上原有的场地魔法因规则送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断效果处理，使后续动作不与送墓视为同时进行
			Duel.BreakEffect()
		end
		-- 将选取的「虹之古代都市」表侧表示移动到自己的场地区域并适用其效果（发动）
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		-- 获取对方场地区域当前存在的卡
		fc=Duel.GetFieldCard(1-tp,LOCATION_FZONE,0)
		local te=tc:GetActivateEffect()
		te:UseCountLimit(tp,1,true)
		-- 手动触发场地魔法发动的事件时点
		Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
		-- 判断对方场上是否存在表侧表示的场地魔法，且对方可以抽卡，并询问对方是否抽卡
		if fc and fc:IsFaceup() and Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectYesNo(1-tp,aux.Stringid(97970833,0)) then  --"是否要抽一张卡？"
			-- 中断效果处理，使抽卡不与之前的处理视为同时进行
			Duel.BreakEffect()
			-- 让对方玩家从卡组抽1张卡
			Duel.Draw(1-tp,1,REASON_EFFECT)
		end
	end
end
