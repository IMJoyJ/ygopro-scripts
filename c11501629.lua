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
	-- 只要这张卡在场上存在，每次自己场上表侧表示存在的炎属性怪兽被卡的效果破坏，那些破坏的怪兽数量的指示物给这张卡放置。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_DESTROY)
	e2:SetCondition(c11501629.ctcon)
	e2:SetOperation(c11501629.ctop)
	c:RegisterEffect(e2)
	-- 此外，自己或者对方的准备阶段时把这张卡送去墓地才能发动。给与对方基本分这张卡的效果给这张卡放置的指示物数量×1000的数值的伤害。
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
-- 筛选符合“自己场上表侧表示存在的炎属性怪兽被卡的效果破坏”的怪兽：表侧表示、由自己控制、位于怪兽区域、炎属性、破坏原因为效果。
function c11501629.ctfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsReason(REASON_EFFECT)
end
-- 统计本次被效果破坏并符合条件的怪兽数量；若数量大于0且此卡可以放置对应数量的指示物，则将数量存入标签并返回true，否则返回false，作为指示物放置效果的发动/适用条件。
function c11501629.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(c11501629.ctfilter,nil,tp)
	if ct>0 and e:GetHandler():IsCanAddCounter(0x2d,ct) then
		e:SetLabel(ct)
		return true
	else
		return false
	end
end
-- 给这张卡放置与已记录的破坏怪兽数量相同数量的0x2d指示物。
function c11501629.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x2d,e:GetLabel())
end
-- 当前阶段为准备阶段时才可发动，对应‘自己或者对方的准备阶段时’的发动条件。
function c11501629.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为准备阶段。
	return Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 作为发动代价把此卡送去墓地：先检查此卡能否作为代价送墓，若能则记录当前指示物数量，随后将它送去墓地，对应‘把这张卡送去墓地才能发动’。
function c11501629.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabel(e:GetHandler():GetCounter(0x2d))
	-- 将这张卡作为发动代价（REASON_COST）送入墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 发动时确认此卡上指示物数量大于0；计算伤害为指示物数量×1000，将对象玩家设为对方、参数设为伤害值，并写入连锁操作信息。
function c11501629.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetCounter(0x2d)>0 end
	local dam=e:GetLabel()*1000
	-- 将连锁的对象玩家设为对方（1-tp），使效果以对方玩家为对象。
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的对象参数设为伤害数值（指示物数量×1000）。
	Duel.SetTargetParam(dam)
	-- 设置当前连锁的操作信息：效果分类为伤害，对象为对方玩家，参数为伤害量dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时，从连锁信息中读取对象玩家和伤害值，给对方造成对应伤害。
function c11501629.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中设置的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
