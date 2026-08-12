--エレキャノン
-- 效果：
-- 场上有4星以下的雷族怪兽召唤·特殊召唤时，给与对方基本分600分伤害。这个效果1回合只能使用1次。
function c95084054.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上有4星以下的雷族怪兽召唤·特殊召唤时，给与对方基本分600分伤害。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95084054,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c95084054.damcon)
	e2:SetTarget(c95084054.damtg)
	e2:SetOperation(c95084054.damop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的4星以下的雷族怪兽
function c95084054.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsRace(RACE_THUNDER)
end
-- 发动条件：召唤·特殊召唤的怪兽中存在满足过滤条件的怪兽
function c95084054.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95084054.filter,1,nil)
end
-- 效果发动：设置伤害对象为对方玩家，伤害数值为600，并注册伤害操作信息
function c95084054.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前效果的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前效果的对象参数为600
	Duel.SetTargetParam(600)
	-- 设置操作信息为给与对方玩家600点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 效果处理：获取目标玩家和伤害数值，并执行伤害处理
function c95084054.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
