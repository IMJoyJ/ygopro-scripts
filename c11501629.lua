--キックファイア
-- 效果：
-- 只要这张卡在场上存在，每次自己场上表侧表示存在的炎属性怪兽被卡的效果破坏，那些破坏的怪兽数量的指示物给这张卡放置。这个效果1回合只能适用1次。此外，自己或者对方的准备阶段时把这张卡送去墓地才能发动。给与对方基本分这张卡的效果给这张卡放置的指示物数量×1000的数值的伤害。
function c11501629.initial_effect(c)
	c:EnableCounterPermit(0x2d)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：只要这张卡在场上存在，每次自己场上表侧表示存在的炎属性怪兽被卡的效果破坏，那些破坏的怪兽数量的指示物给这张卡放置。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_DESTROY)
	e2:SetCondition(c11501629.ctcon)
	e2:SetOperation(c11501629.ctop)
	c:RegisterEffect(e2)
	-- 效果原文：此外，自己或者对方的准备阶段时把这张卡送去墓地才能发动。给与对方基本分这张卡的效果给这张卡放置的指示物数量×1000的数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11501629,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(TIMING_STANDBY_PHASE)
	e3:SetCondition(c11501629.damcon)
	e3:SetCost(c11501629.damcost)
	e3:SetTarget(c11501629.damtg)
	e3:SetOperation(c11501629.damop)
	c:RegisterEffect(e3)
end
-- 规则层面：过滤满足条件的被破坏的炎属性怪兽（表侧表示、在自己场上、被效果破坏）
function c11501629.ctfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsReason(REASON_EFFECT)
end
-- 规则层面：统计满足条件的被破坏怪兽数量，并判断是否可以放置对应数量的指示物
function c11501629.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c11501629.ctfilter,nil,tp)
	if ct>0 and e:GetHandler():IsCanAddCounter(0x2d,ct) then
		e:SetLabel(ct)
		return true
	else
		return false
	end
end
-- 规则层面：将对应数量的指示物放置到此卡上
function c11501629.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x2d,e:GetLabel())
end
-- 规则层面：判断当前阶段是否为准备阶段
function c11501629.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：判断当前阶段是否为准备阶段
	return Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 规则层面：支付将此卡送去墓地作为代价
function c11501629.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x2d))
	-- 规则层面：将此卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面：设置伤害效果的目标玩家和伤害值
function c11501629.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x2d)>0 end
	local dam=e:GetLabel()*1000
	-- 规则层面：设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面：设置连锁处理的目标参数为伤害值
	Duel.SetTargetParam(dam)
	-- 规则层面：设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 规则层面：执行对目标玩家造成伤害的操作
function c11501629.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：对目标玩家造成指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
