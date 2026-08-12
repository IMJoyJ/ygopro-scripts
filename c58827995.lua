--鎧竜降臨
-- 效果：
-- 「铠龙之圣骑士」的降临必需。这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到4以上的自己的手卡·场上的怪兽解放，从手卡把「铠龙之圣骑士」仪式召唤。
-- ②：从手卡以及自己场上的表侧表示怪兽之中把等级合计直到4以上的怪兽除外才能发动。墓地的这张卡除外，从自己墓地选1只「铠龙之圣骑士」特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c58827995.initial_effect(c)
	-- 注册仪式召唤效果，指定仪式怪兽为「铠龙之圣骑士」，且解放怪兽的等级合计可以超过仪式怪兽的原本等级
	aux.AddRitualProcGreaterCode(c,75901113)
	-- ②：从手卡以及自己场上的表侧表示怪兽之中把等级合计直到4以上的怪兽除外才能发动。墓地的这张卡除外，从自己墓地选1只「铠龙之圣骑士」特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,58827995)
	-- 设置效果发动条件：这张卡送去墓地的回合不能发动
	e1:SetCondition(aux.exccon)
	e1:SetCost(c58827995.spcost)
	e1:SetTarget(c58827995.sptg)
	e1:SetOperation(c58827995.spop)
	c:RegisterEffect(e1)
end
-- 过滤可作为除外代价的卡片：手卡或场上表侧表示的、等级在1以上且可以被除外的怪兽
function c58827995.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and c:IsLevelAbove(1) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup())
end
-- 检查选中的卡片组是否满足：等级合计在4以上，且除外这些卡后玩家场上有足够的怪兽区域空位
function c58827995.fselect(g,tp)
	-- 将当前已选择的卡片组传入后续的等级合计检查函数中
	Duel.SetSelectedCard(g)
	-- 返回选中的卡片等级合计是否在4以上，且除外这些卡后是否能留出足够的怪兽区域空位
	return g:CheckWithSumGreater(Card.GetLevel,4) and aux.mzctcheck(g,tp)
end
-- 效果②的发动代价处理：从手卡·场上选择等级合计直到4以上的怪兽除外
function c58827995.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家自己手卡及怪兽区的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE+LOCATION_HAND,0)
	local sg=g:Filter(c58827995.cfilter,nil)
	if chk==0 then return sg:CheckSubGroup(c58827995.fselect,1,sg:GetCount(),tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=sg:SelectSubGroup(tp,c58827995.fselect,false,1,sg:GetCount(),tp)
	-- 将选中的怪兽作为发动代价表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
-- 过滤墓地中可以特殊召唤的「铠龙之圣骑士」
function c58827995.spfilter(c,e,tp)
	return c:IsCode(75901113) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查墓地的这张卡是否能除外，以及墓地是否存在可特殊召唤的「铠龙之圣骑士」，并设置特殊召唤的操作信息
function c58827995.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：墓地的这张卡是否能除外，且自己墓地是否存在至少1只可以特殊召唤的「铠龙之圣骑士」
	if chk==0 then return e:GetHandler():IsAbleToRemove() and Duel.IsExistingMatchingCard(c58827995.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理：将墓地的这张卡除外，并从自己墓地特殊召唤1只「铠龙之圣骑士」
function c58827995.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将墓地的这张卡表侧表示除外，若除外成功则继续处理
	if Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 检查自己场上是否有可用的怪兽区域空位，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从自己墓地选择1只满足条件的「铠龙之圣骑士」
		local g=Duel.SelectMatchingCard(tp,c58827995.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「铠龙之圣骑士」在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
