--不死式冥界砲
-- 效果：
-- 自己场上有不死族怪兽特殊召唤时，给与对方基本分800分伤害。这个效果1回合只能使用1次。
function c31467372.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上有不死族怪兽特殊召唤时，给与对方基本分800分伤害。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31467372,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c31467372.damcon)
	e2:SetTarget(c31467372.damtg)
	e2:SetOperation(c31467372.damop)
	c:RegisterEffect(e2)
end
-- 过滤条件：判断怪兽是否为表侧表示、控制者是否为tp、种族是否为不死族。
function c31467372.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
-- 伤害诱发条件：特殊召唤成功的怪兽组中存在至少1只满足filter条件的怪兽。
function c31467372.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31467372.filter,1,nil,tp)
end
-- 伤害效果发动时的处理：无需选择卡，设置对象玩家为对方、伤害数值为800，并登记伤害操作信息。
function c31467372.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的伤害对象玩家为对方玩家（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的伤害参数值为800。
	Duel.SetTargetParam(800)
	-- 登记操作信息：本次效果处理将给对方玩家造成800点伤害（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 伤害效果处理：从连锁信息中取得对象玩家和伤害数值，实际给予对方800点伤害。
function c31467372.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象玩家和参数值，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）向玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
