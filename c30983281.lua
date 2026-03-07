--アクセルシンクロ・スターダスト・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从自己墓地把1只2星以下的调整特殊召唤。
-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把1只「星尘龙」当作同调召唤作特殊召唤。那之后，进行1只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
function c30983281.initial_effect(c)
	-- 记录这张卡上记载着另一张卡名“星尘龙”的事实
	aux.AddCodeList(c,44508094)
	-- 为这张卡添加同调召唤手续，要求调整 1 只和调整以外的怪兽 1 只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从自己墓地把 1 只 2 星以下的调整特殊召唤。
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
	-- ②：自己·对方的主要阶段，把这张卡解放才能发动。从额外卡组把 1 只「星尘龙」当作同调召唤作特殊召唤。那之后，进行 1 只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
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
-- 检查这张卡是否是通过同调召唤成功出场的
function c30983281.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤墓地中等级 2 以下且可以特殊召唤的调整怪兽
function c30983281.spfilter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动条件检测，检查场上是否有空格以及墓地是否存在符合条件的调整怪兽
function c30983281.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少 1 张满足过滤条件的卡片
		and Duel.IsExistingMatchingCard(c30983281.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，分类为特殊召唤，预计从墓地特殊召唤 1 张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理操作，选择墓地中 1 只符合条件的调整怪兽并进行特殊召唤
function c30983281.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查场上是否有可用的怪兽区域空格，若无则终止处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择特殊召唤卡片的消息提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地中选择 1 张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c30983281.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将选中的卡片组特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 检查当前阶段是否为自己或对方的主要阶段 1 或主要阶段 2
function c30983281.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的决斗阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤墓地中可以除外作为代价的具有特定效果的卡片
function c30983281.excostfilter(c,tp)
	return c:IsAbleToRemoveAsCost() and c:IsHasEffect(84012625,tp)
end
-- 检查素材组是否符合手卡同调规则且目标同调怪兽可以用该素材组进行同调召唤
function c30983281.syncheck(g,tp,syncard)
	-- 返回手卡同调检查结果以及目标怪兽是否可用指定素材组进行同调召唤的布尔值
	return aux.SynMixHandCheck(g,tp,syncard) and syncard:IsSynchroSummonable(nil,g,#g-1,#g-1)
end
-- 过滤额外卡组中可以进行同调召唤的同调怪兽，并检查素材等级总和
function c30983281.synfilter(c,tp,mg)
	if not c:IsType(TYPE_SYNCHRO) then return false end
	-- 设置同调素材组的额外检查函数，用于验证素材等级总和是否符合目标怪兽等级
	aux.GCheckAdditional=aux.SynGroupCheckLevelAddition(c)
	local res=mg:CheckSubGroup(c30983281.syncheck,2,#mg,tp,c)
	-- 清除同调素材组的额外检查函数
	aux.GCheckAdditional=nil
	return res
end
-- 检查从额外卡组特殊召唤同调怪兽的可行性，包括场上空格和是否存在可同调召唤的怪兽
function c30983281.spcheck(c,tp,rc,mg,opchk)
	-- 检查玩家场上是否有可用于从额外卡组特殊召唤怪兽的空格
	return Duel.GetLocationCountFromEx(tp,tp,rc,c)>0
		-- 检查额外卡组中是否存在至少 1 张可以通过指定素材进行同调召唤的怪兽
		and (opchk or Duel.IsExistingMatchingCard(c30983281.synfilter,tp,LOCATION_EXTRA,0,1,c,tp,mg))
end
-- 过滤额外卡组中卡名为“星尘龙”的卡片，并检查其是否可以进行同调召唤以及后续同调召唤的可行性
function c30983281.scfilter(c,e,tp,rc,chkrel,chknotrel,tgchk,opchk)
	if not (c:IsCode(44508094) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)) then return false end
	-- 获取玩家场上可用于同调召唤的素材怪兽组
	local mg=Duel.GetSynchroMaterial(tp)
	if mg:IsExists(Card.GetHandSynchro,1,nil) then
		-- 获取玩家手卡中的卡片组，用于检查手卡同调素材
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
-- 效果发动的代价检测与支付，检查特殊召唤次数限制、解放条件或除外代替解放条件
function c30983281.sccost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家是否受到特定效果影响及其限制次数
	local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
	-- 检查是否存在额外卡组特殊召唤次数限制的效果对象
	local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
		-- 获取玩家受到的额外卡组特殊召唤次数限制的具体数值
		and aux.ExtraDeckSummonCountLimit[tp]
	-- 获取墓地中可以作为代价除外代替解放的卡片组
	local g=Duel.GetMatchingGroup(c30983281.excostfilter,tp,LOCATION_GRAVE,0,nil,tp)
	local chkrel=c:IsReleasable()
	local chknotrel=g:GetCount()>0
	-- 检查如果解放这张卡，是否存在符合条件的额外卡组怪兽可以特殊召唤
	local b1=chkrel and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,chkrel,nil)
	-- 检查如果使用除外代替解放，是否存在符合条件的额外卡组怪兽可以特殊召唤
	local b2=chknotrel and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,nil,chknotrel)
	-- 检查玩家是否能够进行至少 2 次特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and (not ect1 or ect1>1) and (not ect2 or ect2>1) and (b1 or b2)
		-- 检查玩家是否有必须成为同调素材的效果限制
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL) end
	local rg=Group.CreateGroup()
	local rc=nil
	if b1 then rg:AddCard(c) end
	if b2 then rg:Merge(g) end
	if rg:GetCount()>1 then
		-- 向玩家发送选择要解放或代替解放除外的卡片的消息提示
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(84012625,0))  --"请选择要解放或代替解放除外的卡"
		rc=rg:Select(tp,1,1,nil):GetFirst()
	else
		rc=rg:GetFirst()
	end
	local te=rc:IsHasEffect(84012625,tp)
	if te then
		-- 将选中的卡片除外作为代价代替解放
		Duel.Remove(rc,POS_FACEUP,REASON_COST+REASON_REPLACE)
	else
		-- 将选中的卡片解放作为代价
		Duel.Release(rc,REASON_COST)
	end
