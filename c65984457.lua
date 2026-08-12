--剣闘獣トラケス
-- 效果：
-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组并抽1张卡。
function c65984457.initial_effect(c)
	-- 这张卡用名字带有「剑斗兽」的怪兽的效果特殊召唤成功的场合，这张卡进行战斗的战斗阶段结束时可以让这张卡回到卡组并抽1张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65984457,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c65984457.spcon)
	e1:SetCost(c65984457.spcost)
	e1:SetTarget(c65984457.sptg)
	e1:SetOperation(c65984457.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：检查是否满足「剑斗兽」特召条件以及是否进行过战斗
function c65984457.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否由「剑斗兽」怪兽效果特召且本回合进行过战斗
	return aux.gbspcon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():GetBattledGroupCount()>0
end
-- 效果发动代价函数：将自身回到卡组
function c65984457.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将自身送回持有者卡组并洗牌
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 效果发动目标函数：设置抽卡的目标玩家和数量，并注册操作信息
function c65984457.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的目标玩家为发动效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为1（抽卡张数）
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数：执行抽卡
function c65984457.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
