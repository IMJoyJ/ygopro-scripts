--種子弾丸
-- 效果：
-- 每次植物族怪兽召唤·反转召唤·特殊召唤，给这张卡放置1个植物指示物（最多5个）。可以把场上存在的这张卡送去墓地，给与对方基本分这张卡放置的植物指示物数量×500的数值的伤害。
function c81524977.initial_effect(c)
	c:EnableCounterPermit(0x20)
	c:SetCounterLimit(0x20,5)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次植物族怪兽召唤·反转召唤·特殊召唤，给这张卡放置1个植物指示物（最多5个）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c81524977.ctcon)
	e2:SetOperation(c81524977.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- 可以把场上存在的这张卡送去墓地，给与对方基本分这张卡放置的植物指示物数量×500的数值的伤害。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(81524977,0))  --"伤害"
	e5:SetCategory(CATEGORY_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCost(c81524977.damcost)
	e5:SetTarget(c81524977.damtg)
	e5:SetOperation(c81524977.damop)
	c:RegisterEffect(e5)
end
-- 过滤条件：场上表侧表示的植物族怪兽
function c81524977.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 放置指示物效果的触发条件：召唤·反转召唤·特殊召唤的怪兽中存在植物族怪兽
function c81524977.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81524977.ctfilter,1,nil)
end
-- 放置指示物效果的处理：给这张卡放置1个植物指示物
function c81524977.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x20,1)
end
-- 伤害效果的发动代价：确认能否送去墓地，记录送墓前的指示物数量，并将自身送去墓地
function c81524977.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x20))
	-- 作为发动代价将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 伤害效果的发动准备：确认送墓前有指示物，设置对方为目标玩家，设置伤害数值，并声明伤害操作信息
function c81524977.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x20)>0 end
	-- 设置对方玩家为效果的对象玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果的对象参数为（指示物数量×500）
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置操作信息为给与对方玩家（指示物数量×500）的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- 伤害效果的处理：获取目标玩家和伤害数值，并给与对方伤害
function c81524977.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家相应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
