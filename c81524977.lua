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
c81524977.mentioned_counter={
	[0x20]=true,
}
-- 指示物放置过滤条件：场上表侧表示的植物族怪兽
function c81524977.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT)
end
-- 指示物放置条件检查：召唤·反转召唤·特殊召唤的怪兽中包含表侧表示的植物族怪兽
function c81524977.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81524977.ctfilter,1,nil)
end
-- 指示物放置处理：给此卡放置1个植物指示物
function c81524977.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x20,1)
end
-- 伤害效果Cost：记录当前指示物数量并将场上的此卡送去墓地
function c81524977.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x20))
	-- 将场上的此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 伤害效果准备：检查指示物数量并设置给与对方伤害的操作信息
function c81524977.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetCounter(0x20)>0 end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁对象参数为指示物数量×500的伤害数值
	Duel.SetTargetParam(e:GetLabel()*500)
	-- 设置连锁操作信息：给与对方指示物数量×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,e:GetLabel()*500)
end
-- 伤害效果处理：根据锁定的目标玩家与伤害数值造成效果伤害
function c81524977.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中锁定的目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
