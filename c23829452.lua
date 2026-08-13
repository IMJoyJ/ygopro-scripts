--アルトメギアの獄神獣
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：自己·对方的主要阶段才能发动。包含场上的这张卡的自己的手卡·场上的怪兽作为融合素材，把1只「神艺」融合怪兽或「创狱神 涅瓦」融合召唤。
-- ③：这张卡从手卡·场上送去墓地的场合才能发动。同名卡不在自己墓地存在的1张「神艺」魔法·陷阱卡从卡组加入手卡。
local s,id,o=GetID()
-- 初始化注册三个效果：e1为场地永续效果，限制自己不能从额外卡组特殊召唤非融合怪兽；e2为诱发即时效果，在自己/对方主要阶段可将包含这张卡的手卡·场上怪兽作为素材融合召唤「神艺」融合怪兽或「创狱神 涅瓦」；e3为诱发选发效果，这张卡从手卡·场上送入墓地时，从卡组检索1张同名卡不在自己墓地的「神艺」魔法·陷阱卡加入手卡。
function s.initial_effect(c)
	-- 将卡号53589300（创狱神 涅瓦）登记为本卡记载的卡名，用于相关卡名判定。
	aux.AddCodeList(c,53589300)
	-- ①：自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段才能发动。包含场上的这张卡的自己的手卡·场上的怪兽作为融合素材，把1只「神艺」融合怪兽或「创狱神 涅瓦」融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡从手卡·场上送去墓地的场合才能发动。同名卡不在自己墓地存在的1张「神艺」魔法·陷阱卡从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"检索"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 作为①的禁止特殊召唤判定：当尝试从额外卡组特殊召唤的怪兽不是融合怪兽时，禁止该特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- ②的发动条件函数：仅在主要阶段（自己或对方）允许发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段，作为②能否发动的时点判断。
	return Duel.IsMainPhase()
end
-- 过滤可作为融合素材的怪兽：排除对本效果免疫的怪兽，保证素材可被本效果使用。
function s.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 检索额外卡组中符合条件的融合召唤候选：必须是融合怪兽且为「神艺」系列或「创狱神 涅瓦」，并确认能以当前素材融合召唤（素材中需包含场上的这张卡）。
function s.spfilter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (c:IsSetCard(0x1cd) or c:IsCode(53589300)) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ②的发动判定目标：取得基础融合素材并检查额外卡组是否有可融合召唤的符合条件的融合怪兽，若没有则再检查连锁素材是否能提供额外素材，满足时设置特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 在发动判定中，取得玩家可用的基础融合素材（手卡·场上的怪兽及额外融合素材效果提供的卡），并排除对本效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
		-- 检查额外卡组是否存在：能用基础融合素材融合召唤出的符合条件的融合怪兽（「神艺」系列或创狱神 涅瓦）。
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 取得连锁素材效果对象，以便后续使用连锁素材提供的额外融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若基础素材不足，则用连锁素材提供的素材组及限制条件再次检查额外卡组中是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本效果发动后将从额外卡组特殊召唤1只融合怪兽，供其他卡检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②的融合召唤处理：确认这张卡仍合法后，重新获取可用素材，让玩家选择符合条件的「神艺」融合怪兽或「创狱神 涅瓦」，选择素材（必须包含这张卡），将素材送入墓地后以融合召唤方式特殊召唤；若使用连锁素材则执行对应操作。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 在效果处理时，重新取得玩家可用的基础融合素材，并排除对本效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
	-- 取得使用基础融合素材可融合召唤的全部候选融合怪兽（在额外卡组中）。
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 在效果处理时取得连锁素材效果对象，用于支持额外素材融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 取得使用连锁素材后可融合召唤的额外候选融合怪兽（在额外卡组中）。
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 向玩家发送选择提示，要求选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是使用基础素材还是连锁素材：若只存在于基础候选，或玩家选择不使用连锁素材，则按普通融合素材处理；否则使用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材（基础素材组mg1），且必须包含场上的这张卡，并检查满足融合召唤条件。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			if #mat1<2 then goto cancel end
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送入墓地，送墓原因为效果+融合素材+融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使随后的特殊召唤单独成时点，避免因连续处理错失时机。
			Duel.BreakEffect()
			-- 以融合召唤方式将目标融合怪兽表侧攻击表示特殊召唤到其持有者（tp）的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材时，让玩家从连锁素材提供的素材组mg2中选择融合素材（同样必须包含场上的这张卡）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			if #mat2<2 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ③的发动条件函数：确认这张卡是从手卡或场上被送入墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end
-- 检索过滤：对象必须是「神艺」系列魔法·陷阱卡、可以加入手卡，且自己墓地没有同名卡。
function s.thfilter(c,tp)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
		-- 判定自己墓地不存在与该卡同名的卡，以满足『同名卡不在自己墓地存在』的检索条件。
		and not Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,c:GetCode())
end
-- ③的发动目标判定：检查卡组中是否存在1张符合条件的「神艺」魔法·陷阱卡，存在则设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认卡组中有满足条件的「神艺」魔陷，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 设置操作信息：本效果处理时将从卡组把1张卡加入手卡，供相关联动判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③的检索处理：从卡组选择1张符合条件的「神艺」魔法·陷阱卡加入手卡，并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送『请选择要加入手牌的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足s.thfilter的「神艺」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示检索加入手卡的卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
