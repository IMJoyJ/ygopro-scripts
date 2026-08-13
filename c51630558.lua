--アドバンスドロー
-- 效果：
-- 把自己场上表侧表示存在的1只8星以上的怪兽解放发动。从自己卡组抽2张卡。
function c51630558.initial_effect(c)
	-- 把自己场上表侧表示存在的1只8星以上的怪兽解放发动。从自己卡组抽2张卡。
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
-- 过滤函数：判断怪兽是否为表侧表示且等级在8星以上，作为解放对象的筛选条件。
function c51630558.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(8)
end
-- 代价函数：发动前检查自己场上是否有符合条件的怪兽可供解放，发动时选择1只表侧表示8星以上的怪兽解放作为代价。
function c51630558.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己场上存在至少1只表侧表示且8星以上的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51630558.filter,1,nil) end
	-- 从自己场上选择1只表侧表示且8星以上的怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,c51630558.filter,1,1,nil)
	-- 将选择的怪兽解放，解放理由为代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 目标函数：发动时检查自己能否抽2张卡，并记录抽卡玩家和抽卡数量，供效果处理时使用。
function c51630558.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己玩家可以抽2张卡，没有受到不能抽卡的效果限制。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将当前连锁的对象玩家设置为发动者自己（tp），表示由该玩家进行抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为2，表示要抽的卡数量为2张。
	Duel.SetTargetParam(2)
	-- 设置操作信息：声明该效果处理时将进行抽卡（CATEGORY_DRAW），抽卡玩家为tp，抽卡数量为2，由于卡组中的卡在处理时才确定，目标卡设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：从连锁信息中取出记录的对象玩家和抽卡数量，让该玩家抽对应数量的卡。
function c51630558.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取预先保存的对象玩家和对象参数，即抽卡玩家与抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
