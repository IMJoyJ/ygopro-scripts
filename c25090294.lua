--ブルーメンブラット
-- 效果：
-- 把自己场上1只「元素英雄 小花蕾」作为祭品发动。从自己的手卡·卡组特殊召唤1只「元素英雄 鲜花女郎」。
function c25090294.initial_effect(c)
	-- 向本卡注册系列字段0x3008（即“元素英雄”系列），使脚本中能正确判定与「元素英雄」相关的卡。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 把自己场上1只「元素英雄 小花蕾」作为祭品发动。从自己的手卡·卡组特殊召唤1只「元素英雄 鲜花女郎」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c25090294.cost)
	e1:SetTarget(c25090294.target)
	e1:SetOperation(c25090294.activate)
	c:RegisterEffect(e1)
end
-- 定义祭品候选的过滤条件：必须是卡号62107981的「元素英雄 小花蕾」，并且将其解放后主要怪兽区仍能有空位，同时该怪兽是在我方场上控制或是表侧表示，以符合作为祭品的条件。
function c25090294.costfilter(c,tp)
	return c:IsCode(62107981)
		-- 追加判定解放该候选怪兽后主要怪兽区仍有空位，且该怪兽的控制者是我方或处于表侧表示，确保其可以作为“自己场上”的祭品使用。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 设置发动代价的完整流程：先标记已确认过祭品条件，然后选择并解放1只满足条件的「元素英雄 小花蕾」作为发动代价。
function c25090294.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动确认阶段检查是否存在至少1只满足祭品过滤条件的可解放怪兽，若不存在则不能发动。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c25090294.costfilter,1,nil,tp) end
	-- 让玩家从满足条件的怪兽中选择1只「元素英雄 小花蕾」作为要解放的祭品。
	local g=Duel.SelectReleaseGroup(tp,c25090294.costfilter,1,1,nil,tp)
	-- 将选择的「元素英雄 小花蕾」解放，作为发动本效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 定义特殊召唤对象的过滤条件：必须是卡号51085303的「元素英雄 鲜花女郎」，且能够被本效果特殊召唤（忽略召唤条件，但遵守苏生限制）。
function c25090294.filter(c,e,tp)
	return c:IsCode(51085303) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 发动时判定是否满足条件并设定后续处理信息：在cost阶段已确认有祭品后的空位或当前仍有空位，且手卡·卡组中存在可特殊召唤的对象，然后设置特殊召唤的操作信息。
function c25090294.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断发动时是否满足特殊召唤所需空位：cost阶段已经确认过（标签为1）或当前主要怪兽区仍有空位，二者其一即可。
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if chk==0 then
		e:SetLabel(0)
		-- 返回发动是否可行：同时满足空位条件，并且从手卡·卡组中存在至少1只可特殊召唤的「元素英雄 鲜花女郎」。
		return res and Duel.IsExistingMatchingCard(c25090294.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp)
	end
	-- 设置本连锁的操作信息，标明效果涉及从手卡·卡组进行1只怪兽的特殊召唤，供后续连锁判定和时点触发使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理阶段：先检查怪兽区是否有空位，然后提示玩家选择要特殊召唤的「元素英雄 鲜花女郎」，从手卡·卡组将其特殊召唤，并完成正规召唤手续。
function c25090294.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前主要怪兽区没有空位，则效果不处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，用于后续卡牌选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己的手卡·卡组中选择1张符合条件的「元素英雄 鲜花女郎」作为特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c25090294.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「元素英雄 鲜花女郎」以表侧表示特殊召唤到自己的主要怪兽区，不检查召唤条件但保留苏生限制。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end
