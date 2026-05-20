--ダークネス・ネオスフィア
-- 效果：
-- 这张卡不能通常召唤。对方怪兽的攻击宣言时，从自己的手卡·场上各把1只恶魔族怪兽送去墓地才能把这张卡从手卡特殊召唤。这张卡不会被战斗破坏。1回合1次，可以让自己场上表侧表示存在的陷阱卡全部回到手卡。
function c60417395.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制，使这张卡不能被其他卡的效果特殊召唤
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 对方怪兽的攻击宣言时，从自己的手卡·场上各把1只恶魔族怪兽送去墓地才能把这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60417395,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c60417395.spcon)
	e2:SetCost(c60417395.spcost)
	e2:SetTarget(c60417395.sptg)
	e2:SetOperation(c60417395.spop)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 1回合1次，可以让自己场上表侧表示存在的陷阱卡全部回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60417395,1))  --"陷阱卡返回手牌"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c60417395.thtg)
	e4:SetOperation(c60417395.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤效果的发动条件：对方怪兽宣言攻击时
function c60417395.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤场上表侧表示、恶魔族、能送去墓地作代价，且满足怪兽区域空位限制的怪兽（若场上没有空位，则必须选择主要怪兽区域的怪兽以腾出位置）
function c60417395.cfilter1(c,ft)
	return c:IsFaceup() and c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 过滤手卡中恶魔族且能送去墓地作代价的怪兽
function c60417395.cfilter2(c)
	return c:IsRace(RACE_FIEND) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的发动代价：从手卡和场上各将1只恶魔族怪兽送去墓地
function c60417395.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在chk为0时，判断场上是否存在至少1只满足条件的恶魔族怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c60417395.cfilter1,tp,LOCATION_MZONE,0,1,nil,ft)
		-- 并且手卡中是否存在至少1只除这张卡以外的恶魔族怪兽
		and Duel.IsExistingMatchingCard(c60417395.cfilter2,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择场上1只满足条件的恶魔族怪兽
	local g1=Duel.SelectMatchingCard(tp,c60417395.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择手卡1只满足条件的恶魔族怪兽
	local g2=Duel.SelectMatchingCard(tp,c60417395.cfilter2,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g1:Merge(g2)
	-- 将选中的场上和手卡的恶魔族怪兽作为代价送去墓地
	Duel.SendtoGrave(g1,REASON_COST)
end
-- 特殊召唤效果的发动目标：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c60417395.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 设置连锁处理中的操作信息为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：将这张卡特殊召唤，并完成正规召唤程序（苏生限制）
function c60417395.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡无视召唤条件以表侧表示特殊召唤到自己场上，若成功则执行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- 过滤场上表侧表示且能回到手卡的陷阱卡
function c60417395.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 回手牌效果的发动目标：检查场上是否存在表侧表示的陷阱卡，并设置回手牌的操作信息
function c60417395.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，判断场上是否存在至少1张表侧表示的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c60417395.filter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 获取场上所有表侧表示的陷阱卡
	local g=Duel.GetMatchingGroup(c60417395.filter,tp,LOCATION_ONFIELD,0,nil)
	-- 设置连锁处理中的操作信息为将这些陷阱卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 回手牌效果的执行：将场上所有表侧表示的陷阱卡全部回到手卡
function c60417395.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有表侧表示的陷阱卡
	local g=Duel.GetMatchingGroup(c60417395.filter,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 通过效果将这些陷阱卡全部送回持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
