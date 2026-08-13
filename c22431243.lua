--超進化薬
-- 效果：
-- 祭掉自己场上1只爬虫类族怪兽。从手卡特殊召唤1只恐龙族怪兽上场。
function c22431243.initial_effect(c)
	-- 祭掉自己场上1只爬虫类族怪兽。从手卡特殊召唤1只恐龙族怪兽上场。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c22431243.cost)
	e1:SetTarget(c22431243.target)
	e1:SetOperation(c22431243.activate)
	c:RegisterEffect(e1)
end
-- 定义解放候选的过滤条件：该怪兽为爬虫类族，且解放后自己场上仍有可用怪兽区，且该怪兽是自己控制或表侧表示（用于可解放自己场上或表侧怪兽的通用判断）。
function c22431243.cfilter(c,tp)
	return c:IsRace(RACE_REPTILE)
		-- 进一步要求：解放该怪兽后，tp方怪兽区仍有空位；且该怪兽的控制者为tp或处于表侧表示。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义效果发动代价：先设置已支付代价标记为1；在合法性检查阶段确认存在可解放的爬虫类族怪兽；实际支付时选择1只爬虫类族怪兽并解放作为代价。
function c22431243.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在代价检查阶段（chk==0）判断：自己场上是否存在至少1只满足cfilter条件的可解放爬虫类族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c22431243.cfilter,1,nil,tp) end
	-- 实际支付代价时，从满足条件的爬虫类族怪兽中选择1只作为要解放的对象。
	local g=Duel.SelectReleaseGroup(tp,c22431243.cfilter,1,1,nil,tp)
	-- 将选中的怪兽解放，作为本次发动效果的代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：手牌中的恐龙族怪兽，并且能够被当前效果（e）正常特殊召唤（需满足召唤条件和苏生限制）。
function c22431243.filter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标与合法性判定：通过label或当前空位判断是否有特殊召唤空位，并检查手牌中是否存在可特召的恐龙族怪兽；若满足，则登记特殊召唤操作信息。
function c22431243.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否存在可用怪兽区：若cost已经解放过怪兽（label为1）则视为有空位，否则检查此时己方怪兽区是否有空位。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 目标合法性检查：必须有可用的怪兽区空位，并且手牌中存在至少1只满足filter条件的恐龙族怪兽，才能发动。
		return res and Duel.IsExistingMatchingCard(c22431243.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 登记操作信息：本次连锁将包含特殊召唤，预定从手牌特殊召唤1只恐龙族怪兽（不取对象，数量为1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：先确保仍有怪兽区空位；然后提示玩家选择要特殊召唤的卡，从手牌中选择1只满足条件的恐龙族怪兽，并以表侧表示特殊召唤到自己场上。
function c22431243.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若己方怪兽区已没有空位，则终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示信息：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中筛选出满足filter条件的恐龙族怪兽，并选择1张作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c22431243.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的恐龙族怪兽以表侧表示特殊召唤到自己（tp）场上，特殊召唤类型为0，且按规定检查召唤条件与苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
