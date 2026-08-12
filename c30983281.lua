--アクセルシンクロ・スターダスト・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只2星以下的调整特殊召唤。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤。那之后，进行1只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
function c30983281.initial_effect(c)
	-- 将「星尘龙」的卡片密码加入当前卡片的关联卡片列表中
	aux.AddCodeList(c,44508094)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只2星以下的调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30983281,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,30983281)
	e1:SetCondition(c30983281.spcon)
	e1:SetTarget(c30983281.sptg)
	e1:SetOperation(c30983281.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤。那之后，进行1只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30983281,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,30983282)
	e2:SetCondition(c30983281.sccon)
	e2:SetCost(c30983281.sccost)
	e2:SetTarget(c30983281.sctg)
	e2:SetOperation(c30983281.scop)
	c:RegisterEffect(e2)
end
-- 效果①发动条件判断：此卡是通过同调召唤方式特殊召唤成功的场合
function c30983281.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：筛选自己墓地2星以下且能够特殊召唤的调整怪兽
function c30983281.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①目标阶段：确认己方场上有空位且存在符合条件的墓地怪兽，并注册特殊召唤的操作信息
function c30983281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有可以特殊召唤怪兽的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地是否存在至少1只符合条件的能够特殊召唤的调整怪兽
		and Duel.IsExistingMatchingCard(c30983281.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理时的特殊召唤操作信息，预计从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①处理阶段：将选中的墓地怪兽特殊召唤到场上
function c30983281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无可用怪兽区域，则特殊召唤处理终止
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要进行特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在自己墓地选择1只符合条件的特殊召唤目标怪兽
	local g=Duel.SelectMatchingCard(tp,c30983281.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的调整怪兽以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②发动条件判断：必须在自己或对方的主要阶段才能发动
function c30983281.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的决斗阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤条件：筛选能够作为代替解放成本而除外的墓地怪兽
function c30983281.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- 校验所选同调素材在手卡同调等规则下是否合法
function c30983281.syncheck(g,tp,syncard)
	-- 进行手卡同调素材校验，并判断该同调怪兽能否通过当前选定的素材组进行同调召唤
	return aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 过滤条件：筛选额外卡组中能够通过当前同调素材合法同调召唤的怪兽
function c30983281.synfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调召唤素材等级辅助校验函数，以辅助计算可同调召唤的怪兽组合
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c30983281.syncheck,2,#mg,tp,c)
	-- 清除同调召唤素材等级辅助校验函数的全局钩子设置
	aux.GCheckAdditional=nil
	return res
end
-- 过滤条件：确认若将此卡解放（或墓地卡除外代替）后，额外卡组是否还能特殊召唤「星尘龙」并进行同调召唤
function c30983281.spcheck(c,tp,rc,mg,opchk)
	-- 检查当前解放/代替解放的卡片离场后，额外卡组是否有空位将怪兽特殊召唤到场上
	return Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
		-- 检查额外卡组是否依然存在至少1只可以合法进行同调召唤的同调怪兽
		and (opchk or Duel.IsExistingMatchingCard(c30983281.synfilter,tp,LOCATION_EXTRA,0,1,c,tp,mg))
end
-- 过滤条件：筛选额外卡组中可以通过此卡效果以同调召唤方式特殊召唤的「星尘龙」
function c30983281.scfilter(c,e,tp,rc,chkrel,chknotrel,tgchk,opchk)
	if not (c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)) then return false end
	-- 获取当前玩家在场上的所有符合同调召唤素材条件的怪兽集合
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取当前玩家手卡中的所有怪兽集合
		local mg2=Duel.GetMatchingGroup(nil,tp,LOCATION_HAND,0,nil)
		if mg2:GetCount()>0 then mg:Merge(mg2) end
	end
	mg:AddCard(c)
	if tgchk then
		return c30983281.spcheck(c,tp,nil,mg,opchk)
	else
		return (chkrel and c30983281.spcheck(c,tp,rc,mg-rc)) or (chknotrel and c30983281.spcheck(c,tp,nil,mg))
	end
end
-- 效果②发动成本阶段：检查玩家是否能够特殊召唤、是否受到各种次数限制，并执行解放或代替解放的发动成本
function c30983281.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取玩家当前受到的特殊召唤次数限制效果影响信息
	local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查玩家是否受到额外卡组召唤次数限制效果的影响
	local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
		-- 获取玩家被限制的额外卡组剩余特殊召唤次数
		and aux.ExtraDeckSummonCountLimit[tp]
	local g=Group.CreateGroup()
	-- 若此卡符合特定卡片系列，则把墓地符合代替解放成本的卡合并进候选集合中
	if c:IsSetCard(0xa3) then g:Merge(Duel.GetMatchingGroup(c30983281.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)) end
	local chkrel=c:IsReleasable()
	local chknotrel=g:GetCount()>0
	-- 判断是否能够正常解放此卡并特殊召唤「星尘龙」以及进行后续的同调召唤
	local b1=chkrel and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,chkrel,nil)
	-- 判断是否能够通过除外墓地的代替卡作为成本来特殊召唤「星尘龙」以及进行后续同调召唤
	local b2=chknotrel and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,nil,chknotrel)
	-- 效果成本检查：确认玩家在此效果处理中能够进行至少2次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and (not ect1 or ect1>1) and (not ect2 or ect2>1) and (b1 or b2)
		-- 检查玩家是否有必须作为同调素材的怪兽限制条件需要满足
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) end
	local rg=Group.CreateGroup()
	local rc=nil
	if b1 then rg:AddCard(c) end
	if b2 then rg:Merge(g) end
	if rg:GetCount()>1 then
		-- 向玩家发送提示信息，要求选择用于支付成本的解放或代替解放除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		rc=rg:Select(tp,1,1,nil):GetFirst()
	else
		rc=rg:GetFirst()
	end
	local te=rc:IsHasEffect(84012625,tp)
	if te then
		-- 将作为代替解放成本的怪兽以表侧表示除外
		Duel.Remove(rc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将此卡解放以支付效果的发动成本
		Duel.Release(rc,REASON_COST)
	end
end
-- 效果②目标阶段：注册特殊召唤操作信息，并确认是否符合多次特殊召唤的限制
function c30983281.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsCostChecked() then return true end
		local c=e:GetHandler()
		-- 目标阶段检查：确认当前玩家受到的特殊召唤次数限制效果影响
		local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
		-- 目标阶段检查：确认玩家是否受到额外卡组特殊召唤次数限制效果影响
		local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
			-- 获取玩家受到的剩余额外卡组特殊召唤次数限制
			and aux.ExtraDeckSummonCountLimit[tp]
		-- 确认当前玩家在后续效果处理中是否还能进行至少2次特殊召唤
		return Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and (not ect1 or ect1>1) and (not ect2 or ect2>1)
			-- 目标阶段检查：确认是否满足必须作为同调素材的限制条件
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 目标阶段检查：确认额外卡组中依然存在符合效果要求的「星尘龙」
			and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,nil,nil,true)
	end
	-- 设置连锁处理时的特殊召唤操作信息，预计从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理阶段：特殊召唤「星尘龙」，赋予其免疫效果，随后再进行1只同调怪兽的同调召唤
