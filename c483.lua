--パラレル・テレポート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是念动力族怪兽不能特殊召唤。
-- ①：把自己场上1只持有等级的念动力族怪兽解放才能发动。从卡组·额外卡组把1只7星以下的念动力族怪兽特殊召唤。解放的怪兽和这个效果特殊召唤的怪兽的原本等级不同的场合，再让自己失去那个相差×1000基本分。
local s,id,o=GetID()
-- 初始化效果，创建并注册发动效果
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是念动力族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 设置计数器，用于限制每回合特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，仅对念动力族卡片生效
function s.counterfilter(c)
	return c:IsRace(RACE_PSYCHO)
end
-- 解放怪兽的过滤条件，必须是念动力族且等级大于等于1
function s.costfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(1)
		-- 检查是否存在满足特殊召唤条件的念动力族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤目标怪兽的过滤条件，必须是念动力族、等级7以下且可特殊召唤
function s.spfilter(c,e,tp,ec)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若目标在卡组，则检查是否有可用怪兽区
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,ec)>0
		-- 若目标在额外卡组，则检查是否有可用额外召唤区域
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 发动费用函数，检查是否满足发动条件
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合首次特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		-- 检查场上是否存在可解放的念动力族怪兽
		and Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) end
	-- 选择并解放符合条件的念动力族怪兽
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选中的怪兽从场上解放作为发动代价
	Duel.Release(g,REASON_COST)
	-- 设置永续效果，禁止非念动力族怪兽特殊召唤
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	-- 注册该禁止效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 禁止特殊召唤效果的过滤函数，仅对非念动力族怪兽生效
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PSYCHO)
end
-- 设置发动时的处理信息，确定将要特殊召唤的怪兽数量和位置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置操作信息，表示将特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 发动效果的处理函数，选择并特殊召唤目标怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或额外卡组中选择一只满足条件的念动力族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽特殊召唤到场上
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:GetOriginalLevel()~=e:GetLabel() then
		local lv=0
		if tc:GetOriginalLevel()>e:GetLabel() then lv=tc:GetOriginalLevel()-e:GetLabel()
		else lv=e:GetLabel()-tc:GetOriginalLevel() end
		-- 若等级不同则扣除相应基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-lv*1000)
	end
end
