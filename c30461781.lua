--八汰烏の骸
-- 效果：
-- 从下面效果选择1个发动。
-- ●从自己卡组抽1张卡。
-- ●对方场上有灵魂怪兽表侧表示存在的场合才能发动。从自己卡组抽2张卡。
function c30461781.initial_effect(c)
	-- 从下面效果选择1个发动。●从自己卡组抽1张卡。●对方场上有灵魂怪兽表侧表示存在的场合才能发动。从自己卡组抽2张卡。
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
-- 定义筛选函数：判断怪兽是否为表侧表示的灵魂怪兽，用于检查对方场上是否存在符合条件的灵魂怪兽。
function c30461781.filter(c)
	return c:IsType(TYPE_SPIRIT) and c:IsFaceup()
end
-- 发动时的目标处理：确认自己可以抽卡后，如果对方场上有表侧灵魂怪兽且自己卡组数量大于1，则让玩家选择抽1张或抽2张，并记录目标玩家和抽卡数量；否则默认为抽1张。
function c30461781.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若自己玩家不能抽至少1张卡，则效果不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local d=1
	-- 检查自己卡组中的卡数量是否大于1，作为能否选择抽2张的条件之一。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
		-- 检查对方场上是否存在至少1张表侧表示的灵魂怪兽，对应‘对方场上有灵魂怪兽表侧表示存在的场合’的条件。
		and Duel.IsExistingMatchingCard(c30461781.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 让玩家选择发动哪个效果：选项0为抽1张，选项1为抽2张；若选择抽2张则将抽卡数d设为2。
		and Duel.SelectOption(tp,aux.Stringid(30461781,0),aux.Stringid(30461781,1))==1 then  --"抽一张卡/抽两张卡"
		d=2
	end
	-- 将当前连锁的对象玩家设置为tp（自己），使后续处理知道由谁抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为d（抽卡数量），供效果处理时读取。
	Duel.SetTargetParam(d)
	-- 设置操作信息：声明本次效果属于抽卡效果，目标玩家为tp，参数为抽卡数量d，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,d)
end
-- 效果处理：从连锁信息中取得之前记录的目标玩家和抽卡数，执行抽卡。
function c30461781.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家p和抽卡数d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p以效果原因抽d张卡，完成抽卡动作。
	Duel.Draw(p,d,REASON_EFFECT)
end
