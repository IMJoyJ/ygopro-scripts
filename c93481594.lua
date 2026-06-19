--幸せの多重奏
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●选自己1张手卡丢弃，从卡组把2只灵摆刻度不同的「七音服」灵摆怪兽加入手卡。那之后，可以把最多有对方场上的怪兽数量＋1只的「七音服」灵摆怪兽从手卡特殊召唤。
-- ●这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「七音服」怪兽灵摆召唤。
-- ●自己的灵摆区域2张「七音服」卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「七音服」灵摆怪兽的条件函数。
function s.thfilter(c)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检查卡片组中2张卡的灵摆刻度是否不同的条件函数。
function s.gcheck(g)
	return g:GetClassCount(Card.GetCurrentScale)==2
end
-- 过滤灵摆区域中可以特殊召唤的「七音服」怪兽的条件函数。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检测函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取卡组中所有满足条件的「七音服」灵摆怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local b1=g:CheckSubGroup(s.gcheck,2,2)
		-- 检查手卡中是否存在除这张卡以外可以因效果丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c,REASON_EFFECT)
		and (not e:IsCostChecked()
			-- 或者是本回合尚未选择过第1个效果。
			or Duel.GetFlagEffect(tp,id)==0)
	-- 检查本回合是否尚未适用过第2个效果的额外灵摆召唤。
	local b2=Duel.GetFlagEffect(tp,id+o*3)==0
		and (not e:IsCostChecked()
			-- 或者是本回合尚未选择过第2个效果。
			or Duel.GetFlagEffect(tp,id+o)==0)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	local b3=not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上的怪兽区域空位数是否大于1。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查自己的灵摆区域是否存在至少2只可以特殊召唤的「七音服」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_PZONE,0,2,nil,e,tp)
		and (not e:IsCostChecked()
			-- 或者是本回合尚未选择过第3个效果。
			or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 or b3 end
	local op=0
	if b1 or b2 or b3 then
		-- 让玩家从可发动的效果中选择1个。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2},  --"额外灵摆"
			{b3,aux.Stringid(id,3),3})  --"特殊召唤"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_HANDES_SELF|CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(0)
			-- 给玩家注册本回合已选择第2个效果的标识。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==3 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			-- 给玩家注册本回合已选择第3个效果的标识。
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置从灵摆区域特殊召唤2只怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_PZONE)
	end
end
-- 过滤手牌中可以特殊召唤的「七音服」灵摆怪兽的条件函数。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的执行函数。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==1 then
		-- 让玩家选择并丢弃1张手卡，若未成功丢弃则处理终止。
		if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil,REASON_EFFECT)==0 then return end
		-- 获取卡组中所有满足条件的「七音服」灵摆怪兽。
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 and g:CheckSubGroup(s.gcheck,2,2) then
			-- 提示玩家选择要加入手牌的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local ag=g:SelectSubGroup(tp,s.gcheck,false,2,2)
			if ag then
				-- 将选中的卡加入玩家手卡。
				Duel.SendtoHand(ag,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手牌的卡。
				Duel.ConfirmCards(1-tp,ag)
				-- 获取对方场上的怪兽数量。
				local dt=Duel.GetMatchingGroupCount(aux.TRUE,tp,0,LOCATION_MZONE,nil)
				-- 获取自己场上可用的怪兽区域空格数。
				local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
				if ft<=0 then return end
				if ft>dt+1 then ft=dt+1 end
				-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
				if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
				-- 检查手卡中是否存在可特殊召唤的怪兽且有可用区域，并询问玩家是否进行特殊召唤。
				if Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) and ft>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
					-- 提示玩家选择要特殊召唤的怪兽。
					Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
					-- 让玩家选择最多等同于可召唤数量的「七音服」灵摆怪兽。
					local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
					if sg:GetCount()>0 then
						-- 中断当前效果，使后续的特殊召唤处理不与检索同时处理。
						Duel.BreakEffect()
						-- 洗切玩家的手卡。
						Duel.ShuffleHand(tp)
						-- 将选中的怪兽以表侧表示特殊召唤。
						Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
					end
				end
			end
		end
	elseif e:GetLabel()==2 then
		-- 检查本回合是否已经适用过该额外灵摆召唤效果，若已适用则不处理。
		if Duel.GetFlagEffect(tp,id+o*3)~=0 then return end
		-- ●这个回合，自己在通常的灵摆召唤外加上只有1次，自己主要阶段可以把「七音服」怪兽灵摆召唤。●自己的灵摆区域2张「七音服」卡特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,5))  --"使用「幸福的多重奏」的效果灵摆召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_EXTRA_PENDULUM_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetCountLimit(1,id)
		e1:SetValue(s.pendvalue)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 在全局环境中注册该额外灵摆召唤的效果。
		Duel.RegisterEffect(e1,tp)
		-- 给玩家注册本回合已适用额外灵摆召唤的标识。
		Duel.RegisterFlagEffect(tp,id+o*3,RESET_PHASE+PHASE_END,0,1)
	elseif e:GetLabel()==3 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
		-- 检查自己场上的怪兽区域空位数是否小于2，若小于2则无法特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
		-- 获取自己灵摆区域中所有满足特殊召唤条件的「七音服」卡。
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_PZONE,0,nil,e,tp)
		if g:GetCount()>=2 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=g:Select(tp,2,2,nil)
			-- 将选中的2张灵摆卡特殊召唤。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 限制额外灵摆召唤只能用于「七音服」怪兽的辅助函数。
function s.pendvalue(e,c)
	return c:IsSetCard(0x162)
end
