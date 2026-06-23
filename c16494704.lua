--オッドアイズ・アドベント
-- 效果：
-- 龙族仪式怪兽的降临必需。这个卡名的卡在1回合只能发动1张。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的灵摆怪兽解放，从自己的手卡·墓地把1只龙族仪式怪兽仪式召唤。对方场上有怪兽2只以上存在，自己场上没有怪兽存在的场合，自己的额外卡组的「异色眼」怪兽也能作为解放的代替而送去墓地。
function c16494704.initial_effect(c)
	-- 效果设定：将此卡注册为发动时点为自由时点的魔法卡，且每回合只能发动一次，发动时会特殊召唤一只龙族仪式怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16494704+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c16494704.target)
	e1:SetOperation(c16494704.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选出玩家手牌中满足「异色眼」系列、等级大于等于1、可以送入墓地的灵摆怪兽
function c16494704.exfilter0(c)
	return c:IsSetCard(0x99) and c:IsLevelAbove(1) and c:IsAbleToGrave()
end
-- 过滤函数：筛选出玩家手牌中满足龙族的怪兽
function c16494704.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON)
end
-- 效果发动时点的处理：检查是否存在满足条件的仪式怪兽，若存在则设置操作信息为特殊召唤
function c16494704.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取玩家可用的仪式召唤素材组，筛选出灵摆怪兽
		local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsType,nil,TYPE_PENDULUM)
		local sg=nil
		-- 判断条件：对方场上怪兽数量大于等于2，且自己场上没有怪兽
		if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
			-- 获取满足条件的额外卡组中的「异色眼」怪兽作为替代解放的素材
			sg=Duel.GetMatchingGroup(c16494704.exfilter0,tp,LOCATION_EXTRA,0,nil)
		end
		-- 检查是否存在满足仪式召唤条件的龙族仪式怪兽
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,c16494704.filter,e,tp,mg,sg,Card.GetLevel,"Greater")
	end
	-- 设置操作信息：表示将特殊召唤1只来自手牌或墓地的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果发动时点的处理：选择要特殊召唤的仪式怪兽，并进行后续的解放和召唤处理
function c16494704.operation(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 获取玩家可用的仪式召唤素材组，筛选出灵摆怪兽
	local mg=Duel.GetRitualMaterial(tp):Filter(Card.IsType,nil,TYPE_PENDULUM)
	local sg=nil
	-- 判断条件：对方场上怪兽数量大于等于2，且自己场上没有怪兽
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>1 then
		-- 获取满足条件的额外卡组中的「异色眼」怪兽作为替代解放的素材
		sg=Duel.GetMatchingGroup(c16494704.exfilter0,tp,LOCATION_EXTRA,0,nil)
	end
	-- 提示玩家选择要特殊召唤的仪式怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的仪式怪兽
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
		-- 提示玩家选择要解放的素材
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置额外的仪式召唤检查函数，用于验证等级合计是否满足要求
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		-- 从可用素材中选择满足仪式召唤条件的素材组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		-- 清除额外的仪式召唤检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local mat2=mat:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
		mat:Sub(mat2)
		-- 将选中的素材进行解放处理
		Duel.ReleaseRitualMaterial(mat)
		-- 将额外卡组中被选中的素材送去墓地
		Duel.SendtoGrave(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 将选中的仪式怪兽以仪式召唤方式特殊召唤到场上
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