end
-- 效果发动的目标检测，验证特殊召唤“星尘龙”及后续同调召唤的可行性
function c30983281.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:IsCostChecked() then return true end
		local c=e:GetHandler()
		-- 检查玩家是否受到特定效果影响及其限制次数
		local ect1=c29724053 and Duel.IsPlayerAffectedByEffect(tp,29724053) and c29724053[tp]
		-- 检查是否存在额外卡组特殊召唤次数限制的效果对象
		local ect2=aux.ExtraDeckSummonCountLimit and Duel.IsPlayerAffectedByEffect(tp,92345028)
			-- 获取玩家受到的额外卡组特殊召唤次数限制的具体数值
			and aux.ExtraDeckSummonCountLimit[tp]
		-- 返回玩家是否能够进行至少 2 次特殊召唤的检测结果
		return Duel.IsPlayerCanSpecialSummonCount(tp,2)
			and (not ect1 or ect1>1) and (not ect2 or ect2>1)
			-- 返回玩家是否有必须成为同调素材的效果限制的检测结果
			and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
			-- 检查额外卡组中是否存在至少 1 张符合条件的“星尘龙”且可以进行后续同调召唤
			and Duel.IsExistingMatchingCard(c30983281.scfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,nil,nil,true)
	end
	-- 设置当前处理的连锁的操作信息，分类为特殊召唤，预计从额外卡组特殊召唤 1 张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理操作，特殊召唤“星尘龙”并赋予免疫效果，之后进行同调召唤并赋予免疫效果
function c30983281.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送选择要特殊召唤的卡片的消息提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组中选择 1 张满足过滤条件的“星尘龙”
	local g=Duel.SelectMatchingCard(tp,c30983281.scfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,c,nil,nil,true,true)
	local tc=g:GetFirst()
	local res=false
	if tc then
		tc:SetMaterial(nil)
		-- 执行特殊召唤步骤，将选中的“星尘龙”当作同调召唤特殊召唤
		if Duel.SpecialSummonStep(tc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP) then
			-- 从额外卡组把 1 只「星尘龙」当作同调召唤作特殊召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
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
	-- 完成特殊召唤步骤，更新场上状态
	Duel.SpecialSummonComplete()
	-- 立刻刷新场地信息，确保状态更新
	Duel.AdjustAll()
	-- 获取额外卡组中可以进行同调召唤的怪兽组
	local tg=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if res and tg:GetCount()>0 then
		-- 中断当前效果，使之后的效果处理视为不同时处理，用于分开两次召唤的时点
		Duel.BreakEffect()
		-- 向玩家发送选择要特殊召唤的卡片的消息提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=tg:Select(tp,1,1,nil)
		-- 那之后，进行 1 只同调怪兽的同调召唤。这个效果同调召唤的怪兽在这个回合不受对方发动的效果影响。
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
		-- 让玩家以选中的怪兽为目标进行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 过滤对方玩家发动的已激活的效果，使怪兽不受这些效果影响
function c30983281.immval(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer() and te:IsActivated()
end
