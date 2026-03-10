--アドバンスドロー
-- 效果：
-- 把自己场上表侧表示存在的1只8星以上的怪兽解放发动。从自己卡组抽2张卡。
function c51630558.initial_effect(c)
	-- 上级抽卡：把自己场上表侧表示存在的1只8星以上的怪兽解放发动。从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c51630558.cost)
	e1:SetTarget(c51630558.target)
	e1:SetOperation(c51630558.activate)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示且等级8以上的怪兽
function c51630558.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8)
end
-- 效果处理时，检查玩家是否能解放满足条件的怪兽并选择1只进行解放
function c51630558.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否可以解放满足条件的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51630558.filter,1,nil) end
	-- 从场上选择1只满足条件的怪兽
	local g=Duel.SelectReleaseGroup(tp,c51630558.filter,1,1,nil)
	-- 将选中的怪兽以代价形式解放
	Duel.Release(g,REASON_COST)
end
-- 设置效果的目标玩家和抽卡数量
function c51630558.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置连锁对象为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为抽卡效果，目标玩家为当前玩家，抽卡数为2
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 执行效果的抽卡操作
function c51630558.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
