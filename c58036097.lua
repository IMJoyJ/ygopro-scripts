--どきどきメルフィータイム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己的场上·墓地1只「童话动物」怪兽为对象才能发动。那只怪兽回到手卡。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只兽族融合怪兽融合召唤。
-- ②：自己场上有「童话动物」超量怪兽存在的场合，把墓地的这张卡除外才能发动。这个回合中，从额外卡组特殊召唤的自己场上的「童话动物」怪兽不受对方发动的效果影响。
local s,id,o=GetID()
-- 注册效果①（回手牌及融合召唤）与效果②（墓地除外使童话动物怪兽获得不受影响抗性）
function s.initial_effect(c)
	-- ①：以自己的场上·墓地1只「童话动物」怪兽为对象才能发动。那只怪兽回到手卡。那之后，可以把自己的手卡·场上的怪兽作为融合素材，把1只兽族融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「童话动物」超量怪兽存在的场合，把墓地的这张卡除外才能发动。这个回合中，从额外卡组特殊召唤的自己场上的「童话动物」怪兽不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"不受影响"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.immcon)
	-- 效果②的Cost：作为发动代价，把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.immtg)
	e2:SetOperation(s.immop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己的场上·墓地中且可以回到手牌的「童话动物」怪兽
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x146) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的判定与对象选择函数：以自己的场上·墓地的1只「童话动物」怪兽为对象，并设置操作信息为将该对象回到手卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and s.thfilter(chkc) and chkc:IsControler(tp) end
	-- 若为效果发动的检查（chk==0），判定己方的场上或墓地中是否存在可以回到手牌的「童话动物」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 发送系统提示：请选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 优先从场上（若场上无则从墓地）选择1只符合条件的「童话动物」怪兽作为效果的对象
	local g=aux.SelectTargetFromFieldFirst(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的对象卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 过滤条件：不受融合效果影响的怪兽（用作融合素材判定）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤条件：额外卡组中的兽族融合怪兽，且可以使用指定的融合素材进行特殊召唤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_BEAST) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的效果处理：使对象怪兽回到手牌，之后可以让玩家选择是否进行融合召唤1只兽族融合怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁对应的第一个效果对象
	local tc=Duel.GetFirstTarget()
	-- 判定效果对象是否存在、是否依然关联到此连锁，并且不受王家长眠之谷的影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将对象卡片送回手牌，并确认其已成功回到手牌
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		local chkf=tp
		-- 获取己方手卡、场上可用于融合素材的怪兽，并过滤出不受该融合效果影响的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 判定额外卡组中是否存在可以利用当前手卡、场上素材进行融合召唤的兽族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查己方是否受到连锁素材的效果影响并获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的素材，判定额外卡组中是否存在可以融合召唤的兽族融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		-- 若满足融合召唤的条件，询问玩家是否进行融合召唤
		if res and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否融合召唤？"
			-- 若玩家确认进行融合召唤，洗切玩家的手牌
			Duel.ShuffleHand(tp)
			-- 获取常规情况下可进行融合召唤的兽族融合怪兽卡片组
			local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
			local mg2=nil
			local sg2=nil
			-- 检查己方是否受到连锁素材的效果影响并获取连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 获取在连锁素材效果影响下，可以进行融合召唤的兽族融合怪兽卡片组
				sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
			end
			if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
				local sg=sg1:Clone()
				if sg2 then sg:Merge(sg2) end
				-- 发送系统提示：请选择要特殊召唤的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				local tg=sg:Select(tp,1,1,nil)
				local tc=tg:GetFirst()
				-- 判定选择召唤的融合怪兽是否可以通过常规融合素材进行融合召唤（若可用常规素材，且玩家不选择使用连锁素材效果，则使用常规素材）
				if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
					-- 让玩家从己方常规融合素材卡片组中选择一组该融合怪兽的融合素材
					local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
					tc:SetMaterial(mat1)
					-- 将选中的融合素材送去墓地
					Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
					-- 中断当前效果处理，使之后特殊召唤的处理与回手牌的处理不同时进行，防止错时点
					Duel.BreakEffect()
					-- 将选中的融合怪兽作为融合召唤特殊召唤到场上
					Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				elseif ce then
					-- 让玩家通过连锁素材的效果，选择并确定该融合怪兽所需的融合素材
					local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
					local fop=ce:GetOperation()
					fop(ce,e,tp,tc,mat2)
				end
				tc:CompleteProcedure()
			end
		end
	end
end
-- 过滤条件：自己场上表侧表示的「童话动物」超量怪兽
function s.confilter(c)
	return c:IsFaceup() and c:IsSetCard(0x146) and c:IsType(TYPE_XYZ)
end
-- 效果②的发动条件函数：自己场上必须存在表侧表示的「童话动物」超量怪兽
function s.immcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定己方场上是否存在表侧表示的「童话动物」超量怪兽
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果②的发动判定：检查本回合是否尚未注册过该效果的标识效果
function s.immtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为效果发动的检查（chk==0），则判定本回合是否尚未发动过该除外效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 效果②的效果处理：为玩家注册全局效果，使本回合从额外卡组特殊召唤的自己场上的「童话动物」怪兽不受对方发动的效果影响
function s.immop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，从额外卡组特殊召唤的自己场上的「童话动物」怪兽不受对方发动的效果影响。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.tg)
	e1:SetValue(s.efilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册全局标识效果，用于记录本回合已使用过该效果
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- 将不受影响的抗性效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 抗性影响的目标怪兽过滤：必须是从额外卡组特殊召唤的自己场上的「童话动物」怪兽
function s.tg(e,c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsSetCard(0x146)
end
-- 抗性过滤函数：不受对方发动的效果影响
function s.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
