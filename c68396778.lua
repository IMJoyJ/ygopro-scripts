--悪魔への貢物
-- 效果：
-- 选择场上1只特殊召唤的怪兽送去墓地，从手卡把1只4星以下的通常怪兽特殊召唤。
function c68396778.initial_effect(c)
	-- 选择场上1只特殊召唤的怪兽送去墓地，从手卡把1只4星以下的通常怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c68396778.target)
	e1:SetOperation(c68396778.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上特殊召唤的怪兽
function c68396778.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤手卡中等级4以下且可以特殊召唤的通常怪兽
function c68396778.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与可行性检查（Target函数）
function c68396778.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c68396778.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在可以作为对象的特殊召唤的怪兽
		and Duel.IsExistingTarget(c68396778.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查手卡中是否存在可以特殊召唤的4星以下通常怪兽
		and Duel.IsExistingMatchingCard(c68396778.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68396778.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理的执行函数（Activate函数）
function c68396778.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽因效果送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
		-- 检查对象怪兽是否成功送去墓地，且自己场上仍有可用的怪兽区域
		if tc:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 从手卡选择1只满足条件的4星以下通常怪兽
			local g=Duel.SelectMatchingCard(tp,c68396778.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选择的通常怪兽以表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
