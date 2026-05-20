--毒蛇神ヴェノミナーガ
-- 效果：
-- 这张卡不能通常召唤。「蛇神降临」的效果以及这张卡的效果才能特殊召唤。这张卡的攻击力上升自己墓地的爬虫类族怪兽数量×500的数值。这张卡只要在场上表侧表示存在，不会成为这张卡以外的卡的效果的对象，也不受效果影响。这张卡被战斗破坏送去墓地时，可以通过把这张卡以外的自己墓地1只爬虫类族怪兽从游戏中除外，这张卡特殊召唤。这张卡给与对方基本分战斗伤害时，给这张卡放置1个超毒指示物。这张卡有3个超毒指示物放置时，这张卡的控制者决斗胜利。
function c8062132.initial_effect(c)
	c:EnableCounterPermit(0x11)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「蛇神降临」的效果以及这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c8062132.splimit)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力上升自己墓地的爬虫类族怪兽数量×500的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c8062132.atkval)
	c:RegisterEffect(e2)
	-- 这张卡被战斗破坏送去墓地时，可以通过把这张卡以外的自己墓地1只爬虫类族怪兽从游戏中除外，这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(8062132,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c8062132.condition)
	e3:SetCost(c8062132.cost)
	e3:SetTarget(c8062132.target)
	e3:SetOperation(c8062132.operation)
	c:RegisterEffect(e3)
	-- 这张卡只要在场上表侧表示存在，不会成为这张卡以外的卡的效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetValue(c8062132.efilter)
	c:RegisterEffect(e5)
	-- 这张卡给与对方基本分战斗伤害时，给这张卡放置1个超毒指示物。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(8062132,1))  --"放置指示物"
	e6:SetCategory(CATEGORY_COUNTER)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_BATTLE_DAMAGE)
	e6:SetCondition(c8062132.ctcon)
	e6:SetOperation(c8062132.ctop)
	c:RegisterEffect(e6)
	-- 这张卡有3个超毒指示物放置时，这张卡的控制者决斗胜利。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetRange(LOCATION_MZONE)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e7:SetOperation(c8062132.winop)
	c:RegisterEffect(e7)
end
-- 特殊召唤限制：仅能通过「蛇神降临」的效果或自身效果特殊召唤。
function c8062132.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:IsCode(16067089) or sc==e:GetHandler()
end
-- 效果免疫过滤：不受自身以外的卡的效果影响。
function c8062132.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 攻击力数值计算：获取自己墓地爬虫类族怪兽的数量并乘以500。
function c8062132.atkval(e,c)
	-- 返回自己墓地爬虫类族怪兽数量乘以500的数值。
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_REPTILE)*500
end
-- 效果发动条件：自身被战斗破坏并送去墓地。
function c8062132.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤条件：自己墓地的爬虫类族怪兽，且可以作为cost除外。
function c8062132.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 效果发动代价：从自己墓地将1只自身以外的爬虫类族怪兽除外。
function c8062132.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只除自身以外的、可除外的爬虫类族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c8062132.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家发送选择要除外的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地1只除自身以外的爬虫类族怪兽。
	local g=Duel.SelectMatchingCard(tp,c8062132.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的怪兽表侧表示除外作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果发动目标：检查自己场上是否有空位，且自身是否可以特殊召唤，并设置特殊召唤的操作信息。
function c8062132.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含特殊召唤自身1张。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若自身仍存在于墓地，则将自身特殊召唤。
function c8062132.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件：给对方玩家造成了战斗伤害。
function c8062132.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 效果处理：给自身放置1个超毒指示物。
function c8062132.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x11,1)
end
-- 决斗胜利检测：在时点调整时，若自身有3个超毒指示物，则判定控制者决斗胜利。
function c8062132.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_VENNOMINAGA = 0x12
	local c=e:GetHandler()
	if c:GetCounter(0x11)==3 then
		-- 判定当前玩家以“毒蛇神 维诺米纳迦”的效果决斗胜利。
		Duel.Win(tp,WIN_REASON_VENNOMINAGA)
	end
end
