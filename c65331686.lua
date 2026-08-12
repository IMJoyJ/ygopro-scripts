--ファーニマル・オウル
-- 效果：
-- 「毛绒动物·猫头鹰」的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1张「融合」加入手卡。
-- ②：支付500基本分才能发动。从自己的手卡·场上把「魔玩具」融合怪兽决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
function c65331686.initial_effect(c)
	-- ①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1张「融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65331686,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,65331686)
	e1:SetCondition(c65331686.thcon)
	e1:SetTarget(c65331686.thtg)
	e1:SetOperation(c65331686.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：支付500基本分才能发动。从自己的手卡·场上把「魔玩具」融合怪兽决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65331686,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,65331686)
	e3:SetCost(c65331686.cost)
	e3:SetTarget(c65331686.target)
	e3:SetOperation(c65331686.operation)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否是从手卡召唤·特殊召唤成功
function c65331686.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤卡组中卡名为「融合」且能加入手牌的卡
function c65331686.thfilter(c)
	return c:IsCode(24094653) and c:IsAbleToHand()
end
-- 效果①的靶效果（检查卡组是否存在「融合」并设置检索的操作信息）
function c65331686.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「融合」
	if chk==0 then return Duel.IsExistingMatchingCard(c65331686.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理（从卡组将1张「融合」加入手牌并给对方确认）
function c65331686.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「融合」
	local g=Duel.SelectMatchingCard(tp,c65331686.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的代价（支付500基本分）
function c65331686.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 过滤不受该效果影响的卡（用于融合素材）
function c65331686.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的「魔玩具」融合怪兽
function c65331686.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xad) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②的靶效果（检查是否存在可融合召唤的「魔玩具」怪兽并设置特殊召唤的操作信息）
function c65331686.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手牌和场上可用的融合素材
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的「魔玩具」融合怪兽
		local res=Duel.IsExistingMatchingCard(c65331686.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下，是否存在可以融合召唤的「魔玩具」融合怪兽
				res=Duel.IsExistingMatchingCard(c65331686.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示该效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理（选择1只「魔玩具」融合怪兽，将素材送去墓地并进行融合召唤）
function c65331686.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手牌和场上可用且不受此效果影响的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(c65331686.filter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「魔玩具」融合怪兽组
	local sg1=Duel.GetMatchingGroup(c65331686.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下可以融合召唤的「魔玩具」融合怪兽组
		sg2=Duel.GetMatchingGroup(c65331686.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与送去墓地不视为同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以表侧表示进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
