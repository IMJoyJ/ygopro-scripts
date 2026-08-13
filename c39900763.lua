--異次元の邂逅
-- 效果：
-- ①：双方有除外的自己怪兽1只以上存在的场合才能发动。双方玩家各自选除外的1只自己怪兽里侧守备表示特殊召唤。
function c39900763.initial_effect(c)
	-- ①：双方有除外的自己怪兽1只以上存在的场合才能发动。双方玩家各自选除外的1只自己怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c39900763.target)
	e1:SetOperation(c39900763.operation)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否表侧表示且能否被里侧守备特殊召唤（检查苏生限制与召唤条件）。
function c39900763.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 发动时的目标处理：确认双方有可用怪兽区且各自除外区存在可选怪兽，并登记特殊召唤的操作信息。
function c39900763.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己场上是否还有可用的主要怪兽区空位。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己除外区是否存在至少1只满足filter条件（表侧且可里侧守备特殊召唤）的怪兽。
			and Duel.IsExistingMatchingCard(c39900763.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
			-- 检查对方场上是否有可用的主要怪兽区空位（按对方视角计算可用区域）。
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
			-- 检查对方除外区是否存在至少1只满足filter条件（表侧且可里侧守备特殊召唤）的怪兽。
			and Duel.IsExistingMatchingCard(c39900763.filter,1-tp,LOCATION_REMOVED,0,1,nil,e,1-tp)
	end
	-- 设置本连锁的特殊召唤操作信息：预计有2只怪兽会被特殊召唤，涉及双方玩家。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,PLAYER_ALL,0)
end
-- 效果处理时，在双方都有可用怪兽区的前提下，各自选择除外区1只怪兽里侧守备特殊召唤，最后统一完成特殊召唤流程。
function c39900763.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上仍有空余的主要怪兽区，则进行自己的特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向自己弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己除外区选择1只符合条件（表侧且可里侧守备特殊召唤）的怪兽。
		local g=Duel.SelectMatchingCard(tp,c39900763.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若成功选出怪兽，则以里侧守备表示将其特殊召唤到自己场上（特殊召唤步骤之一）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE) then
			-- 向对方展示自己特殊召唤的这张里侧怪兽（里侧特殊召唤需让对方确认卡片信息）。
			Duel.ConfirmCards(1-tp,tc)
		end
	end
	-- 若对方场上仍有空余的主要怪兽区，则进行对方的特殊召唤处理。
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 then
		-- 向对方弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从对方除外区选择1只符合条件（表侧且可里侧守备特殊召唤）的怪兽。
		local g=Duel.SelectMatchingCard(1-tp,c39900763.filter,1-tp,LOCATION_REMOVED,0,1,1,nil,e,1-tp)
		local tc=g:GetFirst()
		-- 若成功选出怪兽，则以里侧守备表示将其特殊召唤到对方场上（特殊召唤步骤之一）。
		if tc and Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE) then
			-- 向自己展示对方特殊召唤的这张里侧怪兽（里侧特殊召唤需让自己确认卡片信息）。
			Duel.ConfirmCards(tp,tc)
		end
	end
	-- 完成这次效果处理中的所有特殊召唤步骤，并触发特殊召唤成功的相关时点。
	Duel.SpecialSummonComplete()
end
