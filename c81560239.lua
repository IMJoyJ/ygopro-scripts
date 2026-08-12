--巳剣降臨
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·场上的爬虫类族怪兽解放，从卡组把1只爬虫类族仪式怪兽仪式召唤。
-- ●等级合计直到变成和仪式召唤的怪兽相同为止，把自己的手卡·卡组·场上最多2只爬虫类族怪兽解放，从手卡把1只爬虫类族仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤可仪式召唤的爬虫类族怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_REPTILE)
end
-- 过滤可作为仪式素材解放的爬虫类族怪兽
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsRace(RACE_REPTILE) and c:IsReleasable(REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
-- 定义仪式素材数量检查函数，限制素材数量最多为2只
function s.rcheck(tp,g,c)
	return g:GetCount()<3
end
-- 定义仪式素材组数量检查函数，限制素材数量最多为2只
function s.rgcheck(g,ec)
	return g:GetCount()<3
end
-- 效果发动时的目标选择与合法性检查函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡·场上可作为仪式素材的爬虫类族怪兽
	local mg1=Duel.GetRitualMaterial(tp):Filter(Card.IsRace,nil,RACE_REPTILE)
	-- 获取卡组中可作为仪式素材的爬虫类族怪兽
	local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
	-- 检查卡组中是否存在可进行仪式召唤的爬虫类族仪式怪兽（效果1）
	local s1=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	-- 将仪式素材数量检查函数注册为全局附加检查
	aux.RCheckAdditional=s.rcheck
	-- 将仪式素材组数量检查函数注册为全局附加检查
	aux.RGCheckAdditional=s.rgcheck
	-- 检查手卡中是否存在可进行仪式召唤的爬虫类族仪式怪兽（效果2）
	local s2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,s.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	-- 重置全局仪式素材数量附加检查
	aux.RCheckAdditional=nil
	-- 重置全局仪式素材组数量附加检查
	aux.RGCheckAdditional=nil
	-- 检查效果1（从卡组仪式召唤）是否可行，且本回合未选择过该效果
	local b1=s1 and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 检查效果2（从手卡仪式召唤）是否可行，且本回合未选择过该效果
	local b2=s2 and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	-- 让玩家从可发动的效果中选择1个
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"从卡组仪式召唤"
		{b2,aux.Stringid(id,2),2})  --"从手卡仪式召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			-- 给玩家注册本回合已选择效果1的标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置特殊召唤卡组怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 给玩家注册本回合已选择效果2的标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置特殊召唤手卡怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	end
end
-- 效果处理函数，根据玩家的选择执行对应的仪式召唤处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		s.spop1(e,tp,eg,ep,ev,re,r,rp)
	elseif op==2 then
		s.spop2(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 效果1的处理函数：从卡组仪式召唤爬虫类族仪式怪兽
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	::cancel1::
	-- 获取手卡·场上可作为仪式素材的爬虫类族怪兽
	local mg1=Duel.GetRitualMaterial(tp):Filter(Card.IsRace,nil,RACE_REPTILE)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足仪式召唤条件的爬虫类族仪式怪兽
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的素材怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材等级检查函数，要求等级合计必须严格等于仪式怪兽的等级
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 让玩家选择符合仪式召唤条件的素材怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 重置仪式素材等级检查函数
		aux.GCheckAdditional=nil
		if not mat then goto cancel1 end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断效果处理，使之后的特殊召唤不与解放同时处理
		Duel.BreakEffect()
		-- 将目标怪兽以仪式召唤的方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 效果2的处理函数：从手卡仪式召唤爬虫类族仪式怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	::cancel2::
	-- 将仪式素材数量检查函数注册为全局附加检查
	aux.RCheckAdditional=s.rcheck
	-- 将仪式素材组数量检查函数注册为全局附加检查
	aux.RGCheckAdditional=s.rgcheck
	-- 获取手卡·场上可作为仪式素材的爬虫类族怪兽
	local mg1=Duel.GetRitualMaterial(tp):Filter(Card.IsRace,nil,RACE_REPTILE)
	-- 获取卡组中可作为仪式素材的爬虫类族怪兽
	local mg2=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足仪式召唤条件的爬虫类族仪式怪兽
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,s.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放的素材怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 设置仪式素材等级检查函数，要求等级合计必须严格等于仪式怪兽的等级
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
		-- 让玩家选择符合仪式召唤条件的素材怪兽组
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
		-- 重置仪式素材等级检查函数
		aux.GCheckAdditional=nil
		if not mat then
			-- 重置全局仪式素材数量附加检查
			aux.RCheckAdditional=nil
			-- 重置全局仪式素材组数量附加检查
			aux.RGCheckAdditional=nil
			goto cancel2
		end
		tc:SetMaterial(mat)
		-- 解放选定的仪式素材
		Duel.ReleaseRitualMaterial(mat)
		-- 中断效果处理，使之后的特殊召唤不与解放同时处理
		Duel.BreakEffect()
		-- 将目标怪兽以仪式召唤的方式特殊召唤
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	-- 重置全局仪式素材数量附加检查
	aux.RCheckAdditional=nil
	-- 重置全局仪式素材组数量附加检查
	aux.RGCheckAdditional=nil
end
