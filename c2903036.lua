--生け贄人形
-- 效果：
-- 祭掉自己场上1只怪兽发动。从手卡特殊召唤1只可以通常召唤的7星怪兽。特殊召唤出的怪兽本回合不能攻击。
function c2903036.initial_effect(c)
	-- 祭掉自己场上1只怪兽发动。从手卡特殊召唤1只可以通常召唤的7星怪兽。特殊召唤出的怪兽本回合不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2903036.cost)
	e1:SetTarget(c2903036.target)
	e1:SetOperation(c2903036.activate)
	c:RegisterEffect(e1)
end
-- 定义代价筛选函数：判断某只怪兽作为解放对象后，我方场上是否仍有可用的怪兽区空格。
function c2903036.cfilter(c,tp)
	-- 计算解放候选怪兽c后我方场上可用怪兽区数量是否大于0，确保腾出格子用于后续特殊召唤。
	return Duel.GetMZoneCount(tp,c)>0
end
-- 发动代价的整体处理：先标记已确认可解放，合法性检查是否存在可解放的怪兽，选择1只并解放，为特殊召唤做准备。
function c2903036.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 若为代价合法性检查（chk==0），返回是否存在至少1只可解放且解放后仍能让特殊召唤有格子可用的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c2903036.cfilter,1,nil,tp) end
	-- 让玩家从我方场上选择1只满足解放条件（解放后有空位）的怪兽作为代价。
	local g=Duel.SelectReleaseGroup(tp,c2903036.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放，作为效果的发动代价（REASON_COST）。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤对象的筛选函数：必须是等级7、可以通常召唤且能被效果特殊召唤的怪兽。
function c2903036.filter(c,e,tp)
	return c:IsLevel(7) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点的目标处理整体：结合代价是否已预留空位或当前空位，确认手牌存在满足条件的怪兽，并登记特殊召唤操作信息。
function c2903036.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算“有怪兽区可用”：要么代价阶段已证明能通过解放腾出格子（e:GetLabel()==1），要么当前我方场上就有空格。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 返回发动条件是否满足：有可用格子，并且手牌中存在至少1张等级7可通常召唤且可特殊召唤的怪兽。
		return res and Duel.IsExistingMatchingCard(c2903036.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	-- 设置效果处理时的操作信息：本次效果将从手卡特殊召唤1只怪兽，供系统进行相关检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理整体：检查格子，选择符合条件的怪兽特殊召唤，并给该怪兽附加本回合不能攻击的效果。
function c2903036.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果处理时我方已没有可用怪兽区，则终止处理，无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作者显示选择提示消息“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1张满足条件（等级7、可通常召唤、可特殊召唤）的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c2903036.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 如果确实选择了怪兽并成功执行特殊召唤步骤（临时特殊召唤），则进入附加不能攻击效果的处理。
	if g:GetCount()>0 and Duel.SpecialSummonStep(g:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		-- 特殊召唤出的怪兽本回合不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		g:GetFirst():RegisterEffect(e1,true)
	end
	-- 完成连续的特殊召唤处理，将之前步骤中的怪兽正式特殊召唤上场。
	Duel.SpecialSummonComplete()
end
