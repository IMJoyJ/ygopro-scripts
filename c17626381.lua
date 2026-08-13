--補給部隊
-- 效果：
-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合发动。自己抽1张。
function c17626381.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上的怪兽被战斗·效果破坏的场合发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17626381,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1)
	e2:SetCondition(c17626381.drcon)
	e2:SetTarget(c17626381.drtg)
	e2:SetOperation(c17626381.drop)
	c:RegisterEffect(e2)
end
-- 筛选被战斗或效果破坏、破坏前位于主要怪兽区且破坏前控制者为自己（补给部队的控制者）的怪兽。
function c17626381.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 检查本次被破坏的怪兽集合中，是否存在至少1只满足上述条件的怪兽，即满足“自己场上的怪兽被战斗·效果破坏”的发动条件。
function c17626381.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c17626381.cfilter,1,nil,tp)
end
-- 效果发动时的目标处理：本效果不取对象，直接设置抽卡玩家为自己、抽卡数量为1，并登记抽卡的操作信息。
function c17626381.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为效果控制者自己，即抽卡的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽取1张卡。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本效果属于“抽卡”分类，由玩家tp抽1张卡（数量为1，目标位置无）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的操作：从连锁信息中取回记录的对象玩家和抽卡数量，执行抽卡。
function c17626381.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的对象玩家（抽卡玩家）和对象参数（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p以效果原因抽取d张卡，即自己抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
