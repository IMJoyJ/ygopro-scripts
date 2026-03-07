--DDパンドラ
-- 效果：
-- ①：这张卡被战斗或者对方的效果破坏送去墓地时，自己场上没有卡存在的场合才能发动。自己从卡组抽2张。
function c32146097.initial_effect(c)
	-- ①：这张卡被战斗或者对方的效果破坏送去墓地时，自己场上没有卡存在的场合才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c32146097.drcon)
	e1:SetTarget(c32146097.drtg)
	e1:SetOperation(c32146097.drop)
	c:RegisterEffect(e1)
end
-- 满足破坏原因条件：由战斗破坏或由对方效果破坏且之前在自己场上
function c32146097.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE)
		or rp==1-tp and c:IsReason(REASON_DESTROY) and c:IsPreviousControler(tp))
		-- 满足场上没有卡存在的条件
		and Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0
end
-- 设置效果的发动目标：检查玩家是否可以抽2张卡，并设置抽卡相关操作信息
function c32146097.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为2（抽卡数量）
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息为抽卡效果，目标玩家为当前玩家，抽卡数量为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：获取目标玩家和抽卡数量并执行抽卡
function c32146097.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡效果，抽卡数量为d，抽卡原因为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
