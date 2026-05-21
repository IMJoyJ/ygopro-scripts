--カオス・グリード
-- 效果：
-- 当自己的卡有4张以上从游戏中除外，且自己的墓地里没有卡存在时这张卡才能发动。从自己的卡组抽2张卡。
function c97439308.initial_effect(c)
	-- 当自己的卡有4张以上从游戏中除外，且自己的墓地里没有卡存在时这张卡才能发动。从自己的卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c97439308.condition)
	e1:SetTarget(c97439308.target)
	e1:SetOperation(c97439308.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查自身除外区卡片数量是否在4张以上，且自身墓地没有卡片存在
function c97439308.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的除外区卡片数量是否大于等于4张
	return Duel.GetFieldGroupCount(tp,LOCATION_REMOVED,0)>=4
		-- 检查自己的墓地卡片数量是否等于0
		and Duel.GetFieldGroupCount(tp,LOCATION_GRAVE,0)==0
end
-- 发动准备（Target）：检查玩家是否能抽卡，并设置抽卡的目标玩家、张数及操作信息
function c97439308.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测可行性阶段，则返回玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置当前连锁的目标玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2（抽2张卡）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：由发动玩家从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理（Operation）：获取目标玩家和抽卡张数，执行抽卡效果
function c97439308.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和目标参数（抽卡张数）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
