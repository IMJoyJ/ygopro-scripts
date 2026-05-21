--翼の恩返し
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上的怪兽只有鸟兽族怪兽并有原本卡名不同的怪兽2只以上的场合，支付600基本分才能发动。自己从卡组抽2张。
function c8843569.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上的怪兽只有鸟兽族怪兽并有原本卡名不同的怪兽2只以上的场合，支付600基本分才能发动。自己从卡组抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,8843569+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c8843569.drcon)
	e1:SetCost(c8843569.drcost)
	e1:SetTarget(c8843569.drtg)
	e1:SetOperation(c8843569.drop)
	c:RegisterEffect(e1)
end
-- 过滤非表侧表示或非鸟兽族怪兽的辅助函数
function c8843569.cfilter(c,g)
	return c:IsFacedown() or not c:IsRace(RACE_WINDBEAST)
end
-- 发动条件：自己场上仅有2只以上原本卡名不同的表侧表示鸟兽族怪兽
function c8843569.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return g:GetCount()>=2 and not g:IsExists(c8843569.cfilter,1,nil,g) and g:GetClassCount(Card.GetOriginalCodeRule)>=2
end
-- 发动代价：支付600基本分
function c8843569.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能够支付600基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 效果发动：检查是否能抽卡，并设置抽卡的目标玩家、张数和操作信息
function c8843569.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查玩家是否能够从卡组抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的目标玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为2（抽卡张数）
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息为：自己从卡组抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：执行抽卡效果
function c8843569.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果从卡组抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
