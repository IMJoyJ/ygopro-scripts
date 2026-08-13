--パラレル・テレポート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是念动力族怪兽不能特殊召唤。
-- ①：把自己场上1只持有等级的念动力族怪兽解放才能发动。从卡组·额外卡组把1只7星以下的念动力族怪兽特殊召唤。解放的怪兽和这个效果特殊召唤的怪兽的原本等级不同的场合，再让自己失去那个相差×1000基本分。
local s,id,o=GetID()
-- 创建并注册①效果的发动效果：设置效果描述为“特殊召唤”、效果类别为特殊召唤、类型为魔法卡发动、可在自由时点发动、1回合只能发动1次（誓约计数）、设置提示时点、指定解放代价、发动条件和效果处理；随后注册自定义活动计数器，用于限制本回合不能特殊召唤非念动力族怪兽。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只持有等级的念动力族怪兽解放才能发动。从卡组·额外卡组把1只7星以下的念动力族怪兽特殊召唤。解放的怪兽和这个效果特殊召唤的怪兽的原本等级不同的场合，再让自己失去那个相差×1000基本分。
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
	-- 注册特殊召唤活动计数器：每当有特殊召唤发生时，若特殊召唤的怪兽不是念动力族，则计数器增加（上限1）；用于代价检查中确认本回合尚未进行过非念动力族特殊召唤。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数：若怪兽为念动力族则返回true（允许该特殊召唤，不增加计数）；否则返回false（该特殊召唤会使计数增加，代表违背了自肃）。
function s.counterfilter(c)
	return c:IsRace(RACE_PSYCHO)
end
-- 解放候选过滤：怪兽必须是念动力族、持有等级，并且当前状态下存在至少1只可从卡组·额外卡组特殊召唤的7星以下念动力族怪兽；这样解放后效果能成功处理。
function s.costfilter(c,e,tp)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelAbove(1)
		-- 检查存在至少1张满足spfilter的特殊召唤候选（7星以下念动力族、可被效果特殊召唤且区域允许），保证解放代价能达成后续特殊召唤。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 特殊召唤候选过滤：必须是念动力族且7星以下，可被当前效果特殊召唤；若在卡组，则要求解放ec后我方有可用怪兽区；若在额外卡组，则要求解放ec后还有可用的额外/主怪兽区空格。
function s.spfilter(c,e,tp,ec)
	return c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 候选在卡组时：解放作为代价的怪兽ec后，我方场上至少留有1个可用怪兽区。
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp,ec)>0
		-- 候选在额外卡组时：解放ec后，额外卡组怪兽有可用的特殊召唤区域（GetLocationCountFromEx检查主怪兽区或额外怪兽区空格）。
		or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 代价检查：chk==0时，确认本回合没有进行过非念动力族特殊召唤，且场上存在可解放的合适怪兽；满足则代价合法。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合特殊召唤活动计数为0，即本回合尚未特殊召唤过非念动力族怪兽，满足发动自肃条件。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0
		-- 并且场上存在至少1只可解放的怪兽（满足costfilter），作为发动代价。
		and Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) end
	-- 从自己场上选择1只满足costfilter的怪兽，作为要被解放的代价怪兽。
	local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetOriginalLevel())
	-- 将选择的怪兽解放（REASON_COST），支付代价。
	Duel.Release(g,REASON_COST)
	-- 这张卡发动的回合，自己不是念动力族怪兽不能特殊召唤。①：把自己场上1只持有等级的念动力族怪兽解放才能发动。从卡组·额外卡组把1只7星以下的念动力族怪兽特殊召唤。解放的怪兽和这个效果特殊召唤的怪兽的原本等级不同的场合，再让自己失去那个相差×1000基本分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(s.splimit)
	-- 给玩家tp注册一个场地永续效果：该回合内不能特殊召唤非念动力族怪兽（EFFECT_CANNOT_SPECIAL_SUMMON），结束阶段时自动重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制判定：如果特殊召唤的怪兽不是念动力族，则禁止该特殊召唤（返回true表示‘不能特殊召唤’）。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PSYCHO)
end
-- 效果发动目标：确认代价已满足（e:IsCostChecked），然后设置操作信息，声明将从卡组·额外卡组特殊召唤1只怪兽，不取对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置本次效果的操作信息：进行1次从卡组·额外卡组区域挑选并特殊召唤的处理，目标数为1，目标玩家为tp，供连锁检测（如星尘龙等）使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 效果处理：让玩家选择1只符合条件的念动力族怪兽并特殊召唤；如果其原本等级与解放的怪兽原本等级不同，则计算等级差并准备扣除LP（×1000）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择卡片的提示框，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·额外卡组中，选择1张满足spfilter的念动力族怪兽（7星以下、可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选择到的卡存在且特殊召唤成功（表侧表示），则继续后续等级差判定。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:GetOriginalLevel()~=e:GetLabel() then
		local lv=0
		if tc:GetOriginalLevel()>e:GetLabel() then lv=tc:GetOriginalLevel()-e:GetLabel()
		else lv=e:GetLabel()-tc:GetOriginalLevel() end
		-- 扣除玩家tp的LP，数值为等级差×1000，对应‘失去那个相差×1000基本分’。
		Duel.SetLP(tp,Duel.GetLP(tp)-lv*1000)
	end
end
