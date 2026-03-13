--走魔灯
-- 效果：
-- ①：自己基本分未满100的场合才能发动。自己从卡组抽2张。自己基本分未满10的场合，再让自己从卡组抽2张。
function c53442500.initial_effect(c)
	-- 效果原文内容：①：自己基本分未满100的场合才能发动。自己从卡组抽2张。自己基本分未满10的场合，再让自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c53442500.condition)
	e1:SetTarget(c53442500.target)
	e1:SetOperation(c53442500.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：检查玩家LP是否小于100以满足发动条件
function c53442500.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己基本分未满100的场合才能发动
	return Duel.GetLP(tp)<100
end
-- 效果作用：根据玩家LP决定抽卡数量并设置目标与操作信息
function c53442500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=2
	-- 效果原文内容：自己基本分未满10的场合，再让自己从卡组抽2张
	if Duel.GetLP(tp)<10 then ct=4 end
	-- 效果作用：判断玩家是否可以抽指定数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 效果作用：设定连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设定连锁处理的目标参数为抽卡数量
	Duel.SetTargetParam(ct)
	-- 效果作用：设置操作信息为抽卡效果并确定抽卡数量
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果作用：执行抽卡操作，若满足条件则再次抽卡
function c53442500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 效果作用：判断第一次抽卡成功且玩家LP小于10时触发第二次抽卡
	if Duel.Draw(p,2,REASON_EFFECT)>0 and Duel.GetLP(p)<10 then
		-- 效果作用：中断当前效果处理，使后续效果视为错时点处理
		Duel.BreakEffect()
		-- 效果作用：执行一次抽卡操作
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
