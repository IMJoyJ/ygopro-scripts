--時械神ザフィオン
-- 效果：
-- 这张卡不能从卡组特殊召唤。
-- ①：自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡进行战斗的战斗阶段结束时发动。对方场上的魔法·陷阱卡全部回到卡组。
-- ④：这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张。
-- ⑤：自己准备阶段发动。这张卡回到持有者卡组。
function c28929131.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上没有怪兽存在的场合，这张卡可以不用解放作召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28929131,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c28929131.ntcon)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
	-- 这张卡进行战斗的战斗阶段结束时发动。对方场上的魔法·陷阱卡全部回到卡组。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(28929131,1))
	e6:SetCategory(CATEGORY_TODECK)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e6:SetCountLimit(1)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c28929131.tdcon)
	e6:SetTarget(c28929131.tdtg)
	e6:SetOperation(c28929131.tdop)
	c:RegisterEffect(e6)
	-- 这张卡从场上送去墓地的场合才能发动。自己从卡组抽1张。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(28929131,2))
	e7:SetCategory(CATEGORY_DRAW)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e7:SetProperty(EFFECT_FLAG_DELAY)
	e7:SetCode(EVENT_TO_GRAVE)
	e7:SetCountLimit(1)
	e7:SetCondition(c28929131.drcon)
	e7:SetTarget(c28929131.drtg)
	e7:SetOperation(c28929131.drop)
	c:RegisterEffect(e7)
	-- 自己准备阶段发动。这张卡回到持有者卡组。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(28929131,3))
	e8:SetCategory(CATEGORY_TODECK)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e8:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e8:SetCountLimit(1)
	e8:SetRange(LOCATION_MZONE)
	e8:SetCondition(c28929131.rtdcon)
	e8:SetTarget(c28929131.rtdtg)
	e8:SetOperation(c28929131.rtdop)
	c:RegisterEffect(e8)
end
-- 检查召唤时是否满足条件：不需解放、等级不低于5、自己场上没有怪兽、有可用的怪兽区域。
function c28929131.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and c:IsLevelAbove(5)
		-- 检查自己场上是否没有怪兽。
		and Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 检查自己场上是否有可用的怪兽区域。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 检查该卡是否参与过战斗。
function c28929131.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 过滤函数：返回可以送回卡组的魔法或陷阱卡。
function c28929131.tdfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
end
-- 设置连锁操作信息：准备将对方场上的魔法·陷阱卡送回卡组。
function c28929131.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取对方场上的魔法·陷阱卡组。
	local g=Duel.GetMatchingGroup(c28929131.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置操作信息：将指定数量的魔法·陷阱卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 执行将魔法·陷阱卡送回卡组的操作。
function c28929131.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的魔法·陷阱卡组。
	local g=Duel.GetMatchingGroup(c28929131.tdfilter,tp,0,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将卡组中的魔法·陷阱卡送回卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 检查该卡是否从场上送去墓地。
function c28929131.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置连锁操作信息：准备抽一张卡。
function c28929131.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽一张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置连锁操作的目标玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数。
	Duel.SetTargetParam(1)
	-- 设置操作信息：抽一张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作。
function c28929131.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁操作的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 检查是否轮到自己准备阶段。
function c28929131.rtdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- 设置连锁操作信息：准备将该卡送回卡组。
function c28929131.rtdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 执行将该卡送回卡组的操作。
function c28929131.rtdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡送回卡组并洗牌。
		Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
