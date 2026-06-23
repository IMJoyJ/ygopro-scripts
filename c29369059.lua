--ヤミー☆サプライズ
-- 效果：
-- ①：可以从以下选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●以自己场上2只兽族·光属性怪兽和对方场上2张卡为对象才能发动。那些卡回到手卡。
-- ●从自己的手卡·墓地把1只「味美喵」怪兽特殊召唤。那只怪兽在这个回合不能直接攻击。
-- ●从自己的场上（表侧表示）·墓地让1张场地魔法卡回到手卡。那之后，可以从手卡把1张「味美喵」场地魔法卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡的效果，设置为发动时点，可选择效果
function s.initial_effect(c)
	-- 发动
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
-- 过滤场上2只兽族·光属性怪兽
function s.thfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 过滤「味美喵」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ca) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 过滤表侧表示的场地魔法卡
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 判断是否能选择第1个效果（双方的卡回到手卡）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否已使用过第1个效果
	local b1=(Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked()) and
		-- 判断是否满足第1个效果的条件（场上2只兽族·光属性怪兽和对方场上2张卡）
		Duel.IsExistingTarget(s.thfilter1,tp,LOCATION_MZONE,0,2,nil) and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil)
	-- 判断是否已使用过第2个效果
	local b2=(Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
		-- 判断是否满足第2个效果的条件（手卡·墓地有「味美喵」怪兽且有空场）
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 判断是否已使用过第3个效果
	local b3=(Duel.GetFlagEffect(tp,id+2*o)==0 or not e:IsCostChecked())
		-- 判断是否满足第3个效果的条件（场上或墓地有场地魔法卡）
		and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_FZONE+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家选择发动哪个效果
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"双方的卡回到手卡"
		{b2,aux.Stringid(id,2),2},  --"特殊召唤"
		{b3,aux.Stringid(id,3),3})  --"场地回到手卡"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 标记第1个效果已使用
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场上2只兽族·光属性怪兽
		local g1=Duel.SelectTarget(tp,s.thfilter1,tp,LOCATION_MZONE,0,2,2,nil)
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择对方场上2张卡
		local g2=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
		g1:Merge(g2)
		-- 设置操作信息为将卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,g1:GetCount(),0,0)
	elseif op==2 then
		-- 设置操作信息为特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
			-- 标记第2个效果已使用
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==3 then
		-- 设置操作信息为将场地魔法卡送回手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_FZONE+LOCATION_GRAVE)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND)
			e:SetProperty(0)
			-- 标记第3个效果已使用
			Duel.RegisterFlagEffect(tp,id+2*o,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
-- 过滤「味美喵」场地魔法卡
function s.tffilter(c,tp)
	return c:IsSetCard(0x1ca) and c:IsAllTypes(TYPE_FIELD+TYPE_SPELL)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 处理发动的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 获取与连锁相关的对象
		local tg=Duel.GetTargetsRelateToChain()
		if tg:GetCount()>0 then
			-- 将对象送回手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	elseif op==2 then
		-- 判断是否有空场
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择「味美喵」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 特殊召唤怪兽
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 使该怪兽本回合不能直接攻击
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	elseif op==3 then
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择场地魔法卡
		local tg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_FZONE+LOCATION_GRAVE,0,1,1,nil)
		if tg:GetCount()>0 then
			-- 显示被选为对象的动画效果
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 将卡送回手牌
			if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
				-- 确认对方手牌
				Duel.ConfirmCards(1-tp,tc)
				-- 获取玩家手牌中符合条件的场地魔法卡
				local fg=Duel.GetMatchingGroup(s.tffilter,tp,LOCATION_HAND,0,nil,tp)
				local tfc=nil
				::cancel::
				-- 询问是否将场地魔法卡表侧表示放置
				if fg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否把场地表侧表示放置？"
					-- 提示玩家选择要放置到场上的卡
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
					local tfg=fg:CancelableSelect(tp,1,1,nil)
					if not tfg then goto cancel end
					tfc=tfg:GetFirst()
				end
				-- 洗切玩家手牌
				Duel.ShuffleHand(tp)
				if tfc then
					-- 中断当前效果
					Duel.BreakEffect()
					-- 获取玩家场上已存在的场地魔法卡
					local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
					if fc then
						-- 将旧场地魔法卡送入墓地
						Duel.SendtoGrave(fc,REASON_RULE)
						-- 中断当前效果
						Duel.BreakEffect()
					end
					-- 将场地魔法卡放置到场上
					Duel.MoveToField(tfc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
				end
			end
		end
	end
end
