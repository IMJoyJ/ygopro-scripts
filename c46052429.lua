--高等儀式術
-- 效果：
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把卡组的通常怪兽送去墓地，从手卡把1只仪式怪兽仪式召唤。
function c46052429.initial_effect(c)
	-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把卡组的通常怪兽送去墓地，从手卡把1只仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46052429.target)
	e1:SetOperation(c46052429.activate)
	c:RegisterEffect(e1)
end
-- 检查手牌中的仪式怪兽是否为仪式怪兽且能被仪式召唤特殊召唤；若该怪兽有素材限制，则进一步过滤可用素材组。
function c46052429.filter(c,e,tp,m)
	if bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	return m:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
end
-- 判断卡组中的卡是否为通常怪兽且能够送去墓地，即可作为仪式素材。
function c46052429.matfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 发动时的效果目标判定：确认场上是否有空位、卡组有无可用通常怪兽素材、手牌有无满足条件的仪式怪兽；满足后设置特殊召唤的操作信息。
function c46052429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己主要怪兽区是否有空位，若无空位则无法发动。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 取得卡组中所有可作为仪式素材的通常怪兽的集合。
		local mg=Duel.GetMatchingGroup(c46052429.matfilter,tp,LOCATION_DECK,0,nil)
		-- 检查手牌中是否存在满足仪式召唤条件的仪式怪兽。
		return Duel.IsExistingMatchingCard(c46052429.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
	end
	-- 设置本次效果将进行特殊召唤的操作信息（从手牌特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理阶段：从卡组选择通常怪兽作为素材送入墓地，并从手牌将仪式怪兽仪式召唤。
function c46052429.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己主要怪兽区是否有空位，无空位则不能处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	::cancel::
	-- 重新取得卡组中所有可作为仪式素材的通常怪兽，供玩家选择。
	local mg=Duel.GetMatchingGroup(c46052429.matfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌选择1只满足条件的仪式怪兽作为特殊召唤对象。
	local tg=Duel.SelectMatchingCard(tp,c46052429.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		local lv=tc:GetLevel()
		-- 提示玩家选择要送去墓地的仪式素材卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 设置额外的素材选择限制，使已选素材的等级合计不得超过仪式怪兽的等级。
		aux.GCheckAdditional=function(sg) return sg:GetSum(Card.GetRitualLevel,tc)<=lv end
		-- 让玩家从卡组中选择素材，使素材等级合计恰好等于仪式怪兽的等级（至少1张）。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheckEqual,true,1,99,tc,lv)
		-- 清除额外的素材选择限制，避免影响后续操作。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将选中的素材卡以效果·素材·仪式召唤的原因送去墓地。
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果链，使后续的仪式召唤处理与送墓处理分开，避免错过时点。
		Duel.BreakEffect()
		-- 将仪式怪兽以仪式召唤方式特殊召唤到场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
