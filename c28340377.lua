--絵札の絆
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽存在的场合才能发动。从自己的手卡·墓地选「王后骑士」「卫兵骑士」「国王骑士」之内1只特殊召唤。
-- ②：从自己的手卡·墓地把「王后骑士」「卫兵骑士」「国王骑士」各最多1只除外才能发动。自己从卡组抽出除外的数量。
function c28340377.initial_effect(c)
	-- 注册该卡牌所关联的其他卡片代码，用于识别其效果中涉及的特定怪兽卡片。
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上没有「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽存在的场合才能发动。从自己的手卡·墓地选「王后骑士」「卫兵骑士」「国王骑士」之内1只特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28340377,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,28340377)
	e2:SetCondition(c28340377.spcon)
	e2:SetTarget(c28340377.sptg)
	e2:SetOperation(c28340377.spop)
	c:RegisterEffect(e2)
	-- ②：从自己的手卡·墓地把「王后骑士」「卫兵骑士」「国王骑士」各最多1只除外才能发动。自己从卡组抽出除外的数量。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28340377,1))  --"除外并抽卡"
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCountLimit(1,28340377)
	e3:SetCost(c28340377.drcost)
	e3:SetTarget(c28340377.drtg)
	e3:SetOperation(c28340377.drop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽。
function c28340377.confilter(c)
	return c:IsFaceup() and c:IsCode(64788463,25652259,90876561)
end
-- 判断是否满足效果①的发动条件：自己场上没有「王后骑士」「卫兵骑士」「国王骑士」以外的怪兽。
function c28340377.spcon(e,tp)
	-- 获取自己场上的所有怪兽组。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	return #g==0 or (#g>0 and g:FilterCount(c28340377.confilter,nil)==#g)
end
-- 过滤函数，用于判断手牌或墓地中的卡片是否为「王后骑士」「卫兵骑士」「国王骑士」且可特殊召唤。
function c28340377.spfilter(c,e,tp)
	return c:IsCode(64788463,25652259,90876561) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果①的发动条件：确认场上是否有足够的召唤位置以及手牌或墓地中是否存在符合条件的怪兽。
function c28340377.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c28340377.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果①的处理信息，表示将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果①的处理函数，执行特殊召唤操作。
function c28340377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的召唤位置，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌或墓地中选择符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c28340377.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断手牌或墓地中的卡片是否为「王后骑士」「卫兵骑士」「国王骑士」且可除外作为费用。
function c28340377.cfilter(c)
	return c:IsCode(64788463,25652259,90876561) and c:IsAbleToRemoveAsCost()
end
-- 效果②的处理函数，执行除外并抽卡操作。
function c28340377.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌或墓地中所有符合条件的怪兽。
	local g=Duel.GetMatchingGroup(c28340377.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,nil)
	local mt=g:GetClassCount(Card.GetCode)
	if chk==0 then return mt>0 end
	local ct=1
	for i=2,3 do
		-- 判断玩家是否可以抽卡，用于确定最多可除外的怪兽数量。
		if Duel.IsPlayerCanDraw(tp,i) then ct=i end
	end
	if mt<ct then ct=mt end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽中选择不重复卡名的若干张。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	-- 将选中的怪兽除外，并记录除外数量。
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- 设置效果②的发动条件：确认玩家是否可以抽卡。
function c28340377.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	local ct=e:GetLabel()
	-- 设置效果②的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置效果②的目标参数为除外的怪兽数量。
	Duel.SetTargetParam(ct)
	-- 设置效果②的处理信息，表示将抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- 效果②的处理函数，执行抽卡操作。
function c28340377.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 根据目标参数执行抽卡操作。
	Duel.Draw(p,d,REASON_EFFECT)
end
