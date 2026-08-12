--花騎士団の駿馬
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只光属性「圣骑士」怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c71736213.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只光属性「圣骑士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71736213,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,71736213)
	e1:SetTarget(c71736213.thtg)
	e1:SetOperation(c71736213.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含场上的这张卡的融合素材怪兽从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71736213,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c71736213.fustg)
	e3:SetOperation(c71736213.fusop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中光属性的「圣骑士」怪兽且能加入手卡
function c71736213.thfilter(c)
	return c:IsSetCard(0x107a) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测，设置操作信息为将卡片加入手卡
function c71736213.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的光属性「圣骑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c71736213.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1只光属性「圣骑士」怪兽加入手卡并给对方确认
function c71736213.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的光属性「圣骑士」怪兽
	local g=Duel.SelectMatchingCard(tp,c71736213.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：位于手卡或怪兽区且不受当前效果影响的卡（作为融合素材）
function c71736213.filter1(c,e)
	return c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中可以进行融合召唤，且能以包含本卡在内的可用素材进行融合召唤的融合怪兽
function c71736213.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 融合召唤效果的发动准备与合法性检测，检查是否存在可融合召唤的怪兽，并设置操作信息
function c71736213.fustg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡·场上可用的融合素材，并过滤掉不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(c71736213.filter1,nil,e)
		-- 检查额外卡组中是否存在可以使用包含场上这张卡在内的素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(c71736213.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在有连锁素材效果影响时，检查是否能使用其指定的素材进行融合召唤
				res=Duel.IsExistingMatchingCard(c71736213.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置连锁的操作信息，表示该效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理：选择融合怪兽，将包含场上此卡的融合素材送去墓地，并从额外卡组融合召唤该怪兽
function c71736213.fusop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 效果处理时，重新获取玩家手卡·场上可用的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c71736213.filter1,nil,e)
	-- 获取当前素材下，额外卡组中所有可以融合召唤的怪兽组合
	local sg1=Duel.GetMatchingGroup(c71736213.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理时，重新获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下，额外卡组中所有可以融合召唤的怪兽组合
		sg2=Duel.GetMatchingGroup(c71736213.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合方式（若只能用常规方式，或玩家在可选时选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合怪兽所需的融合素材（必须包含场上的这张卡）
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时进行（防止错时点）
			Duel.BreakEffect()
			-- 将选定的融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在使用连锁素材效果时，让玩家选择对应的融合素材（必须包含场上的这张卡）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
