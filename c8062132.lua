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
	-- 这张卡只要在场上表侧表示存在，不会成为这张卡以外的卡的效果的对象，
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
c8062132.mentioned_counter={
	[0x11]=true,
}
-- 特殊召唤条件的限制函数
function c8062132.splimit(e,se,sp,st)
	local sc=se:GetHandler()
	return sc:IsCode(16067089) or sc==e:GetHandler()
end
-- 不受其他卡效果影响的过滤函数
function c8062132.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
-- 攻击力上升数值的计算函数
function c8062132.atkval(e,c)
	-- 计算自己墓地爬虫类族怪兽的数量并乘以500
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_REPTILE)*500
end
-- 被战斗破坏送墓特殊召唤的发动条件：在墓地且被战斗破坏
function c8062132.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 筛选可以作为除外代价的爬虫类族怪兽的过滤函数
function c8062132.cfilter(c)
	return c:IsRace(RACE_REPTILE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤效果的代价：除外自己墓地1只爬虫类族怪兽
function c8062132.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以除外的爬虫类族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8062132.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地的1只爬虫类族怪兽
	local g=Duel.SelectMatchingCard(tp,c8062132.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选择的怪兽作为代价除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤效果的检查与目标设定
function c8062132.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有主要的怪兽区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定将这张卡特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行过程
function c8062132.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 放置指示物效果的发动条件：受到战斗伤害的玩家是对方
function c8062132.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 放置指示物效果的执行过程：给这张卡放置1个超毒指示物
function c8062132.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(0x11,1)
end
-- 特殊胜利效果的执行过程：有3个指示物时决斗胜利
function c8062132.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON_VENNOMINAGA = 0x12
	local c=e:GetHandler()
	if c:GetCounter(0x11)==3 then
		-- 令该玩家取得决斗胜利
		Duel.Win(tp,WIN_REASON_VENNOMINAGA)
	end
end
