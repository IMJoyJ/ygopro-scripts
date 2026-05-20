--計都星辰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组把1只「星辰」怪兽加入手卡。对方场上有怪兽存在的场合，可以再让以下效果适用。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只龙族·魔法师族的融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片的效果初始化函数，定义该卡的发动效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从卡组把1只「星辰」怪兽加入手卡。对方场上有怪兽存在的场合，可以再让以下效果适用。●自己的手卡·场上的怪兽作为融合素材，把1只龙族·魔法师族的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「星辰」系列且可以加入手牌的怪兽卡。
function s.thfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的目标选择与合法性检测函数。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「星辰」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表明此效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤不受此卡效果影响的卡片（用于融合素材过滤）。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的龙族或魔法师族融合怪兽。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON+RACE_SPELLCASTER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理的核心逻辑函数，包含检索和后续可选的融合召唤处理。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的「星辰」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
		-- 立即刷新场上所有卡片的状态信息。
		Duel.AdjustAll()
		local chkf=tp
		-- 获取玩家手卡和场上可用于融合召唤的素材，并过滤掉不受效果影响的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组中是否存在可以使用当前素材进行融合召唤的合法怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」等卡片的影响）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，额外卡组中是否存在可融合召唤的合法怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 检查对方场上是否有怪兽存在，且自己有可融合召唤的怪兽，并询问玩家是否进行融合召唤。
		if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and res and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否进行融合召唤？"
			-- 中断当前效果处理，使后续的融合召唤与检索不视为同时处理。
			Duel.BreakEffect()
			-- 洗切玩家的手牌。
			Duel.ShuffleHand(tp)
			-- 获取额外卡组中所有可以使用手卡·场上素材进行融合召唤的怪兽组。
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 再次获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取额外卡组中所有可以使用连锁素材效果进行融合召唤的怪兽组。
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 给玩家发送提示信息，提示选择要特殊召唤的融合怪兽。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判断选择的融合怪兽是否只能使用手卡·场上的素材进行召唤，或者玩家选择不使用连锁素材效果。
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 让玩家选择用于融合召唤该怪兽的手卡·场上素材。
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
					tc:SetMaterial(mat1)
					-- 将选定的融合素材送去墓地。
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断效果处理，使送去墓地与特殊召唤不视为同时处理。
					Duel.BreakEffect()
					-- 将选定的融合怪兽以融合召唤的方式表侧表示特殊召唤。
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 让玩家选择用于连锁素材效果融合召唤该怪兽的素材。
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
