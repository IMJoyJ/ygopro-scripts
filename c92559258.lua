--サーヴァント・オブ・エンディミオン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
-- ②：把这张卡3个魔力指示物取除才能发动。卡组1只可以放置魔力指示物的攻击力1000以上的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
-- 【怪兽效果】
-- 自己对「恩底弥翁的仆从」1回合只能有1次特殊召唤。
-- ①：有魔力指示物放置的这张卡可以直接攻击。
-- ②：对方回合1次，丢弃1张手卡才能发动。给这张卡以及自己场上的可以放置魔力指示物的卡全部各放置1个魔力指示物。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
function c92559258.initial_effect(c)
	c:EnableCounterPermit(0x1,LOCATION_PZONE+LOCATION_MZONE)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）。
	aux.EnablePendulumAttribute(c)
	c:SetSPSummonOnce(92559258)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_PZONE)
	-- 在连锁中注册该卡，用于记录魔法卡发动时该卡已在场。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ①：每次自己或者对方把魔法卡发动，给这张卡放置1个魔力指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetOperation(c92559258.counterop)
	c:RegisterEffect(e2)
	-- ②：把这张卡3个魔力指示物取除才能发动。卡组1只可以放置魔力指示物的攻击力1000以上的怪兽和灵摆区域的这张卡特殊召唤，给那2只各放置1个魔力指示物。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92559258,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCost(c92559258.spcost)
	e3:SetTarget(c92559258.sptg)
	e3:SetOperation(c92559258.spop)
	c:RegisterEffect(e3)
	-- ①：有魔力指示物放置的这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetCondition(c92559258.dacon)
	c:RegisterEffect(e4)
	-- ②：对方回合1次，丢弃1张手卡才能发动。给这张卡以及自己场上的可以放置魔力指示物的卡全部各放置1个魔力指示物。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(92559258,1))  --"放置指示物"
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCondition(c92559258.countercon2)
	e5:SetCost(c92559258.countercost2)
	e5:SetTarget(c92559258.countertg2)
	e5:SetOperation(c92559258.counterop2)
	c:RegisterEffect(e5)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(92559258,2))  --"在灵摆区域放置"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(c92559258.pencon)
	e6:SetTarget(c92559258.pentg)
	e6:SetOperation(c92559258.penop)
	c:RegisterEffect(e6)
	-- 那之后，这张卡放置过的数量的魔力指示物给这张卡放置。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetOperation(c92559258.regop)
	e7:SetLabelObject(e6)
	c:RegisterEffect(e7)
end
-- 魔法卡发动连锁处理完毕后，若该卡在场，则给该卡放置1个魔力指示物。
function c92559258.counterop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0 then
		e:GetHandler():AddCounter(0x1,1)
	end
end
-- 灵摆效果②的的Cost：取除这张卡的3个魔力指示物。
function c92559258.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x1,3,REASON_COST)
end
-- 过滤卡组中满足条件的怪兽：攻击力1000以上、可以放置魔力指示物、能被特殊召唤。
function c92559258.spfilter(c,e,tp)
	-- 检查卡片是否攻击力在1000以上、可以放置魔力指示物、且可以被特殊召唤。
	return c:IsAttackAbove(1000) and c:IsCanHaveCounter(0x1) and Duel.IsCanAddCounter(tp,0x1,1,c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果②的Target：检查怪兽区域空位、青眼精灵龙的影响，以及自身和卡组怪兽是否能特殊召唤。
function c92559258.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自身（灵摆区域的这张卡）是否可以特殊召唤，且是否可以被放置1个魔力指示物。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsCanAddCounter(tp,0x1,1,c)
		-- 检查卡组中是否存在至少1只满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c92559258.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，包含2只怪兽（自身和卡组的怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,2,tp,LOCATION_DECK)
end
-- 灵摆效果②的Operation：将自身和卡组选定的怪兽特殊召唤，并给这两只怪兽各放置1个魔力指示物。
function c92559258.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c92559258.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		g:AddCard(c)
		-- 将选中的怪兽和自身以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 遍历特殊召唤成功的怪兽组（包含自身和卡组召唤的怪兽）。
		for tc in aux.Next(g) do
			tc:AddCounter(0x1,1)
		end
	end
end
-- 怪兽效果①的Condition：检查这张卡上是否有魔力指示物。
function c92559258.dacon(e)
	return e:GetHandler():GetCounter(0x1)>0
end
-- 怪兽效果②的Condition：只能在对方回合发动。
function c92559258.countercon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方。
	return Duel.GetTurnPlayer()==1-tp
end
-- 怪兽效果②的Cost：丢弃1张手卡。
function c92559258.countercost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除自身以外的可丢弃卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 怪兽效果②的Target：检查自身是否能放置指示物，并获取场上其他可放置指示物的卡，设置操作信息。
function c92559258.countertg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanAddCounter(0x1,1) end
	-- 获取自己场上除自身以外所有可以放置魔力指示物的卡。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,c,0x1,1)
	g:AddCard(c)
	-- 设置放置指示物的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,0,0)
end
-- 怪兽效果②的Operation：给自身以及自己场上所有可以放置魔力指示物的卡各放置1个魔力指示物。
function c92559258.counterop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 重新获取场上除自身以外可以放置魔力指示物的卡。
	local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_ONFIELD,0,c,0x1,1)
	if c:IsRelateToEffect(e) then g:AddCard(c) end
	-- 遍历自身及场上所有可以放置魔力指示物的卡。
	for tc in aux.Next(g) do
		if tc:IsCanAddCounter(0x1,1) then
			tc:AddCounter(0x1,1)
		end
	end
end
-- 怪兽效果③的Condition：检查这张卡是否在怪兽区域被破坏且表侧表示。
function c92559258.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果③的Target：检查自己的灵摆区域是否有空位。
function c92559258.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查左侧或右侧的灵摆区域是否可用。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果③的Operation：将这张卡在自己的灵摆区域放置，并放置与其被破坏前相同数量的魔力指示物。
function c92559258.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	-- 检查卡片是否与效果相关，并将其表侧表示移动到灵摆区域。
	if c:IsRelateToEffect(e) and Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		and ct>0 then
		c:AddCounter(0x1,ct)
	end
end
-- 注册离场事件的处理：记录这张卡离场前所放置的魔力指示物数量。
function c92559258.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(e:GetHandler():GetCounter(0x1))
end
