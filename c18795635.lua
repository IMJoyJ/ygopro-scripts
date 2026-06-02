--GMX Applied Experiment #55
-- 效果：
-- 直到1只「GMX」怪兽和1只恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那之后，可以把翻开的怪兽作为融合素材，把1只「GMX」融合怪兽融合召唤。剩下的卡回到卡组洗切。
-- 「GMX应用试验55号」在1回合只能发动1张。
local s,id,o=GetID()
-- 注册卡片的效果：此卡发动的效果处理，且1回合只能发动1张
function s.initial_effect(c)
	-- 「GMX应用试验55号」在1回合只能发动1张。直到1只「GMX」怪兽和1只恐龙族怪兽出现为止从自己卡组上面翻卡，自己失去翻开的卡的数量×400的基本分，那之后，可以把翻开的怪兽作为融合素材，把1只「GMX」融合怪兽融合召唤。剩下的卡回到卡组洗切。
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
-- 过滤条件：卡名为「GMX」的怪兽卡
function s.cfilter1(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER)
end
-- 过滤条件：恐龙族怪兽卡
function s.cfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 设置发动的靶向信息：检查自己卡组里是否同时存在「GMX」怪兽与恐龙族怪兽，且合计包含这两种怪兽至少有2张，设置操作信息为从额外卡组特殊召唤融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组中是否存在至少1只「GMX」怪兽
		return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_DECK,0,1,nil)
			-- 检查自己卡组中是否存在至少1只恐龙族怪兽
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,1,nil)
			-- 检查自己卡组中是否至少有2张满足上述两种条件之一的怪兽
			and Duel.IsExistingMatchingCard(
				function(c) return s.cfilter1(c) or s.cfilter2(c) end,
				tp,LOCATION_DECK,0,2,nil
			)
	end
	-- 设置效果分类为从额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
-- 过滤条件：可以利用可用素材进行融合召唤的额外卡组的「GMX」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理：从自己卡组最上方翻卡直到1只「GMX」怪兽和1只恐龙族怪兽出现，失去翻开卡数量×400的基本分，可将翻开的怪兽作为融合素材把1只「GMX」融合怪兽融合召唤，剩下的卡洗回卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的卡片数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 获取自己卡组中所有的「GMX」怪兽
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_DECK,0,nil)
	if #g1==0 then return end
	-- 获取自己卡组中所有的恐龙族怪兽
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
	-- 确认（翻开）自己卡组最上方计算出的翻卡数量的卡片
	Duel.ConfirmDecktop(tp,excavate_count)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发卡组翻开卡片相关的自定义时点事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 扣减玩家的基本分，失去翻开的卡片数量×400的生命值
	Duel.SetLP(tp,Duel.GetLP(tp)-excavate_count*400)
	-- 如果玩家生命值归零或以下，则直接结束效果处理
	if Duel.GetLP(tp)<=0 then return end
	-- 获取翻开的卡片中属于怪兽卡的部分，作为融合素材的候选怪兽
	local mg=Duel.GetDecktopGroup(tp,excavate_count):Filter(Card.IsType,nil,TYPE_MONSTER)
	local chkf=tp
	-- 获取额外卡组中可以使用这批怪兽作为素材融合召唤的「GMX」融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检测是否存在能代替融合素材的其他连锁卡片效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 利用连锁素材效果获取额外卡组中可以进行融合召唤的「GMX」融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	-- 若存在可融合召唤的怪兽，由玩家选择是否进行融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否融合召唤？"
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 给玩家发送选择特殊召唤卡片的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽是否是使用翻开的怪兽作为素材的合法对象
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 从翻开的怪兽中选择该融合怪兽所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat1)
			-- 中断当前效果，使素材送入墓地不与之前的处理视为同时处理
			Duel.BreakEffect()
			-- 将选为融合素材的怪兽作为融合素材送入墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使特殊召唤不与之前的处理视为同时进行
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤的方式表侧表示特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 利用连锁素材效果中可用的怪兽选择所需的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			-- 中断当前效果，使后续的融合召处理不与之前的处理视为同时进行
			Duel.BreakEffect()
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 将卡组中剩下的卡回到卡组洗切
	Duel.ShuffleDeck(tp)
end
