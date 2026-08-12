--ヘル・パニッシャー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只恐龙族·水属性怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。从自己的手卡·卡组·墓地把1只6星以上的炎属性怪兽特殊召唤。这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
local s,id,o=GetID()
-- 初始化这张卡的魔法卡效果：创建一个魔陷发动类（自由时点）的效果，设定其效果分类为特殊召唤、检索、加入手卡、卡组相关操作，并设定目标函数与效果处理函数后注册到这张卡上
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 代价过滤函数：判断以自己场上这张卡为解放对象时，卡组·墓地·手卡存在可特殊召唤的6星以上炎属性怪兽，且这张卡离开后自己场上仍有可用怪兽区
function s.costfilter(c,e,tp)
	-- 检查自己卡组·墓地·手卡是否存在至少1只满足spfilter条件（6星以上炎属性、可特殊召唤）的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 并且这张卡离开场上后，自己场上仍至少有1个可用的怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤对象过滤函数：筛选炎属性、等级6以上、且能够以这个效果特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检索过滤函数：筛选水属性·恐龙族、且可以加入手卡的怪兽
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 效果的目标函数：分别判定「检索效果」和「特殊召唤」两个选项是否可发动，发动时让玩家选择1个选项并记录；选择检索则设置检索·加入手卡的操作信息并登记回合内使用标识，选择特殊召唤则把1只怪兽解放作为代价，设置特殊召唤的操作信息并登记使用标识
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组是否存在至少1只可加入手卡的恐龙族·水属性怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 并且在进行发动合法性检测（不检查代价）时，或本回合尚未使用过检索选项时
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 判定特殊召唤选项：不检查代价时，要求自己场上有可用怪兽区
	local b2=not e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 并且自己的卡组·墓地·手卡存在至少1只可特殊召唤的6星以上炎属性怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 或者检查代价时，自己场上存在至少1只满足条件的可解放怪兽，且本回合尚未使用过特殊召唤选项
		or Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,id+o)==0
	if chk==0 then return b1 or b2 end
	-- 让玩家从「检索效果」和「特殊召唤」两个选项中选择1个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
			-- 为玩家登记回合结束阶段重置的标识效果，标记本回合已使用过检索选项
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从卡组检索1张卡加入手卡
		Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 让玩家从自己场上选择1只满足条件的怪兽作为解放对象
			local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
			-- 把选择的怪兽解放作为效果发动的代价
			Duel.Release(g,REASON_COST)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 为玩家登记回合结束阶段重置的标识效果，标记本回合已使用过特殊召唤选项
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：从自己的手卡·卡组·墓地把1只怪兽特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
	end
end
-- 效果处理函数：选择检索选项时从卡组选1只恐龙族·水属性怪兽加入手卡并向对方展示，对方场上有怪兽存在的场合可以再询问是否把那只怪兽特殊召唤；选择特殊召唤选项时从手卡·卡组·墓地选1只6星以上的炎属性怪兽特殊召唤，特殊召唤的不是恶魔族的场合把那只怪兽的效果无效化
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向玩家提示「请选择要加入手卡的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1只恐龙族·水属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 把选择的卡以效果原因加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 把加入手卡的那张卡展示给对方确认
			Duel.ConfirmCards(1-tp,tc)
			-- 如果对方场上有怪兽存在且自己场上有可用的怪兽区
			if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 并且是怪兽、可以特殊召唤，再询问玩家是否特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
				-- 中断当前效果处理，使之后的特殊召唤视为不同时处理
				Duel.BreakEffect()
				-- 把加入手卡的那只怪兽在自己场上以表侧表示特殊召唤
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 如果自己场上没有可用的怪兽区则中断处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家提示「请选择要特殊召唤的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的手卡·卡组·墓地选择1只不受「王家长眠之谷」影响的6星以上炎属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 如果选到了卡且那只怪兽成功被特殊召唤（单卡特殊召唤步骤）
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
		-- 完成特殊召唤处理，结束本次特殊召唤步骤
		Duel.SpecialSummonComplete()
	end
end
