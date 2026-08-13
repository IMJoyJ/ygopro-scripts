--オッドアイズ・アドベント
-- 效果：
-- 龙族仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的灵摆怪兽解放，从自己的手卡·墓地把1只龙族仪式怪兽仪式召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能作为解放的代替而送去墓地。
function c16494704.initial_effect(c)
	-- 龙族仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的灵摆怪兽解放，从自己的手卡·墓地把1只龙族仪式怪兽仪式召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能作为解放的代替而送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16494704+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c16494704.target)
	e1:SetOperation(c16494704.operation)
	c:RegisterEffect(e1)
end
-- 额外卡组中作为代替送去墓地的「异色眼」怪兽的筛选条件：属于「异色眼」字段、等级1以上且可以送去墓地。
function c16494704.exfilter0(c)
	return c:IsSetCard(0x99) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
-- 仪式召唤对象的筛选条件：必须为龙族怪兽。
function c16494704.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON)
end
-- 发动时进行合法性判定：确认存在符合条件的龙族仪式怪兽，且能用灵摆怪兽作为解放素材（满足条件时额外卡组的「异色眼」怪兽也可代替），并登记特殊召唤的操作信息。
function c16494704.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取可用的仪式素材并过滤出灵摆怪兽（手卡·场上的灵摆怪兽）。
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsType,nil,TYPE_PENDULUM)
		local sg=nil
		-- 判定是否满足额外代替素材的条件：自己场上没有怪兽，且对方场上有2只以上怪兽。
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
			-- 满足条件时，检索额外卡组中可作为「异色眼」代替送去墓地的怪兽组。
			sg=Duel.GetMatchingGroup(c16494704.exfilter0,tp,LOCATION_EXTRA,0,nil)
		end
		-- 检查手卡·墓地中是否存在1只龙族仪式怪兽，能够用灵摆素材（及额外代替素材）满足等级合计大于等于其等级的仪式召唤条件。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c16494704.filter,e,tp,mg,sg,Card.GetLevel,"Greater")
	end
	-- 设定本次效果将进行特殊召唤，且对象可能来自手卡·墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理：重新计算可用灵摆素材与额外代替素材，选择仪式怪兽，选择解放素材，解放灵摆素材并将额外「异色眼」怪兽送去墓地，最后进行仪式召唤。
function c16494704.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 处理阶段重新获取当前可用的仪式素材并过滤出灵摆怪兽。
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsType,nil,TYPE_PENDULUM)
	local sg=nil
	-- 处理阶段再次确认自己场上无怪兽且对方场上有2只以上怪兽，以决定是否可以使用额外代替素材。
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		-- 处理阶段获取额外卡组中可作为代替送去墓地的「异色眼」怪兽。
		sg=Duel.GetMatchingGroup(c16494704.exfilter0,tp,LOCATION_EXTRA,0,nil)
	end
	-- 提示玩家选择要仪式召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只符合条件的龙族仪式怪兽（同时受到王家长眠之谷影响的过滤）。
	local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,c16494704.filter,e,tp,mg,sg,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if sg then
			mg:Merge(sg)
		end
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外检查规则：解放素材的等级合计只需大于等于仪式怪兽的等级（允许溢出）。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 选择一组合法的解放素材，其等级合计至少为仪式怪兽的等级，且整体满足仪式召唤的素材要求。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除之前设置的额外检查规则。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		mat:Sub(mat2)
		-- 解放所选择的手卡·场上的灵摆素材（含墓地的仪式魔人等特殊处理）。
		Duel.ReleaseRitualMaterial(mat)
		-- 将额外卡组中选择的「异色眼」怪兽送去墓地，作为解放的代替。
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使素材处理和仪式召唤成为不同时点，避免错过特殊召唤的时点。
		Duel.BreakEffect()
		-- 将选择的龙族仪式怪兽以表侧表示仪式召唤到自己的场上。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
