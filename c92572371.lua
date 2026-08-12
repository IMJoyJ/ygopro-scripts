--殺炎星－ブルキ
-- 效果：
-- 这张卡在墓地存在的场合，把手卡或者自己场上表侧表示存在的名字带有「炎星」或者「炎舞」的卡合计2张送去墓地才能发动。这张卡从墓地特殊召唤。「杀炎星-牛逵」的效果1回合只能使用1次。
function c92572371.initial_effect(c)
	-- 这张卡在墓地存在的场合，把手卡或者自己场上表侧表示存在的名字带有「炎星」或者「炎舞」的卡合计2张送去墓地才能发动。这张卡从墓地特殊召唤。「杀炎星-牛逵」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92572371,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,92572371)
	e1:SetCost(c92572371.spcost)
	e1:SetTarget(c92572371.sptg)
	e1:SetOperation(c92572371.spop)
	c:RegisterEffect(e1)
end
-- 过滤手卡或场上表侧表示的「炎星」或「炎舞」卡片，且这些卡片能作为代价送去墓地
function c92572371.cfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x79,0x7c) and c:IsAbleToGraveAsCost()
end
-- 检查是否存在第二张卡，使得这两张卡送去墓地后，自己场上能留出足够的怪兽区域来特殊召唤此卡
function c92572371.cfilter1(c,g,tp)
	return g:IsExists(c92572371.cfilter2,1,c,c,tp)
end
-- 检查将指定的两张卡送去墓地后，自己场上的可用怪兽区域数量是否大于0
function c92572371.cfilter2(c,mc,tp)
	-- 检查将卡片c和mc送去墓地后，玩家tp场上的可用怪兽区域是否大于0
	return Duel.GetMZoneCount(tp,Group.FromCards(c,mc))>0
end
-- 效果发动的代价：检查手卡或场上是否存在满足送墓条件的2张「炎星」或「炎舞」卡片，或者在「炎星仙-鹫真人」效果适用中且怪兽区域有空位时可以不支付代价发动
function c92572371.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家手卡及场上表侧表示的所有满足条件的「炎星」或「炎舞」卡片
	local sg=Duel.GetMatchingGroup(c92572371.cfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	if chk==0 then return sg:IsExists(c92572371.cfilter1,1,nil,sg,tp)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		or (Duel.IsPlayerAffectedByEffect(tp,46241344) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0) end
	if sg:IsExists(c92572371.cfilter1,1,nil,sg,tp)
		-- 检测【炎星仙-鹫真人】(46241344)的效果是否生效中。若在生效中，自己把「炎星」怪兽的效果发动的场合，也能不把自己的手卡·场上的「炎星」卡以及「炎舞」卡送去墓地来发动。
		and (not Duel.IsPlayerAffectedByEffect(tp,46241344) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.SelectYesNo(tp,aux.Stringid(46241344,0))) then  --"是否不把卡送去墓地发动？"
		-- 提示玩家选择第一张要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g1=sg:FilterSelect(tp,c92572371.cfilter1,1,1,nil,sg,tp)
		-- 提示玩家选择第二张要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g2=sg:FilterSelect(tp,c92572371.cfilter2,1,1,g1:GetFirst(),g1:GetFirst(),tp)
		g1:Merge(g2)
		-- 将选中的2张卡作为发动代价送去墓地
		Duel.SendtoGrave(g1,REASON_COST)
	end
end
-- 效果发动的目标：检查自身是否可以特殊召唤，并设置特殊召唤的操作信息
function c92572371.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表明将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍存在于墓地，则将此卡特殊召唤
function c92572371.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
