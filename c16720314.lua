--スマイル・ポーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有怪兽存在，持有比原本攻击力高的攻击力的怪兽在对方场上存在的场合才能发动。自己从卡组抽2张。
function c16720314.initial_effect(c)
	-- 创建效果对象并设置其分类为抽卡、对象为玩家、类型为发动、时点为自由时点、发动次数限制为1次、条件函数为condition、目标函数为target、效果处理函数为activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16720314+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c16720314.condition)
	e1:SetTarget(c16720314.target)
	e1:SetOperation(c16720314.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查怪兽是否表侧表示且当前攻击力高于原本攻击力
function c16720314.cfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 效果发动条件：自己场上没有怪兽且对方场上存在攻击力高于原本攻击力的怪兽
function c16720314.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上是否存在满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c16720314.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 设置效果目标：检查玩家是否可以抽2张卡，并设置目标玩家和抽卡数量
function c16720314.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为效果发动玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为抽卡效果，目标玩家为效果发动玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从卡组抽卡
function c16720314.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数（抽卡数量）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，抽卡数量为d，抽卡原因为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
