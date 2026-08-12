--螺旋式発条
-- 效果：
-- 把自己场上1只攻击力1500以上的名字带有「发条」的怪兽解放发动。从手卡把1只名字带有「发条」的怪兽特殊召唤。那之后，可以把持有和这个效果特殊召唤的怪兽相同攻击力的1只名字带有「发条」的怪兽从卡组特殊召唤。
function c91422370.initial_effect(c)
	-- 把自己场上1只攻击力1500以上的名字带有「发条」的怪兽解放发动。从手卡把1只名字带有「发条」的怪兽特殊召唤。那之后，可以把持有和这个效果特殊召唤的怪兽相同攻击力的1只名字带有「发条」的怪兽从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c91422370.cost)
	e1:SetTarget(c91422370.target)
	e1:SetOperation(c91422370.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上攻击力1500以上且名字带有「发条」的怪兽，并考虑解放后是否能空出怪兽区域
function c91422370.costfilter(c,ft,tp)
	return c:IsSetCard(0x58) and c:IsAttackAbove(1500)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果发动代价：解放自己场上1只攻击力1500以上且名字带有「发条」的怪兽
function c91422370.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用怪兽区域的数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查是否存在可解放的满足条件的怪兽，且解放后有足够的怪兽区域进行特殊召唤
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c91422370.costfilter,1,nil,ft,tp) end
	-- 玩家选择1只满足条件的怪兽作为解放对象
	local sg=Duel.SelectReleaseGroup(tp,c91422370.costfilter,1,1,nil,ft,tp)
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 过滤条件：手卡中名字带有「发条」且可以特殊召唤的怪兽
function c91422370.filter(c,e,tp)
	return c:IsSetCard(0x58) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：卡组中名字带有「发条」、攻击力与指定数值相同且可以特殊召唤的怪兽
function c91422370.filter2(c,atk,e,tp)
	return c:IsSetCard(0x58) and c:IsAttack(atk) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认：检查手卡中是否存在可特殊召唤的「发条」怪兽，并设置特殊召唤的操作信息
function c91422370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以特殊召唤的「发条」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91422370.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁信息，表示此效果包含从手卡特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡特殊召唤1只「发条」怪兽，之后可以从卡组特殊召唤1只相同攻击力的「发条」怪兽
function c91422370.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则直接结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「发条」怪兽
	local g=Duel.SelectMatchingCard(tp,c91422370.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 再次检查自己场上是否有可用的怪兽区域，若无则无法继续从卡组特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local atk=g:GetFirst():GetAttack()
		-- 获取卡组中与刚刚特殊召唤的怪兽攻击力相同且可以特殊召唤的「发条」怪兽
		local sg=Duel.GetMatchingGroup(c91422370.filter2,tp,LOCATION_DECK,0,nil,atk,e,tp)
		-- 如果卡组中存在符合条件的怪兽，询问玩家是否要从卡组特殊召唤
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(91422370,0)) then  --"是否要从卡组特殊召唤？"
			-- 中断当前效果，使后续的卡组特殊召唤处理视为不同时处理（造成错时点）
			Duel.BreakEffect()
			-- 提示玩家选择要从卡组特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local dg=sg:Select(tp,1,1,nil)
			-- 将从卡组选中的怪兽以表侧表示特殊召唤
			Duel.SpecialSummon(dg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
