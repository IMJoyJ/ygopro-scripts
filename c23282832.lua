--オーバーリミット
-- 效果：
-- 支付500基本分。这个回合被战斗破坏的攻击力1000以下的通常怪兽尽可能在自己场上特殊召唤。
function c23282832.initial_effect(c)
	-- 支付500基本分。这个回合被战斗破坏的攻击力1000以下的通常怪兽尽可能在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(c23282832.cost)
	e1:SetTarget(c23282832.tg)
	e1:SetOperation(c23282832.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：在本回合被战斗破坏的通常怪兽，且攻击力不超过1000，可以被特殊召唤。
function c23282832.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsType(TYPE_NORMAL)
		and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 支付500基本分的处理函数，检查是否能支付并执行支付操作。
function c23282832.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 让玩家支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 设置效果的发动条件，检查场上是否有空位且墓地是否存在满足条件的怪兽。
function c23282832.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c23282832.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果发动时的处理函数，获取可用召唤数量并选择要特殊召唤的怪兽。
function c23282832.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的怪兽进行特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c23282832.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,ft,ft,nil,e,tp,Duel.GetTurnCount())
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
