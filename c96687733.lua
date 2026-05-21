--神殿の守護神
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只地属性融合怪兽融合召唤。把有「王家的神殿」的卡名记述的自己场上的怪兽作为融合素材的场合，对方场上的表侧表示怪兽也能作为融合素材。
-- ②：自己场上有「王家的神殿」存在的场合，把墓地的这张卡除外才能发动。从卡组把1张「神之怒」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含融合召唤效果和墓地检索效果
function s.initial_effect(c)
	-- 将「王家的神殿」和「神之怒」的卡片密码注册到这张卡的关联卡片列表中
	aux.AddCodeList(c,29762407,22082432)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只地属性融合怪兽融合召唤。把有「王家的神殿」的卡名记述的自己场上的怪兽作为融合素材的场合，对方场上的表侧表示怪兽也能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「王家的神殿」存在的场合，把墓地的这张卡除外才能发动。从卡组把1张「神之怒」加入手卡。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.thcon)
	-- 将墓地的这张卡除外作为发动效果的Cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上可以作为融合素材且能送去墓地的表侧表示怪兽
function s.filter0(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤不受效果影响的怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以进行融合召唤的地属性融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_EARTH) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 在融合素材检查中临时加入自定义的素材校验函数
	aux.FCheckAdditional=s.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 重置融合素材校验函数
	aux.FCheckAdditional=nil
	return res
end
-- 过滤自己场上记述有「王家的神殿」卡名的怪兽
function s.ffilter(c,tp)
	-- 判断卡片是否记述有「王家的神殿」卡名、是否由自己控制且在场上
	return aux.IsCodeListed(c,29762407) and c:IsControler(tp) and c:IsOnField()
end
-- 自定义融合素材校验：若使用了对方场上的怪兽，则必须包含自己场上记述有「王家的神殿」卡名的怪兽
function s.fcheck(tp,sg,fc)
	return not sg:IsExists(Card.IsControler,1,nil,1-tp) or sg:IsExists(s.ffilter,1,nil,tp)
end
-- 融合召唤效果的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己可用的融合素材（手卡·场上）并过滤掉不受效果影响的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 获取对方场上可以作为融合素材的表侧表示怪兽
		local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可以使用当前素材进行融合召唤的地属性融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果影响的可用素材
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在使用连锁素材效果时，是否存在可以融合召唤的地属性融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 融合召唤效果的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己可用的融合素材（手卡·场上）并过滤掉不受效果影响的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取对方场上可以作为融合素材的表侧表示怪兽并过滤掉不受效果影响的怪兽
	local mg2=Duel.GetMatchingGroup(s.filter0,tp,0,LOCATION_MZONE,nil):Filter(s.filter1,nil,e)
	mg1:Merge(mg2)
	-- 获取当前可用素材可以融合召唤的所有地属性融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果影响的可用素材
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取使用连锁素材效果可以融合召唤的所有地属性融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用常规融合素材进行融合召唤（若同时满足连锁素材，则让玩家选择是否使用连锁素材的效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 在选择素材前，设置自定义的融合素材校验函数（包含对方场上怪兽的使用限制）
			aux.FCheckAdditional=tc.branded_fusion_check or s.fcheck
			-- 让玩家选择用于融合召唤的素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 重置融合素材校验函数
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选定的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续的特殊召唤不与送墓同时处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材效果提供的素材中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 检索效果的发动条件检测函数
function s.thcon(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的「王家的神殿」
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceupEx,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,29762407)
end
-- 过滤卡组中可以加入手牌的「神之怒」
function s.thfilter(c)
	return c:IsCode(22082432) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「神之怒」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「神之怒」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
