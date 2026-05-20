--Aiの儀式
-- 效果：
-- 电子界族仪式怪兽的降临必需。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的「@火灵天星」怪兽解放，从手卡把1只电子界族仪式怪兽仪式召唤。发动时自己场上有「@火灵天星」怪兽存在的场合，自己墓地的「@火灵天星」怪兽也能作为解放的代替而除外。
function c85327820.initial_effect(c)
	-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的「@火灵天星」怪兽解放，从手卡把1只电子界族仪式怪兽仪式召唤。发动时自己场上有「@火灵天星」怪兽存在的场合，自己墓地的「@火灵天星」怪兽也能作为解放的代替而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c85327820.target)
	e1:SetOperation(c85327820.activate)
	c:RegisterEffect(e1)
end
-- 过滤电子界族怪兽（用于仪式召唤的目标怪兽过滤）
function c85327820.filter(c,e,tp)
	return c:IsRace(RACE_CYBERSE)
end
-- 过滤自己场上表侧表示的「@火灵天星」怪兽（用于判断是否满足墓地替代除外条件）
function c85327820.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x135)
end
-- 过滤「@火灵天星」怪兽（用于墓地替代素材过滤）
function c85327820.mfilter(c)
	return c:IsSetCard(0x135)
end
-- 仪式魔法卡发动的效果处理（Target阶段），检查可行性并设置操作信息
function c85327820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式素材，并过滤出其中的「@火灵天星」怪兽
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0x135)
		local mg2=nil
		-- 检查自己场上是否存在表侧表示的「@火灵天星」怪兽
		if Duel.IsExistingMatchingCard(c85327820.cfilter,tp,LOCATION_MZONE,0,1,nil) then
			-- 获取自己墓地中可以作为代替除外的「@火灵天星」怪兽组
			mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,c85327820.mfilter)
		end
		-- 检查手卡中是否存在可以使用上述素材进行仪式召唤的电子界族仪式怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c85327820.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	end
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 再次检查场上是否有「@火灵天星」怪兽，以决定是否在发动时登记除外操作信息
	if Duel.IsExistingMatchingCard(c85327820.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		-- 设置除外的操作信息（从墓地除外卡片）
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_GRAVE)
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end
-- 仪式魔法卡发动后的效果处理（Operation阶段），执行仪式召唤流程
function c85327820.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取手卡·场上可解放的「@火灵天星」怪兽作为仪式素材
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0x135)
	local mg2=nil
	if e:GetLabel()==1 then
		-- 获取墓地中可作为代替除外的「@火灵天星」怪兽组
		mg2=Duel.GetMatchingGroup(aux.RitualExtraFilter,tp,LOCATION_GRAVE,0,nil,c85327820.mfilter)
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足仪式召唤条件的电子界族仪式怪兽
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c85327820.filter,e,tp,mg,mg2,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if mg2 then
			mg:Merge(mg2)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放（或代替除外）的素材怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式召唤等级检查的附加函数（要求等级合计在仪式怪兽等级以上）
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 让玩家选择满足等级合计要求的仪式素材怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除仪式召唤等级检查的附加函数，避免影响后续其他效果
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材（若包含墓地代替素材则将其除外）
		Duel.ReleaseRitualMaterial(mat)
		-- 产生时点中断，使后续的特殊召唤处理与解放处理不视为同时进行
		Duel.BreakEffect()
		-- 将选定的仪式怪兽以仪式召唤的方式从手卡表侧表示特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
