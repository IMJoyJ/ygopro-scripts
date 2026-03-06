--ヘル・パニッシャー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只恐龙族·水属性怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。从自己的手卡·卡组·墓地把1只6星以上的炎属性怪兽特殊召唤。这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
local s,id,o=GetID()
-- 创建并注册卡牌效果，设置为自由连锁发动，具有检索和特殊召唤的分类
function s.initial_effect(c)
	-- 发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足特殊召唤条件的过滤函数，检查是否有满足条件的怪兽且场上存在空位
function s.costfilter(c,e,tp)
	-- 检查场上是否存在满足特殊召唤条件的怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查场上是否存在空位
		and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否满足特殊召唤条件的过滤函数，检查是否为火属性且等级6以上且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足检索条件的过滤函数，检查是否为水属性恐龙族且可加入手牌
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 设置效果的发动条件和选项选择，根据选择的选项设置不同的处理方式和操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的怪兽
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查是否为第一次发动该效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查场上是否存在空位
	local b2=not e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查场上是否存在满足特殊召唤条件的怪兽
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查是否满足解放怪兽的条件且为第一次发动该效果
		or Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,id+o)==0
	if chk==0 then return b1 or b2 end
	-- 让玩家选择发动效果的选项
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
			-- 注册标识效果，防止该效果在本回合再次发动
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息，表示将从卡组检索并加入手牌
		Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 选择满足条件的可解放怪兽
			local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
			-- 以解放怪兽为代价发动效果
			Duel.Release(g,REASON_COST)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 注册标识效果，防止该效果在本回合再次发动
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息，表示将特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
	end
end
-- 处理效果发动后的具体操作，根据选择的选项执行不同的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足检索条件的卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 确认对方查看该卡
			Duel.ConfirmCards(1-tp,tc)
			-- 检查对方场上是否存在怪兽且己方场上存在空位
			if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问玩家是否特殊召唤该卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 将该卡特殊召唤到场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 检查场上是否存在空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足特殊召唤条件的卡
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 开始特殊召唤步骤
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)~=0
			and not tc:IsRace(RACE_FIEND) then
			-- 使该怪兽效果无效
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使该怪兽效果在结束阶段无效
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤处理
		Duel.SpecialSummonComplete()
	end
end
