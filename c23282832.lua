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
-- 筛选出本回合被战斗破坏、攻击力1000以下、为通常怪兽且可以被当前效果特殊召唤的墓地怪兽。
function c23282832.filter(c,e,tp,tid)
	return c:GetTurnID()==tid and c:IsReason(REASON_BATTLE) and c:IsType(TYPE_NORMAL)
		and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动代价处理：检查能否支付500基本分，能则支付500基本分。
function c23282832.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测阶段：确认玩家tp能否支付500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分。
	Duel.PayLPCost(tp,500)
end
-- 效果发动条件判定：我方主要怪兽区有空位，且双方墓地存在本回合被战斗破坏的攻击力1000以下的通常怪兽可供特殊召唤。
function c23282832.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定我方主要怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定双方墓地是否存在至少1张满足filter条件的怪兽（本回合被战斗破坏的1000以下通常怪兽）。
		and Duel.IsExistingMatchingCard(c23282832.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,Duel.GetTurnCount()) end
	-- 向系统登记本效果将包含特殊召唤操作，对象为双方墓地，数量至少1，用于连锁判定与效果发动合法性检查。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：根据可用怪兽区数量选择并特殊召唤符合条件的怪兽；若青眼精灵龙效果适用中则最多只能特殊召唤1只。
function c23282832.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方主要怪兽区当前可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家从墓地选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地中选出至多ft张满足条件的通常怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c23282832.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,ft,ft,nil,e,tp,Duel.GetTurnCount())
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到我方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
