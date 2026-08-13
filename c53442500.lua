--走魔灯
-- 效果：
-- ①：自己基本分未满100的场合才能发动。自己从卡组抽2张。自己基本分未满10的场合，再让自己从卡组抽2张。
function c53442500.initial_effect(c)
	-- ①：自己基本分未满100的场合才能发动。自己从卡组抽2张。自己基本分未满10的场合，再让自己从卡组抽2张。
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
-- 效果发动条件函数：判断自己基本分是否未满100，满100则不能发动。
function c53442500.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家LP是否小于100，作为效果能否发动的条件。
	return Duel.GetLP(tp)<100
end
-- 效果发动时的目标处理：设定本次抽卡数量，若LP未满10则为4（含追加），否则为2；检查能否抽相应数量卡；以自身为对象玩家，记录目标参数，并声明抽卡操作信息。
function c53442500.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=2
	-- 若当前玩家基本分未满10，则把抽卡数量从2改为4，用于覆盖追加抽2张的情况。
	if Duel.GetLP(tp)<10 then ct=4 end
	-- 合法性检查阶段：若自己不能抽ct张卡，则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 将效果的对象玩家设为当前发动玩家tp，即抽卡者为自身。
	Duel.SetTargetPlayer(tp)
	-- 将效果的目标参数设为抽卡数量ct，供处理阶段读取。
	Duel.SetTargetParam(ct)
	-- 设置连锁操作信息为抽卡效果（CATEGORY_DRAW），目标玩家tp预计抽ct张，便于相关卡片和时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果处理：先让对象玩家抽2张；若抽卡成功且其LP仍未满10，则中断后追加抽2张。
function c53442500.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家（即之前设定的抽卡玩家tp）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 让玩家p以效果原因抽2张；若实际抽卡数大于0且p基本分仍低于10，则执行追加抽卡。
	if Duel.Draw(p,2,REASON_EFFECT)>0 and Duel.GetLP(p)<10 then
		-- 中断当前效果处理，使后续追加抽卡与第一次抽卡视为不同时处理，避免时点合并。
		Duel.BreakEffect()
		-- 让对象玩家p再抽2张卡，实现“再让自己从卡组抽2张”的追加效果。
		Duel.Draw(p,2,REASON_EFFECT)
	end
end
