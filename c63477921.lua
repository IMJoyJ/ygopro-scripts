--サイバー・サモン・ブラスター
-- 效果：
-- ①：这张卡已在魔法与陷阱区域存在的状态，每次机械族怪兽特殊召唤成功发动。给与对方300伤害。
function c63477921.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡已在魔法与陷阱区域存在的状态，每次机械族怪兽特殊召唤成功发动。给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63477921,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c63477921.damcon)
	e2:SetTarget(c63477921.damtg)
	e2:SetOperation(c63477921.damop)
	c:RegisterEffect(e2)
end
-- 过滤出表侧表示的机械族怪兽
function c63477921.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 检查特殊召唤成功的怪兽中是否存在表侧表示的机械族怪兽
function c63477921.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c63477921.filter,1,nil)
end
-- 伤害效果的发动准备，设置目标玩家、伤害数值并注册操作信息
function c63477921.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置对方玩家为效果处理的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的的参数值为300（伤害值）
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为给与对方玩家300点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 伤害效果的实际处理，获取目标玩家和伤害数值并执行伤害
function c63477921.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
