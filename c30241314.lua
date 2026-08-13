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
-- 效果发动时的合法性检查：在发动时（chk==0）直接返回true，表示这个效果没有额外的发动条件限制。
function c30241314.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 筛选满足条件的卡：卡名必须是「原始太阳 赫利俄斯」（卡号54493213），并且能够被当前效果特殊召唤。
function c30241314.filter(c,e,sp)
	return c:IsCode(54493213) and c:IsCanBeSpecialSummoned(e,0,sp,false,false)
end
-- 发动效果时的处理：从手卡·卡组中寻找符合条件的「原始太阳 赫利俄斯」，若存在且怪兽区有空位，则由玩家选择是否特殊召唤并执行。
function c30241314.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方手卡和卡组中所有符合filter条件的「原始太阳 赫利俄斯」卡，作为可特殊召唤的候选集合。
	local cg=Duel.GetMatchingGroup(c30241314.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	-- 判断是否存在候选卡，且我方主要怪兽区域是否有空位可进行特殊召唤。
	if cg:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出“是否要特殊召唤？”的确认提示，玩家选择是才继续执行特殊召唤流程。
		if Duel.SelectYesNo(tp,aux.Stringid(30241314,0)) then  --"是否要特殊召唤？"
			-- 发送选择卡片的提示，要求玩家从候选卡中选出要特殊召唤的那1只「原始太阳 赫利俄斯」。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=cg:Select(tp,1,1,nil)
			-- 将选中的「原始太阳 赫利俄斯」以表侧攻击表示特殊召唤到我方场上（此操作会检查其召唤条件与苏生限制）。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
