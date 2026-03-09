--高等儀式術
-- 效果：
-- ①：等级合计直到变成和仪式召唤的怪兽相同为止，把卡组的通常怪兽送去墓地，从手卡把1只仪式怪兽仪式召唤。
function c46052429.initial_effect(c)
	-- 效果原文内容：①：等级合计直到变成和仪式召唤的怪兽相同为止，把卡组的通常怪兽送去墓地，从手卡把1只仪式怪兽仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46052429.target)
	e1:SetOperation(c46052429.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查手牌中的怪兽是否可以作为仪式召唤的素材（必须是通常怪兽且能特殊召唤）
function c46052429.filter(c,e,tp,m)
	if bit.band(c:GetType(),0x81)~=0x81
		or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_RITUAL,tp,false,true) then return false end
	if c.mat_filter then
		m=m:Filter(c.mat_filter,nil,tp)
	end
	return m:CheckWithSumEqual(Card.GetRitualLevel,c:GetLevel(),1,99,c)
end
-- 过滤函数，检查卡组中是否含有通常怪兽且能送去墓地
function c46052429.matfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 判断是否满足发动条件：手牌中有可仪式召唤的怪兽，且场上有足够空间
function c46052429.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断场上是否有足够的怪兽区域进行特殊召唤
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		-- 获取卡组中所有通常怪兽作为可能的仪式素材
		local mg=Duel.GetMatchingGroup(c46052429.matfilter,tp,LOCATION_DECK,0,nil)
		-- 检查手牌中是否存在符合条件的仪式怪兽
		return Duel.IsExistingMatchingCard(c46052429.filter,tp,LOCATION_HAND,0,1,nil,e,tp,mg)
	end
	-- 设置操作信息：准备从手牌特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数，执行仪式召唤流程
function c46052429.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次判断场上是否有足够的怪兽区域进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	::cancel::
	-- 获取卡组中所有通常怪兽作为可能的仪式素材
	local mg=Duel.GetMatchingGroup(c46052429.matfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一只符合条件的仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,c46052429.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,mg)
	if tg:GetCount()>0 then
		local tc=tg:GetFirst()
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,nil,tp)
		end
		local lv=tc:GetLevel()
		-- 提示玩家选择要送去墓地的通常怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 设置额外条件：所选素材等级总和不能超过仪式怪兽等级
		aux.GCheckAdditional=function(sg) return sg:GetSum(Card.GetRitualLevel,tc)<=lv end
		-- 从满足条件的卡组通常怪兽中选择符合等级要求的组合
		local mat=mg:SelectSubGroup(tp,aux.RitualCheckEqual,true,1,99,tc,lv)
		-- 清除额外条件设置
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 将选中的通常怪兽送去墓地作为仪式召唤的素材
		Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，防止后续效果同时处理
		Duel.BreakEffect()
		-- 将选中的仪式怪兽以仪式召唤方式特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
