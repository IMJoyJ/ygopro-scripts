--第５５次GMX応用試験
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：直到「基因组混合」怪兽以及恐龙族怪兽各出现为止从自己卡组上面翻卡，自己失去翻开数量×400基本分。可以把翻开的卡之中的怪兽作为融合素材，把1只「基因组混合」融合怪兽融合召唤。剩下的翻开的卡回到卡组。
local s,id,o=GetID()
-- 初始化函数：注册效果e1，设置效果描述、分类（特殊召唤+融合召唤+卡组破坏）、类型为魔法卡发动、自由时点、同名卡1回合只能发动1张的誓约限制，以及目标函数和处理函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：直到「基因组混合」怪兽以及恐龙族怪兽各出现为止从自己卡组上面翻卡，自己失去翻开数量×400基本分。可以把翻开的卡之中的怪兽作为融合素材，把1只「基因组混合」融合怪兽融合召唤。剩下的翻开的卡回到卡组。
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
-- 过滤函数：判断该卡是否为「基因组混合」怪兽
function s.cfilter1(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_MONSTER)
end
-- 过滤函数：判断该卡是否为恐龙族怪兽
function s.cfilter2(c)
	return c:IsRace(RACE_DINOSAUR)
end
-- 发动目标检测：确认自己卡组中同时存在「基因组混合」怪兽和恐龙族怪兽且两类合计至少2只，并设置将从额外卡组特殊召唤1只怪兽的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查自己卡组是否存在至少1只「基因组混合」怪兽
		return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_DECK,0,1,nil)
			-- 且检查自己卡组是否存在至少1只恐龙族怪兽
			and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_DECK,0,1,nil)
			-- 且检查自己卡组中「基因组混合」怪兽或恐龙族怪兽合计是否存在至少2只（保证两类各能翻出1只）
			and Duel.IsExistingMatchingCard(
				function(c) return s.cfilter1(c) or s.cfilter2(c) end,
				tp,LOCATION_DECK,0,2,nil
			)
	end
	-- 设置操作信息：此效果处理中预计从额外卡组特殊召唤1只怪兽（融合召唤）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
-- 过滤函数：判断额外卡组的卡是否为能用给定融合素材组进行融合召唤、且满足召唤条件与连锁素材条件的「基因组混合」融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1dd) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果处理主函数：计算需要翻开的卡数直到「基因组混合」怪兽和恐龙族怪兽各出现为止，翻开卡组上方的卡，自己失去翻开数量×400基本分，可以以翻开的怪兽为融合素材把1只「基因组混合」融合怪兽融合召唤，最后洗切卡组让剩下的卡回到卡组
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组的卡的数量
	local dcount=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if dcount==0 then return end
	-- 检索自己卡组中所有的「基因组混合」怪兽
	local g1=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_DECK,0,nil)
	if #g1==0 then return end
	-- 检索自己卡组中所有的恐龙族怪兽
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
	-- 从自己卡组上面翻开excavate_count张卡（即直到「基因组混合」怪兽以及恐龙族怪兽各出现为止翻开的数量）
	Duel.ConfirmDecktop(tp,excavate_count)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 若这张卡自身属于「基因组混合」系列，则触发自定义事件1595137（供系列内其他卡的效果联动使用）
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 自己失去翻开数量×400基本分
	Duel.SetLP(tp,Duel.GetLP(tp)-excavate_count*400)
	-- 若失去基本分后自己基本分变为0以下，则中断后续处理
	if Duel.GetLP(tp)<=0 then return end
	-- 取得翻开的卡之中的怪兽卡，作为可用于融合召唤的融合素材组
	local mg=Duel.GetDecktopGroup(tp,excavate_count):Filter(Card.IsType,nil,TYPE_MONSTER)
	local chkf=tp
	-- 检索额外卡组中能以翻开的怪兽作为融合素材进行融合召唤的「基因组混合」融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取自己受到的连锁素材效果（如「连锁素材」，可让融合素材从别处取得）
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 检索额外卡组中能以连锁素材效果提供的融合素材组进行融合召唤的「基因组混合」融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	-- 若存在可以融合召唤的怪兽，询问玩家是否进行融合召唤
	if (sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0)) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否融合召唤？"
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家提示：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选怪兽是否用普通融合素材召唤（若连锁素材也适用，则询问玩家是否改用连锁素材的效果来融合召唤）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从翻开的怪兽中选择用于融合召唤的一组融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg,nil,chkf)
			tc:SetMaterial(mat1)
			-- 中断当前效果处理，使之后的处理与之前视为不同时处理
			Duel.BreakEffect()
			-- 把所选的融合素材以效果原因作为融合召唤的素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的特殊召唤视为不同时处理
			Duel.BreakEffect()
			-- 把所选的「基因组混合」融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 让玩家从连锁素材效果指定的融合素材组中选择用于融合召唤的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			-- 中断当前效果处理，使之后的处理与之前视为不同时处理
			Duel.BreakEffect()
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	-- 洗切自己的卡组（剩下的翻开的卡回到卡组）
	Duel.ShuffleDeck(tp)
end
