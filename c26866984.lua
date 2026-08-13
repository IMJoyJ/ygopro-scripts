--トリアス・ヒエラルキア
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段，把自己场上最多3只天使族怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。并且，再让为这个效果发动而解放的怪兽数量的以下效果各能适用。
-- ●2只以上：对方场上1张卡破坏。
-- ●3只：自己抽2张。
function c26866984.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在手卡·墓地存在的场合，自己·对方的主要阶段，把自己场上最多3只天使族怪兽解放才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。并且，再让为这个效果发动而解放的怪兽数量的以下效果各能适用。●2只以上：对方场上1张卡破坏。●3只：自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26866984,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,26866984)
	e1:SetCondition(c26866984.spcon)
	e1:SetCost(c26866984.spcost)
	e1:SetTarget(c26866984.sptg)
	e1:SetOperation(c26866984.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件判定函数：检查当前是否为主要阶段（主要阶段1或主要阶段2），以限定该效果只能在自己或对方的主要阶段发动。
function c26866984.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2时返回true，即满足发动时机条件，允许发动。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数：筛选可作为解放代价的天使族怪兽，条件为种族是天使族，且（控制者为发动玩家或处于表侧表示），用于构造可解放候选组。
function c26866984.cfilter(c,tp)
	return c:IsRace(RACE_FAIRY) and (c:IsControler(tp) or c:IsFaceup())
end
-- 解放代价处理函数：获取可解放的天使族候选组，在发动检查时确认能选择1~3只；发动时提示玩家选择1~3只怪兽，执行解放并保存解放数量。
function c26866984.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得当前玩家可解放的怪兽组，再利用cfilter过滤出满足条件的天使族怪兽，作为解放候选。
	local rg=Duel.GetReleaseGroup(tp):Filter(c26866984.cfilter,nil,tp)
	-- 在发动合法性检查（chk==0）时，确认候选组中存在1~3只怪兽，解放它们后仍能满足主怪兽区空位等条件，以此判断是否满足代价。
	if chk==0 then return rg:CheckSubGroup(aux.mzctcheckrel,1,3,tp) end
	-- 弹出选择提示，告知玩家需要选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家从候选组中选择1~3只满足解放条件的天使族怪兽，作为本次效果的解放代价。
	local g=rg:SelectSubGroup(tp,aux.mzctcheckrel,false,1,3,tp)
	-- 如果使用了代替解放效果（如暗影敌托邦），则消耗对应的额外解放次数，使解放数量正确生效。
	aux.UseExtraReleaseCount(g,tp)
	-- 将选中的怪兽作为代价解放，并把实际解放的数量存入效果标签，供后续判断“2只以上”/“3只”分支使用。
	e:SetLabel(Duel.Release(g,REASON_COST))
end
-- 发动时设定目标与操作信息：确认本卡可以特殊召唤，并根据解放数量更新效果分类；解放3只时追加抽卡类别，再登记特殊召唤操作信息。
function c26866984.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	local ct=e:GetLabel()
	local cat=CATEGORY_SPECIAL_SUMMON
	if ct==3 then
		cat=cat+CATEGORY_DRAW
		-- 解放数量为3时，登记“自己抽2张”的操作信息，指定不取对象、抽卡数量为2，供相关效果连锁检测。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	end
	e:SetCategory(cat)
	-- 登记将这张卡自身特殊召唤的操作信息，数量为1，用于效果处理时的召唤结算与相关连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数：特殊召唤这张卡；成功召唤后赋予其‘离场时除外’效果；再根据解放数量让玩家选择是否发动破坏对方1张卡（2只以上）和抽2张（3只）的分支效果。
function c26866984.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡与当前效果仍有关联后，以表侧攻击表示特殊召唤到己方场上；若特殊召唤成功（返回值不为0）才继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。并且，再让为这个效果发动而解放的怪兽数量的以下效果各能适用。●2只以上：对方场上1张卡破坏。●3只：自己抽2张。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
		local ct=e:GetLabel()
		-- 获取对方场上的所有卡，作为‘对方场上1张卡破坏’的候选集合。
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
		if (ct>=2 and g:GetCount()>0) or ct==3 then
			-- 当解放数量达到2只以上且对方场上有卡时，询问玩家是否发动破坏效果；若选是则进入破坏处理。
			if ct>=2 and g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(26866984,1)) then  --"是否选对方场上1张卡破坏？"
				-- 中断当前效果处理，使后续的破坏结算视为另开连锁，避免错时点。
				Duel.BreakEffect()
				-- 弹出选择提示，告知玩家选择要破坏的卡。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				local dg=g:Select(tp,1,1,nil)
				-- 向双方显示被选中卡片的对象动画，并记录该卡成为效果对象。
				Duel.HintSelection(dg)
				-- 以效果原因破坏选中的对方场上1张卡。
				Duel.Destroy(dg,REASON_EFFECT)
			end
			-- 当解放数量为3只且玩家可以抽卡时，询问玩家是否发动‘自己抽2张’的效果；若选是则进入抽卡处理。
			if ct==3 and Duel.IsPlayerCanDraw(tp,2) and Duel.SelectYesNo(tp,aux.Stringid(26866984,2)) then  --"是否从卡组抽2张？"
				-- 中断当前效果处理，使后续的抽卡结算视为另开连锁，避免错时点。
				Duel.BreakEffect()
				-- 让自己以效果原因从卡组抽2张卡。
				Duel.Draw(tp,2,REASON_EFFECT)
			end
		end
	end
end
