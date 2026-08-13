--スマイル・ポーション
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有怪兽存在，持有比原本攻击力高的攻击力的怪兽在对方场上存在的场合才能发动。自己从卡组抽2张。
function c16720314.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上没有怪兽存在，持有比原本攻击力高的攻击力的怪兽在对方场上存在的场合才能发动。自己从卡组抽2张。
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
-- 定义过滤条件：该怪兽须为表侧表示，且当前攻击力大于其原本攻击力（即持有比原本攻击力高的攻击力的怪兽）。
function c16720314.cfilter(c)
	return c:IsFaceup() and c:GetAttack()>c:GetBaseAttack()
end
-- 发动条件：自己场上没有怪兽存在，且对方场上有至少1只满足cfilter条件（表侧表示且当前攻击力高于原本攻击力）的怪兽。
function c16720314.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区（包含额外怪兽区）没有怪兽存在，即自己场上没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 检查对方场上的怪兽区是否存在至少1只满足cfilter条件的怪兽（表侧表示且当前攻击力高于原本攻击力）。
		and Duel.IsExistingMatchingCard(c16720314.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果发动时的目标设置：验证玩家可以抽2张卡，并以玩家为对象记录抽卡玩家和抽卡数量，同时登记抽卡操作信息。
function c16720314.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：在发动时（chk==0）确认玩家tp可以进行抽2张卡，若不能则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动者tp，即以自己为抽卡对象。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示抽卡数量为2张。
	Duel.SetTargetParam(2)
	-- 登记此次效果处理包含抽卡分类的操作信息：预计由tp玩家抽2张卡（因为抽卡对象和数量已确定，无需指定具体卡片，故targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理阶段：从当前连锁信息中取出之前保存的对象玩家和抽卡张数，并执行抽卡。
function c16720314.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和对象参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让对象玩家p以效果原因抽d张卡，完成抽卡效果。
	Duel.Draw(p,d,REASON_EFFECT)
end
