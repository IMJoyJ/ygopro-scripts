--ヘヴィ・トリガー
-- 效果：
-- 「装弹枪管暴动龙」的降临必需。
-- ①：等级合计直到8以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己的手卡·场上的「弹丸」怪兽破坏，从手卡把「装弹枪管暴动龙」仪式召唤。这个效果特殊召唤的怪兽不会被和从额外卡组特殊召唤的怪兽的战斗破坏，不受从额外卡组特殊召唤的怪兽发动的效果影响。
function c20071842.initial_effect(c)
	-- 将卡名「装弹枪管暴动龙」（卡号7987191）登记到本卡的代码列表，用于表明本卡效果文本中记载了该卡名，便于程序检索关联。
	aux.AddCodeList(c,7987191)
	-- ①：等级合计直到8以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己的手卡·场上的「弹丸」怪兽破坏，从手卡把「装弹枪管暴动龙」仪式召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20071842,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20071842.target)
	e1:SetOperation(c20071842.activate)
	c:RegisterEffect(e1)
end
-- 定义仪式召唤所需的等级基准：固定返回8，表示需要素材等级合计达到8以上（配合Greater判定）。
function c20071842.lv(c)
	return 8
end
-- 筛选条件：卡片必须是「装弹枪管暴动龙」（卡号7987191），用于从手牌中选出仪式召唤的对象。
function c20071842.filter(c,e,tp)
	return c:IsCode(7987191)
end
-- 筛选可代替解放被破坏的「弹丸」系列怪兽：需要是等级0以上的怪兽、属于「弹丸」系列、并且能够被效果破坏。
function c20071842.mfilter(c,e)
	return c:IsLevelAbove(0) and c:IsSetCard(0x102) and c:IsDestructable(e)
end
-- 发动时的目标判定与操作信息设置：chk==0时检查手牌是否有「装弹枪管暴动龙」且场上有可用的仪式素材（含可代替解放破坏的弹丸怪兽），满足后设置特殊召唤与破坏的操作信息。
function c20071842.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取当前玩家可用于仪式召唤的通常素材组（包括手牌、场上可解放的怪兽以及墓地中可作为仪式魔人的卡）。
		local mg1=Duel.GetRitualMaterial(tp)
		-- 获取可代替解放被破坏的「弹丸」系列怪兽组，范围为手牌和主要怪兽区的我方卡片。
		local mg2=Duel.GetMatchingGroup(c20071842.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		-- 通过仪式召唤核心过滤函数检查是否存在符合条件的仪式怪兽，且可用通常素材或弹丸素材凑齐等级合计≥8。
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,c20071842.filter,e,tp,mg1,mg2,c20071842.lv,"Greater")
	end
	-- 设置操作信息：本效果将进行特殊召唤，目标是从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本效果可能进行破坏，破坏涉及手牌和主要怪兽区的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_HAND+LOCATION_MZONE)
end
-- 效果处理：选择要仪式召唤的「装弹枪管暴动龙」，选择素材；将通常素材解放，将「弹丸」怪兽代替解放破坏；仪式召唤成功后将怪兽区中的该怪兽附加战斗破坏抗性和效果免疫抗性。
function c20071842.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	-- 在效果处理阶段重新获取当前可用的通常仪式素材组，以确保最新状态。
	local mg1=Duel.GetRitualMaterial(tp)
	-- 在效果处理阶段重新获取当前可用的可代替解放破坏的「弹丸」怪兽组。
	local mg2=Duel.GetMatchingGroup(c20071842.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足条件的「装弹枪管暴动龙」作为仪式召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,c20071842.filter,e,tp,mg1,mg2,c20071842.lv,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		-- 提示玩家选择要解放或破坏的仪式素材。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(20071842,1))  --"请选择要解放或破坏的怪兽"
		-- 设置额外素材等级检查函数，确保所选素材的等级合计达到8以上（Greater模式允许超过8），并防止选择多余无用素材。
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,8,"Greater")
		-- 让玩家在可选素材中选择1～8张作为仪式素材，要求这些素材能够满足等级合计≥8的仪式条件。
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,8,tp,tc,8,"Greater")
		-- 清除额外等级检查函数，避免影响后续其他效果。
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		-- 统计所选素材中属于通常仪式素材（mg1）的数量。
		local ct1=mat:FilterCount(aux.IsInGroup,nil,mg1)
		-- 统计所选素材中属于可代替解放破坏的「弹丸」怪兽（mg2）的数量。
		local ct2=mat:FilterCount(aux.IsInGroup,nil,mg2)
		local dg=mat-mg1
		local mat1=mat:Clone()
		local mat2
		if ct1==0 then
			mat2=mat
			mat1:Clear()
		-- 若选择了「弹丸」怪兽素材，且存在必须破坏的非通常素材，或玩家确认选择「弹丸」怪兽破坏，则执行破坏代替解放的后续分支。
		elseif ct2>0 and (#dg>0 or Duel.SelectYesNo(tp,aux.Stringid(20071842,2))) then  --"是否选择「弹丸」怪兽破坏？"
			local min=math.max(#dg,1)
			-- 提示玩家选择要破坏的「弹丸」怪兽卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			mat2=mat:SelectSubGroup(tp,c20071842.descheck,false,min,#mat,mg2,dg)
			mat1:Sub(mat2)
		end
		if #mat1>0 then
			-- 将通常仪式素材（mat1）解放，作为仪式召唤的代价。
			Duel.ReleaseRitualMaterial(mat1)
		end
		if mat2 then
			-- 向对方玩家展示将被破坏的「弹丸」怪兽卡，确认破坏对象。
			Duel.ConfirmCards(1-tp,mat2)
			-- 以效果、作为仪式素材、仪式召唤相关的原因，将代替解放的「弹丸」怪兽破坏。
			Duel.Destroy(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		-- 中断当前效果处理，使后续特殊召唤视为新的效果处理流程，避免时点被占用或错过。
		Duel.BreakEffect()
		-- 将选择的「装弹枪管暴动龙」以仪式召唤方式特殊召唤到自己的怪兽区（正面表示）。
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
		-- 这个效果特殊召唤的怪兽不会被和从额外卡组特殊召唤的怪兽的战斗破坏，不受从额外卡组特殊召唤的怪兽发动的效果影响。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(c20071842.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetValue(c20071842.immval)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(20071842,3))  --"「重型扳机」效果适用中"
	end
end
-- 定义选择破坏素材时的过滤函数：用于从候选的「弹丸」怪兽中选出包含全部非通常素材（dg）且全部来自可破坏弹丸组（mg2）的素材组。
function c20071842.descheck(g,mg2,dg)
	-- 判定逻辑：选中的素材组g必须包含所有非通常素材dg，且g中的每张卡都必须是可破坏的「弹丸」怪兽（属于mg2）。
	return g:FilterCount(aux.IsInGroup,nil,dg)==#dg and mg2:FilterCount(aux.IsInGroup,nil,g)==#g
end
-- 定义战斗破坏抗性的具体判定条件：只有与从额外卡组特殊召唤的怪兽战斗时，该怪兽不会被战斗破坏。
function c20071842.indval(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 定义效果免疫抗性的具体判定条件：免疫从额外卡组特殊召唤的怪兽在怪兽区发动的已发动的怪兽效果（不包括自身效果和魔法陷阱）。
function c20071842.immval(e,te)
	local tc=te:GetOwner()
	return tc~=e:GetHandler() and te:IsActiveType(TYPE_MONSTER) and te:IsActivated()
		and te:GetActivateLocation()==LOCATION_MZONE and tc:IsSummonLocation(LOCATION_EXTRA)
end
