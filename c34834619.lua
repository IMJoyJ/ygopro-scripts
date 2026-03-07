--光子竜降臨
-- 效果：
-- 「光子龙之圣骑士」的降临必需。必须从自己的手卡·场上把等级合计直到4的怪兽解放。此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。等级合计直到4的自己墓地的怪兽从游戏中除外，从手卡把1只「光子龙之圣骑士」当作仪式召唤作特殊召唤。
function c34834619.initial_effect(c)
	-- 为卡片添加仪式召唤效果，仪式怪兽卡号为85346853
	aux.AddRitualProcEqualCode(c,85346853)
	-- 「光子龙之圣骑士」的降临必需。必须从自己的手卡·场上把等级合计直到4的怪兽解放。此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。等级合计直到4的自己墓地的怪兽从游戏中除外，从手卡把1只「光子龙之圣骑士」当作仪式召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34834619,0))  --"仪式召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置效果发动时的费用为将此卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c34834619.sptg)
	e1:SetOperation(c34834619.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的墓地怪兽：等级大于0、可以除外、未被效果免疫
function c34834619.mtfilter(c,e)
	return c:GetLevel()>0 and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选满足条件的「光子龙之圣骑士」：卡号为85346853、可以特殊召唤、且满足仪式召唤所需等级和数量条件
function c34834619.spfilter(c,e,tp,m)
	return c:IsCode(85346853) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,true,false)
		and m:CheckWithSumEqual(Card.GetRitualLevel,4,1,99,c)
end
-- 设置效果的发动条件：检查手牌中是否存在满足条件的「光子龙之圣骑士」，并确保场上存在空位
function c34834619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查玩家场上是否还有空位，若无则效果无法发动
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 获取满足条件的墓地怪兽组，用于后续的等级合计计算
		local mg=Duel.GetMatchingGroup(c34834619.mtfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
		-- 检查手牌中是否存在满足条件的「光子龙之圣骑士」
		return Duel.IsExistingMatchingCard(c34834619.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
	end
	-- 设置效果处理时的操作信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 设置效果的处理函数，执行特殊召唤操作
function c34834619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家场上是否还有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取满足条件的墓地怪兽组，用于后续的等级合计计算
	local mg=Duel.GetMatchingGroup(c34834619.mtfilter,tp,LOCATION_GRAVE,0,nil,e)
	-- 提示玩家选择要特殊召唤的「光子龙之圣骑士」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「光子龙之圣骑士」
	local g=Duel.SelectMatchingCard(tp,c34834619.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	local tc=g:GetFirst()
	if tc then
		-- 提示玩家选择要除外的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local mat=mg:SelectWithSumEqual(tp,Card.GetRitualLevel,4,1,99,tc)
		tc:SetMaterial(mat)
		-- 将选中的怪兽作为仪式召唤的素材进行除外处理
		Duel.ReleaseRitualMaterial(mat)
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 将选中的「光子龙之圣骑士」以仪式召唤方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,true,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
