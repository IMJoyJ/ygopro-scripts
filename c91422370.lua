--螺旋式発条
-- 效果：
-- 把自己场上1只攻击力1500以上的名字带有「发条」的怪兽解放发动。从手卡把1只名字带有「发条」的怪兽特殊召唤。那之后，可以把持有和这个效果特殊召唤的怪兽相同攻击力的1只名字带有「发条」的怪兽从卡组特殊召唤。
function c91422370.initial_effect(c)
	-- 把自己场上1只攻击力1500以上的名字带有「发条」的怪兽解放发动。从手卡把1只名字带有「发条」的怪兽特殊召唤。那之后，可以把持有和这个效果特殊召唤的怪兽相同攻击力的1只名字带有「发条」的怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c91422370.cost)
	e1:SetTarget(c91422370.target)
	e1:SetOperation(c91422370.activate)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：检查怪兽是否为攻击力1500以上的「发条」怪兽，且在空位不足时释放主怪兽区空位并符合己方控制或表侧条件。
function c91422370.costfilter(c,ft,tp)
	return c:IsSetCard(0x58) and c:IsAttackAbove(1500)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动代价：检查并解放自己场上1只符合条件的「发条」怪兽作为发动代价。
function c91422370.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己主要怪兽区当前可用的空位数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动代价检查：确认场上至多差1个空位且存在可解放的符合条件「发条」怪兽。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c91422370.costfilter,1,nil,ft,tp) end
	-- 让己方从场上选择1只满足条件的「发条」怪兽准备解放。
	local sg=Duel.SelectReleaseGroup(tp,c91422370.costfilter,1,1,nil,ft,tp)
	-- 将选择的「发条」怪兽作为发动代价解放。
	Duel.Release(sg,REASON_COST)
end
-- 手卡特招过滤函数：检查卡片是否为可特殊召唤的「发条」怪兽。
function c91422370.filter(c,e,tp)
	return c:IsSetCard(0x58) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡组特招过滤函数：检查卡片是否为攻击力与指定数值相同且可特殊召唤的「发条」怪兽。
function c91422370.filter2(c,atk,e,tp)
	return c:IsSetCard(0x58) and c:IsAttack(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的目标处理函数：检查自己手卡是否存在可特殊召唤的「发条」怪兽，并设置特殊召唤操作信息。
function c91422370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认自己手卡存在至少1只可特殊召唤的「发条」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c91422370.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：预计从自己手卡特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理函数：从手卡特招1只「发条」怪兽，随后若有空位且卡组有相同攻击力的「发条」怪兽，询问并从卡组特殊召唤。
function c91422370.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时检查自己怪兽区是否有空位，没有则结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送提示信息，引导玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己手卡选择1只可特殊召唤的「发条」怪兽。
	local g=Duel.SelectMatchingCard(tp,c91422370.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将所选「发条」怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 再次检查自己怪兽区是否仍有空位用于后续卡组特招。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local atk=g:GetFirst():GetAttack()
		-- 从自己卡组获取所有攻击力与刚特招怪兽相同的可特招「发条」怪兽组。
		local sg=Duel.GetMatchingGroup(c91422370.filter2,tp,LOCATION_DECK,0,nil,atk,e,tp)
		-- 若卡组存在符合条件的「发条」怪兽，询问玩家是否将其特殊召唤。
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91422370,0)) then  --"是否要从卡组特殊召唤？"
			-- 中断当前效果处理，使之后的卡组特招与之前的手卡特招视为不同时处理。
			Duel.BreakEffect()
			-- 发送提示信息，引导玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 从卡组选择并将该同攻击力「发条」怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
