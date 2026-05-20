--グローアップ・バルブ
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在墓地存在的场合才能发动。自己卡组最上面的卡送去墓地，这张卡特殊召唤。
function c67441435.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡在墓地存在的场合才能发动。自己卡组最上面的卡送去墓地，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67441435,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,67441435+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(c67441435.target)
	e1:SetOperation(c67441435.operation)
	c:RegisterEffect(e1)
end
-- 检查发动条件：玩家是否能将卡组最上面的卡送去墓地，且自身是否能特殊召唤到怪兽区域
function c67441435.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否可以把卡组最上面的1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示该效果包含将卡组顶端的卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
	-- 设置操作信息，表示该效果包含将这张卡特殊召唤的处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自己卡组最上面的卡送去墓地，若成功送去墓地且这张卡仍存在于墓地，则将这张卡特殊召唤
function c67441435.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 将自己卡组最上面的1张卡送去墓地，并判断是否成功送去墓地
	if Duel.DiscardDeck(tp,1,REASON_EFFECT)~=0 then
		-- 获取刚刚因效果被送去墓地的卡片
		local oc=Duel.GetOperatedGroup():GetFirst()
		local c=e:GetHandler()
		if oc:IsLocation(LOCATION_GRAVE) and c:IsRelateToEffect(e) then
			-- 将这张卡以表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
