--八汰烏の骸
-- 效果：
-- 从下面效果选择1个发动。
-- ●从自己卡组抽1张卡。
-- ●对方场上有灵魂怪兽表侧表示存在的场合才能发动。从自己卡组抽2张卡。
function c30461781.initial_effect(c)
	-- 效果原文内容：从下面效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30461781.target)
	e1:SetOperation(c30461781.activate)
	c:RegisterEffect(e1)
end
c30461781.has_text_type=TYPE_SPIRIT
-- 效果作用：过滤出对方场上表侧表示存在的灵魂怪兽
function c30461781.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
-- 效果作用：判断是否满足抽2张卡的条件并选择抽卡数量
function c30461781.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local d=1
	-- 效果作用：检查自己卡组是否有多于1张卡
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 效果作用：检查对方场上是否存在灵魂怪兽
		and Duel.IsExistingMatchingCard(c30461781.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 效果作用：让玩家选择抽1张卡或抽2张卡
		and Duel.SelectOption(tp,aux.Stringid(30461781,0),aux.Stringid(30461781,1))==1 then  --"抽一张卡/抽两张卡"
		d=2
	end
	-- 效果作用：设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 效果作用：设置连锁处理的目标参数为抽卡数量
	Duel.SetTargetParam(d)
	-- 效果作用：设置连锁的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- 效果原文内容：●从自己卡组抽1张卡。●对方场上有灵魂怪兽表侧表示存在的场合才能发动。从自己卡组抽2张卡。
function c30461781.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁处理的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 效果作用：执行抽卡操作
	Duel.Draw(p,d,REASON_EFFECT)
end
