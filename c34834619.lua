--光子竜降臨
-- 效果：
-- 「光子龙之圣骑士」的降临必需。必须从自己的手卡·场上把等级合计直到4的怪兽解放。此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。等级合计直到4的自己墓地的怪兽从游戏中除外，从手卡把1只「光子龙之圣骑士」当作仪式召唤作特殊召唤。
function c34834619.initial_effect(c)
	-- 为这张卡添加仪式召唤效果，指定「光子龙之圣骑士」(85346853)作为降临对象；仪式素材要求为从自己的手卡·场上解放等级合计等于4的怪兽。
	aux.AddRitualProcEqualCode(c,85346853)
	-- “此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。等级合计直到4的自己墓地的怪兽从游戏中除外，从手卡把1只「光子龙之圣骑士」当作仪式召唤作特殊召唤。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34834619,0))  --"仪式召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动代价：将墓地中的这张卡从游戏中除外，对应效果文中“把墓地的这张卡从游戏中除外才能发动”的条件。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c34834619.sptg)
	e1:SetOperation(c34834619.spop)
	c:RegisterEffect(e1)
end
-- 定义墓地仪式素材的过滤条件：怪兽的等级大于0、能够被除外、并且不免疫此效果，才能作为被除外的仪式素材。
function c34834619.mtfilter(c,e)
	return c:GetLevel()>0 and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义仪式召唤对象过滤条件：手卡中的「光子龙之圣骑士」能够被此效果当作仪式召唤特殊召唤，且墓地素材中存在等级合计为4的组合（1~99只）。
function c34834619.spfilter(c,e,tp,m)
	return c:IsCode(85346853) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
		and m:CheckWithSumEqual(Card.GetRitualLevel,4,1,99,c)
end
-- 作为起动效果的目标判定：检查自己场上是否有空位、墓地是否有可用素材、手卡是否有可仪式召唤的「光子龙之圣骑士」；通过后登记特殊召唤操作信息。
function c34834619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上怪兽区域是否有空位；没有空位则无法仪式召唤，不能发动效果。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 从自己墓地筛选满足条件的怪兽作为仪式素材候选（等级>0、可除外、不免疫此效果），并排除发动效果的这张卡本身。
		local mg=Duel.GetMatchingGroup(c34834619.mtfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
		-- 检查手卡中是否存在至少1只可以仪式召唤的「光子龙之圣骑士」，且其能够使用当前墓地素材凑出等级合计4。
		return Duel.IsExistingMatchingCard(c34834619.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
	end
	-- 登记操作信息：本效果预定从自己手卡特殊召唤1只怪兽（位置：手卡），供相关卡牌检测发动条件使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：再次确认场上空位，取得墓地素材候选，选择1只手卡仪式怪兽，选择等级合计4的墓地怪兽作素材，设置仪式素材、解放/除外素材，然后以仪式召唤方式特殊召唤目标并完成召唤手续。
function c34834619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次判定：自己场上没有空余怪兽区域则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 处理时重新获取自己墓地中可被除外的怪兽作为素材候选；由于发动代价已除外自身，这里不再排除自身。
	local mg=Duel.GetMatchingGroup(c34834619.mtfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 给出“请选择要特殊召唤的卡”的选择提示，用于随后从手卡选择仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只满足 spfilter 条件的「光子龙之圣骑士」作为本次仪式召唤特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c34834619.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 给出“请选择要除外的卡”的选择提示，用于随后选择墓地中要被除外的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,4,1,99,tc)
		tc:SetMaterial(mat)
		-- 将选择出的墓地怪兽作为仪式素材解放/除外，处理从墓地仪式召唤所需的素材除外。
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果处理，把后续的仪式特殊召唤作为独立处理，确保“仪式召唤成功时”的时点能被正确发动。
		Duel.BreakEffect()
		-- 以「仪式召唤」的召唤方式，将「光子龙之圣骑士」表侧表示特殊召唤到自己场上，并被判定为仪式召唤。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
