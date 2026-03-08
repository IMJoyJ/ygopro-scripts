--異次元の邂逅
-- 效果：
-- ①：双方有除外的自己怪兽1只以上存在的场合才能发动。双方玩家各自选除外的1只自己怪兽里侧守备表示特殊召唤。
function c39900763.initial_effect(c)
	-- 效果原文：①：双方有除外的自己怪兽1只以上存在的场合才能发动。双方玩家各自选除外的1只自己怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39900763.target)
	e1:SetOperation(c39900763.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查一张卡是否为表侧表示且可以里侧守备表示特殊召唤
function c39900763.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果的发动条件判断：检查自己和对方是否都有除外的自己怪兽，且各自场上都有空位
function c39900763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己除外区是否有满足条件的怪兽
			and Duel.IsExistingMatchingCard(c39900763.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			-- 检查对方场上是否有空位
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
			-- 检查对方除外区是否有满足条件的怪兽
			and Duel.IsExistingMatchingCard(c39900763.filter,1-tp,LOCATION_REMOVED,0,1,nil,e,1-tp)
	end
	-- 设置效果处理信息：确定将特殊召唤2张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end
-- 效果处理函数：分别处理自己和对方的特殊召唤
function c39900763.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择自己除外区中满足条件的1张怪兽
		local g=Duel.SelectMatchingCard(tp,c39900763.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 尝试特殊召唤该怪兽（里侧守备表示）
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
			-- 确认对方能看到该怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- 检查对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 提示对方选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择对方除外区中满足条件的1张怪兽
		local g=Duel.SelectMatchingCard(1-tp,c39900763.filter,1-tp,LOCATION_REMOVED,0,1,1,nil,e,1-tp)
		local tc=g:GetFirst()
		-- 尝试特殊召唤该怪兽（里侧守备表示）
		if tc and Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE) then
			-- 确认自己能看到该怪兽
			Duel.ConfirmCards(tp,tc)
		end
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