function c30983281.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示信息，要求选择从额外卡组特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择1只符合条件的「星尘龙」
	local g=Duel.SelectMatchingCard(tp,c30983281.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,nil,nil,true,true)
	local tc=g:GetFirst()
	local res=false
	if tc then
		tc:SetMaterial(nil)
		-- 将选中的「星尘龙」当作同调召唤从额外卡组特殊召唤，如果特殊召唤成功则赋予其免疫效果
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(30983281,2))  --"「加速同调星尘龙」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_IMMUNE_EFFECT)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(c30983281.immval)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetOwnerPlayer(tp)
			tc:RegisterEffect(e1,true)
			tc:CompleteProcedure()
			res=true
		end
	end
	-- 完成当前步骤的怪兽特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 立即刷新场地上的卡片信息，以保证后续同调召唤的合法性检查无误
	Duel.AdjustAll()
	-- 获取玩家额外卡组中当前可以合法进行同调召唤的所有怪兽
	local tg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if res and tg:GetCount()>0 then
		-- 中断当前效果，使得随后的同调召唤操作在规则时间点上不与先前的特殊召唤视为同时发生
		Duel.BreakEffect()
		-- 向玩家发送提示信息，要求选择进行同调召唤的同调怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 那之后，进行1只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(30983281,2))  --"「加速同调星尘龙」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c30983281.immval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		e1:SetOwnerPlayer(tp)
		sg:GetFirst():RegisterEffect(e1,true)
		-- 让玩家对选出的同调怪兽进行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 过滤条件：不受对方发动的效果影响的免疫效果判断函数
function c30983281.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer() and te:IsActivated()
end
