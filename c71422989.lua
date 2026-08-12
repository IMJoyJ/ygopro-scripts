--吸光融合
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「宝石骑士」怪兽不能特殊召唤。
-- ①：从卡组把1张「宝石骑士」卡加入手卡。那之后，以下效果可以适用。
-- ●自己的手卡·场上的怪兽作为融合素材除外，把1只「宝石骑士」融合怪兽融合召唤。
function c71422989.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张，这张卡发动的回合，自己不是「宝石骑士」怪兽不能特殊召唤。①：从卡组把1张「宝石骑士」卡加入手卡。那之后，以下效果可以适用。●自己的手卡·场上的怪兽作为融合素材除外，把1只「宝石骑士」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,71422989+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c71422989.cost)
	e1:SetTarget(c71422989.target)
	e1:SetOperation(c71422989.activate)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于记录本回合特殊召唤非「宝石骑士」怪兽的次数
	Duel.AddCustomActivityCounter(71422989,ACTIVITY_SPSUMMON,c71422989.counterfilter)
end
-- 过滤函数，用于检查特殊召唤的怪兽是否为「宝石骑士」怪兽
function c71422989.counterfilter(c)
	return c:IsSetCard(0x1047)
end
-- 发动代价处理函数，检查本回合是否特殊召唤过非「宝石骑士」怪兽，并施加本回合不能特殊召唤非「宝石骑士」怪兽的限制
function c71422989.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合是否未特殊召唤过非「宝石骑士」怪兽
	if chk==0 then return Duel.GetCustomActivityCount(71422989,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这张卡发动的回合，自己不是「宝石骑士」怪兽不能特殊召唤。①：从卡组把1张「宝石骑士」卡加入手卡。那之后，以下效果可以适用。●自己的手卡·场上的怪兽作为融合素材除外，把1只「宝石骑士」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c71422989.splimit)
	-- 在全局注册不能特殊召唤非「宝石骑士」怪兽的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的过滤函数，限制不能特殊召唤非「宝石骑士」怪兽
function c71422989.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1047)
end
-- 过滤函数，用于检索卡组中可以加入手牌的「宝石骑士」卡
function c71422989.filter(c)
	return c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 效果发动时的目标确认与操作信息设置函数
function c71422989.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「宝石骑士」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71422989.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示此效果包含从卡组将1张卡加入手牌的处理
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选可以被除外且不受该效果影响的融合素材怪兽
function c71422989.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 过滤函数，用于筛选额外卡组中可以进行融合召唤的「宝石骑士」融合怪兽
function c71422989.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理函数，执行检索「宝石骑士」卡以及后续可选的融合召唤处理
function c71422989.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「宝石骑士」卡
	local g=Duel.SelectMatchingCard(tp,c71422989.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		local chkf=tp
		-- 获取玩家手卡和场上可以作为融合素材除外的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(c71422989.filter1,nil,e)
		-- 获取额外卡组中可以使用上述素材进行融合召唤的「宝石骑士」融合怪兽
		local sg1=Duel.GetMatchingGroup(c71422989.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		-- 获取玩家受到的连锁素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取在使用连锁素材效果时可以融合召唤的「宝石骑士」融合怪兽
			sg2=Duel.GetMatchingGroup(c71422989.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		-- 如果存在可以融合召唤的怪兽，询问玩家是否进行融合召唤
		if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(71422989,0)) then  --"是否把「宝石骑士」融合怪兽融合召唤"
			-- 中断当前效果处理，使后续的融合召唤与检索不视为同时处理
			Duel.BreakEffect()
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要特殊召唤的融合怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			-- 判断是否使用常规的融合素材进行融合召唤
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 让玩家选择用于融合召唤的融合素材
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				-- 将选择的融合素材怪兽除外
				Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使特殊召唤与除外素材不视为同时处理
				Duel.BreakEffect()
				-- 将融合怪兽以融合召唤的方式特殊召唤
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				-- 在使用连锁素材效果时，让玩家选择对应的融合素材
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	end
end
