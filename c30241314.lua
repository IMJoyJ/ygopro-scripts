--マクロコスモス
-- 效果：
-- ①：作为这张卡的发动时的效果处理，可以从手卡·卡组把1只「原始太阳 赫利俄斯」特殊召唤。
-- ②：只要这张卡在魔法与陷阱区域存在，被送去墓地的卡不去墓地而除外。
function c30241314.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从手卡·卡组把1只「原始太阳 赫利俄斯」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c30241314.target)
	e1:SetOperation(c30241314.activate)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在魔法与陷阱区域存在，被送去墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
end
-- 效果处理时的检查点，用于判断是否可以发动此卡效果
function c30241314.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 过滤函数，用于筛选手卡或卡组中可以特殊召唤的「原始太阳 赫利俄斯」
function c30241314.filter(c,e,sp)
	return c:IsCode(54493213) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动效果时执行的操作，检索满足条件的「原始太阳 赫利俄斯」并进行特殊召唤
function c30241314.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检索满足条件的「原始太阳 赫利俄斯」卡片组，包括手卡和卡组
	local cg=Duel.GetMatchingGroup(c30241314.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 判断是否有满足条件的卡片且场上存在空位，决定是否可以发动特殊召唤
	if cg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 询问玩家是否要发动特殊召唤效果
		if Duel.SelectYesNo(tp,aux.Stringid(30241314,0)) then  --"是否要特殊召唤？"
			-- 提示玩家选择要特殊召唤的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=cg:Select(tp,1,1,nil)
			-- 将选中的卡片特殊召唤到场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
