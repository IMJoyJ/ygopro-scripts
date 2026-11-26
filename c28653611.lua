--ヘル・パニッシャー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只恐龙族·水属性怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。从自己的手卡·卡组·墓地把1只6星以上的炎属性怪兽特殊召唤。这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化卡片效果，注册卡片发动的二选一效果（从卡组检索恐龙族·水属性怪兽，或解放场上怪兽特召手卡·卡组·墓地的6星以上炎属性怪兽）
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。 ●从卡组把1只恐龙族·水属性怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。 ●把自己场上1只怪兽解放才能发动。从自己的手卡·卡组·墓地把1只6星以上的炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查解放该怪兽后自己怪兽区有空位且手卡·卡组·墓地存在可特殊召唤的6星以上炎属性怪兽
function s.costfilter(c,e,tp)
	-- 检查自己手卡·卡组·墓地是否存在至少1只可特殊召唤的6星以上炎属性怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查解放该怪兽后自己怪兽区是否有可用空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- 过滤函数，检查是否为6星以上、炎属性且可特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，检查是否为水属性、恐龙族且可以加入手卡的怪兽
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 发动条件检查与选项处理，校验两个效果分支的可用性与1回合1次限制，选择分支并在选择第2项时解放自己场上1只怪兽作为代价
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在可加入手卡的恐龙族·水属性怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查当前是否免除代价校验，或者本回合尚未选择过第1项效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 在免除代价校验时检查自己怪兽区是否至少有1个空位
	local b2=not e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己手卡·卡组·墓地是否存在至少1只可特殊召唤的6星以上炎属性怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 或者检查自己场上是否存在可作为代价解放的怪兽且本回合尚未选择过第2项效果
		or Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,id+o)==0
	if chk==0 then return b1 or b2 end
	-- 让控制者从当前可用的效果选项中选择要发动的一项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
			-- 为控制者注册本回合已选择第1项效果的标识
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置从卡组检索并将1张卡加入手卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 让控制者从自己场上选择1只作为发动代价解放的怪兽
			local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
			-- 将选中的自己场上怪兽作为发动代价解放
			Duel.Release(g,REASON_COST)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 为控制者注册本回合已选择第2项效果的标识
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置从手卡·卡组·墓地特殊召唤1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
	end
end
-- 效果处理，按所选分支执行检索恐龙族·水属性怪兽并可追加特殊召唤，或特殊召唤6星以上炎属性怪兽并在非恶魔族时无效其效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示控制者从卡组选择要加入手卡的恐龙族·水属性怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己卡组选择1只恐龙族·水属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的怪兽加入自己手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
			-- 检查对方场上是否有怪兽存在且自己怪兽区是否有可用空位
			if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问控制者是否将刚加入手卡的怪兽特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使后续特殊召唤与前面的加入手卡视为不同时处理
				Duel.BreakEffect()
				-- 将刚加入手卡的怪兽表侧表示特殊召唤到自己场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 若自己怪兽区没有可用空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示控制者选择要特殊召唤的6星以上炎属性怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己手卡·卡组·墓地（受王家长眠之谷限制过滤）选择1只6星以上炎属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 以分步方式开始将选中的6星以上炎属性怪兽表侧表示特殊召唤到自己场上
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			and not tc:IsRace(RACE_FIEND) then
			-- 这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成分步特殊召唤处理并正式将其视作特殊召唤成功
		Duel.SpecialSummonComplete()
	end
end
