--GMX Applied Experiment #55
-- 效果：
-- 直到1只「GMX」怪兽和1只恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那之后，可以把翻开的怪兽作为融合素材，把1只「GMX」融合怪兽融合召唤。剩下的卡回到卡组洗切。
-- 「GMX应用试验55号」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡牌效果，创建一个可以发动的魔法效果
function s.initial_effect(c)
	-- 创建效果1，描述为卡牌效果提示第0句，分类为特殊召唤+融合召唤+从卡组破坏，类型为发动效果，时点为自由连锁，发动次数限制为1次，目标函数为s.target，处理函数为s.activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数1，用于筛选「GMX」怪兽
function s.cfilter1(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER)
end
-- 定义过滤函数2，用于筛选恐龙族怪兽
function s.cfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 目标函数，检查是否满足发动条件：卡组中存在至少1只「GMX」怪兽和1只恐龙族怪兽，并且至少有2张卡满足上述任一条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查卡组中是否存在至少1只「GMX」怪兽
		return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_DECK,0,1,nil)
			-- 检查卡组中是否存在至少1只恐龙族怪兽
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,1,nil)
			-- 检查卡组中是否存在至少2张满足过滤条件的卡（即「GMX」怪兽或恐龙族怪兽）
			and Duel.IsExistingMatchingCard(
				function(c) return s.cfilter1(c) or s.cfilter2(c) end,
				tp,LOCATION_DECK,0,2,nil
			)
	end
	-- 设置连锁操作信息，表示将要特殊召唤1只融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
-- 定义融合怪兽过滤函数，用于筛选满足融合召唤条件的「GMX」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 发动函数，执行卡牌效果的主要逻辑
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组中的卡数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 获取玩家卡组中所有「GMX」怪兽
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_DECK,0,nil)
	if #g1==0 then return end
	-- 获取玩家卡组中所有恐龙族怪兽
	local g2=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_DECK,0,nil)
	if #g2==0 then return end
	local c1=g1:GetMaxGroup(Card.GetSequence):GetFirst()
	local c2=g2:GetMaxGroup(Card.GetSequence):GetFirst()
	local seq=math.min(c1:GetSequence(),c2:GetSequence())
	if c1==c2 then
		g1:RemoveCard(c1)
		g2:RemoveCard(c2)
		if #g1==0 and #g2==0 then return end

		local seq1=(#g1>0) and select(2,g1:GetMaxGroup(Card.GetSequence)) or -1
		local seq2=(#g2>0) and select(2,g2:GetMaxGroup(Card.GetSequence)) or -1
		seq=math.max(seq1,seq2)
	end
	local excavate_count=dcount-seq
	-- 确认玩家卡组最上方的翻开数量张卡
	Duel.ConfirmDecktop(tp,excavate_count)
	-- 玩家失去翻开卡数量×400的基本分
	Duel.SetLP(tp,Duel.GetLP(tp)-excavate_count*400)
	-- 获取翻开的卡中所有怪兽
	local mg=Duel.GetDecktopGroup(tp,excavate_count):Filter(Card.IsType,nil,TYPE_MONSTER)
	local chkf=tp
	-- 获取满足融合条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取融合素材效果对应的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	-- 判断是否有满足条件的融合怪兽且玩家选择融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否融合召唤？"
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选择的融合怪兽是否属于第一组融合怪兽且满足条件
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat1)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 选择融合怪兽的融合素材（来自连锁效果）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			-- 中断当前效果处理
			Duel.BreakEffect()
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 将玩家卡组洗切
	Duel.ShuffleDeck(tp)
end
