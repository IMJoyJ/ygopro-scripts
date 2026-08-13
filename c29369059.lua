--ヤミー☆サプライズ
-- 效果：
-- ①：可以从以下选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●以自己场上2只兽族·光属性怪兽和对方场上2张卡为对象才能发动。那些卡回到手卡。
-- ●从自己的手卡·墓地把1只「味美喵」怪兽特殊召唤。那只怪兽在这个回合不能直接攻击。
-- ●从自己的场上（表侧表示）·墓地让1张场地魔法卡回到手卡。那之后，可以从手卡把1张「味美喵」场地魔法卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡片的①效果：创建一个可在自由时点发动的魔法效果，并设定其目标判定函数和效果处理函数，使玩家从三个选项中择一发动。
function s.initial_effect(c)
	-- ①：可以从以下选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于选择第一个选项的“自己场上2只兽族·光属性怪兽”，要求表侧表示、兽族、光属性且可以返回手卡。
function s.thfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 该过滤函数用于选择第二个选项的“从自己的手卡·墓地把1只「味美喵」怪兽特殊召唤”的对象，要求卡名属于「味美喵」系列且满足特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 该过滤函数用于选择第三个选项的“从自己的场上（表侧表示）·墓地让1张场地魔法卡回到手卡”的对象，要求是场地魔法卡、表侧表示（场上）或处于墓地且可以返回手卡。
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果发动时的目标/条件判定函数：检查三个选项是否分别满足发动条件，并让玩家选择其中一个；若选择对应选项，则选择对象或设置操作信息，并登记该选项在本回合的使用次数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定第一个选项（我方2只兽族光属性怪兽和对方2张卡回手）是否满足使用次数限制：本回合尚未使用过该选项，或当前仅为效果可用性预检测（不检查次数限制）。
	local b1=(Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked()) and
		-- 判定第一个选项的对象条件成立：自己场上有2只表侧表示·兽族·光属性怪兽，对方场上有2张可以返回手牌的卡。
		Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_MZONE,0,2,nil) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil)
	-- 判定第二个选项（从手卡·墓地特殊召唤「味美喵」怪兽）是否满足使用次数限制：本回合尚未使用过该选项，或当前仅为效果可用性预检测。
	local b2=(Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
		-- 判定第二个选项的发动条件：自己主要怪兽区有空位，且手卡·墓地存在可以特殊召唤的「味美喵」怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判定第三个选项（场地魔法卡回到手卡）是否满足使用次数限制：本回合尚未使用过该选项，或当前仅为效果可用性预检测。
	local b3=(Duel.GetFlagEffect(tp,id+2*o)==0 or not e:IsCostChecked())
		-- 判定第三个选项的发动条件：自己的场地区或墓地存在可以返回手卡的场地魔法卡。
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_FZONE+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 调用辅助函数，在满足条件的三个选项列表中让玩家选择要发动的效果（1/2/3）。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"双方的卡回到手卡"
		{b2,aux.Stringid(id,2),2},  --"特殊召唤"
		{b3,aux.Stringid(id,3),3})  --"场地回到手卡"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 若为实际发动，登记第一个选项本回合已使用的标记（持续到回合结束），用于限制该选项本回合不能再选。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 显示选择提示“请选择要返回手牌的卡”，为选择自己场上的兽族·光属性怪兽作准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己场上2只表侧表示·兽族·光属性怪兽作为第一个选项的返回手卡对象（取对象）。
		local g1=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_MZONE,0,2,2,nil)
		-- 显示选择提示“请选择要返回手牌的卡”，为选择对方场上的卡作准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上2张可以返回手牌的卡作为第一个选项的返回手卡对象（取对象）。
		local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
		g1:Merge(g2)
		-- 设置操作信息：本次效果将把选中的卡（我方2只怪兽和对方2张卡）全部返回手牌，数量和对象用于连锁判定。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
	elseif op==2 then
		-- 设置操作信息：本次效果将进行特殊召唤，处理时从手卡·墓地选1只怪兽特殊召唤。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			-- 登记第二个选项本回合已使用的标记（持续到回合结束），用于限制该选项本回合不能再选。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==3 then
		-- 设置操作信息：本次效果将把1张场地魔法卡从场上（表侧表示）或墓地返回手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_FZONE+LOCATION_GRAVE)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(0)
			-- 登记第三个选项本回合已使用的标记（持续到回合结束），用于限制该选项本回合不能再选。
			Duel.RegisterFlagEffect(tp,id+2*o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 该过滤函数用于选择“从手卡把1张「味美喵」场地魔法卡在自己场上表侧表示放置”的卡，要求是「味美喵」且同时为场地魔法卡，不属于禁止卡，并且可以合法放置在场地区。
function s.tffilter(c,tp)
	return c:IsSetCard(0x1ca) and c:IsAllTypes(TYPE_FIELD+TYPE_SPELL)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果处理函数：根据发动时选择的选项分别执行——选项1让对象返回手卡；选项2特殊召唤1只「味美喵」怪兽并附加本回合不能直接攻击的效果；选项3回收场上/墓地1张场地魔法卡，并可再选择手卡的「味美喵」场地魔法卡放置到场地区。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 取得发动时选择的对象组（与本连锁关联的卡），用于后续处理返回手卡。
		local tg=Duel.GetTargetsRelateToChain()
		if tg:GetCount()>0 then
			-- 将对象卡全部返回持有者手卡（效果送回）。
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	elseif op==2 then
		-- 特殊召唤处理前检查自己主要怪兽区是否还有空位；若无空位则直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 显示选择提示“请选择要特殊召唤的卡”，为接下来选择怪兽作准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只满足条件的「味美喵」怪兽（使用王家长眠之谷过滤，避免墓地对象不受影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 以表侧表示将选择的怪兽特殊召唤到自己的主要怪兽区，若特殊召唤成功则继续给该怪兽附加不能直接攻击的效果。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 那只怪兽在这个回合不能直接攻击。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		-- 结束这一组特殊召唤处理（与SpecialSummonStep配对使用），使特殊召唤操作正式完成。
		Duel.SpecialSummonComplete()
	elseif op==3 then
		-- 显示选择提示“请选择要返回手牌的卡”，为选择场上/墓地的场地魔法卡作准备。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 从自己的场上（表侧表示）或墓地选择1张可以返回手卡的场地魔法卡（过滤条件已考虑王家长眠之谷的影响）。
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_FZONE+LOCATION_GRAVE,0,1,1,nil)
		if tg:GetCount()>0 then
			-- 手动显示被选中的卡并标记其为对象，用于展示选择结果。
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 将选中的场地魔法卡返回持有者手卡；若实际返回成功（返回值不为0）则继续执行后续“从手卡放置场地魔法卡”的附加处理。
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
				-- 将返回手卡的这张场地魔法卡展示给对手确认。
				Duel.ConfirmCards(1-tp,tc)
				-- 从自己的手卡中检索所有可作为「味美喵」场地魔法卡放置到场地区的卡，作为是否继续放置的判断依据。
				local fg=Duel.GetMatchingGroup(s.tffilter,tp,LOCATION_HAND,0,nil,tp)
				local tfc=nil
				::cancel::
				-- 如果手卡中存在符合条件的「味美喵」场地魔法卡，则询问玩家是否将其表侧表示放置到场地区。
				if fg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把场地表侧表示放置？"
					-- 显示选择提示“请选择要放置到场上的卡”，为选择要放置的场地魔法卡作准备。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
					local tfg=fg:CancelableSelect(tp,1,1,nil)
					if not tfg then goto cancel end
					tfc=tfg:GetFirst()
				end
				-- 洗切自己的手卡，避免因选择手卡中的卡导致手牌顺序信息暴露。
				Duel.ShuffleHand(tp)
				if tfc then
					-- 中断当前效果处理，使后续的场地放置处理作为独立处理（错开时点），避免与前一动作同时处理。
					Duel.BreakEffect()
					-- 获取自己场地区域当前存在的卡，用于后续将其送去墓地以腾出场地区域。
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						-- 按规则将原本在场地区域的场地魔法卡送去墓地（场地魔法卡被新场地替换时的必要处理）。
						Duel.SendtoGrave(fc,REASON_RULE)
						-- 再次中断效果处理，确保新场地放置不会与旧场地的送墓动作产生同时点的干扰。
						Duel.BreakEffect()
					end
					-- 将选择的「味美喵」场地魔法卡以表侧表示放置到自己的场地区域，完成场地放置。
					Duel.MoveToField(tfc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end
