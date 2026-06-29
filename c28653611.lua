--ヘル・パニッシャー
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把1只恐龙族·水属性怪兽加入手卡。对方场上有怪兽存在的场合，可以再把加入手卡的那只怪兽特殊召唤。
-- ●把自己场上1只怪兽解放才能发动。从自己的手卡·卡组·墓地把1只6星以上的炎属性怪兽特殊召唤。这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
local s,id,o=GetID()
-- 注册卡片发动并允许选择检索或特召效果的激活效果
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
-- 用作解放代价的自己场上怪兽的过滤条件
function s.costfilter(c,e,tp)
	-- 检查自己手卡/卡组/墓地是否存在可被特殊召唤的炎属性高星怪兽
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 检查在将该怪兽解放后，自己场上是否能留有空闲怪兽区域进行特殊召唤
		and Duel.GetMZoneCount(tp,c)>0
end
-- 可特殊召唤的6星以上炎属性怪兽的过滤条件
function s.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevelAbove(6)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 可检索的恐龙族·水属性怪兽的过滤条件
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand()
end
-- 卡片发动准备与多分支效果选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在恐龙族·水属性怪兽且本回合尚未发动分支1
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 确保分支1在整回合的非代价状态下符合发动次数限制
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 在非代价计算下检查是否能正常特殊召唤6星以上炎属性怪兽
	local b2=not e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 在非代价计算下，检查自己场上是否有可解放怪兽且本回合尚未发动分支2
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp)
		-- 若为实际发动，检查自己场上是否存在可用于解放的怪兽
		or Duel.CheckReleaseGroup(tp,s.costfilter,1,nil,e,tp) and Duel.GetFlagEffect(tp,id+o)==0
	if chk==0 then return b1 or b2 end
	-- 询问并允许玩家在可用的分支效果中选择其一发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2})  --"特殊召唤"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
			-- 若选择分支1且当前为实际发动，则在玩家身上登记分支1已被使用
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息为从卡组检索怪兽
		Duel.SetOperationInfo(0,CATEGORY_SEARCH+CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 若选择分支2且当前为实际发动，则让玩家选择自己场上1只怪兽解放作为代价
			local g=Duel.SelectReleaseGroup(tp,s.costfilter,1,1,nil,e,tp)
			-- 解放选中的怪兽
			Duel.Release(g,REASON_COST)
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 在玩家身上登记分支2已被使用
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息为特殊召唤怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND)
	end
end
-- 所选择分支效果 of execution
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 向玩家发送提示，请选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只恐龙族·水属性怪兽
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			local tc=g:GetFirst()
			-- 将选中的恐龙族·水属性怪兽加入手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
			-- 检查对方场上是否存在怪兽且自己场上是否有空怪兽区域
			if Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				and tc:IsType(TYPE_MONSTER) and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 询问玩家是否特殊召唤刚刚加入手卡的恐龙族·水属性怪兽
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
				-- 切断效果处理的连锁时点
				Duel.BreakEffect()
				-- 将该怪兽特殊召唤到自己场上
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		-- 若自己场上已无空怪兽区域，则效果不处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家发送提示，请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡、卡组、墓地选择1只满足条件的6星以上炎属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 将选中的炎属性怪兽特殊召唤到场上但暂不完成
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			and not tc:IsRace(RACE_FIEND) then
			-- 这个效果把恶魔族以外的怪兽特殊召唤的场合，那只怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 注册使特殊召唤的非恶魔族怪兽效果无效的单体持续限制效果
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤程序
		Duel.SpecialSummonComplete()
	end
end
