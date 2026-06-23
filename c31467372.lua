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
-- 检查目标怪兽是否为表侧表示、控制者为指定玩家且种族为不死族
function c31467372.filter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_ZOMBIE)
end
-- 判断是否有满足条件的不死族怪兽被特殊召唤成功
function c31467372.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31467372.filter,1,nil,tp)
end
-- 设置伤害效果的目标玩家为对方玩家，伤害值为800，准备执行伤害效果
function c31467372.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理中伤害效果的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理中伤害效果的伤害值为800
	Duel.SetTargetParam(800)
	-- 设置当前连锁的操作信息为造成800点伤害，对象玩家为对方
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果，对指定玩家造成800点伤害
function c31467372.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取伤害效果的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因对指定玩家造成对应伤害值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
