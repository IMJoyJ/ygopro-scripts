--獄神影獣－ネルヴェド
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：对方连锁「狱神」怪兽或「神艺」怪兽的效果的发动来发动的怪兽的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名在规则上也当作「神艺」卡使用。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「创狱神 涅瓦」当作融合召唤作特殊召唤。
-- ②：这张卡表侧加入额外卡组的场合才能发动。除「狱神影兽-涅瓦红化兽」外的1只「狱神」怪兽或「神艺」怪兽从自己的卡组·额外卡组（表侧）特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册灵摆效果和两个怪兽效果
function s.initial_effect(c)
	-- 将卡片效果注册为「创狱神 涅瓦」卡名
	aux.AddCodeList(c,53589300)
	-- 为卡片添加灵摆属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：对方连锁「狱神」怪兽或「神艺」怪兽的效果的发动来发动的怪兽的效果的处理时，可以把那个效果无效。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
	-- ①：从卡组上面把3张卡里侧除外才能发动。这张卡破坏，从额外卡组把1只「创狱神 涅瓦」当作融合召唤作特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡表侧加入额外卡组的场合才能发动。除「狱神影兽-涅瓦红化兽」外的1只「狱神」怪兽或「神艺」怪兽从自己的卡组·额外卡组（表侧）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_DECK)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 连锁处理时的无效效果条件判断函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	-- 获取当前连锁的触发效果
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	return rp==1-tp and te and te:GetHandler():IsSetCard(0x1cd,0x1ce) and te:IsActiveType(TYPE_MONSTER)
		and re:IsActiveType(TYPE_MONSTER)
		-- 检查该玩家是否已使用过此效果
		and Duel.GetFlagEffect(tp,id)==0
		-- 检查当前连锁是否可以被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 连锁处理时的无效效果操作函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过此效果并询问是否无效
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把那个效果无效？"
		-- 提示玩家该卡被发动
		Duel.Hint(HINT_CARD,0,id)
		-- 注册该玩家已使用过此效果
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 尝试无效当前连锁效果
		if Duel.NegateEffect(ev) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏自身
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 怪兽效果①的费用支付函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家卡组最上方3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查玩家卡组是否至少有3张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 禁止后续操作自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将卡组最上方3张卡除外作为费用
	Duel.Remove(g,POS_FACEDOWN,REASON_COST)
end
-- 融合召唤目标卡筛选函数
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsCode(53589300) and c:CheckFusionMaterial()
		-- 检查目标卡是否可以特殊召唤并满足召唤条件
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 怪兽效果①的发动目标设定函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足融合召唤所需素材
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查是否存在满足条件的融合召唤目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的发动处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍在连锁中并破坏自身
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 检查是否满足融合召唤所需素材
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的融合召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 执行融合召唤
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 怪兽效果②的发动条件判断函数
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 特殊召唤目标卡筛选函数
function s.spfilter2(c,e,tp)
	return not c:IsCode(id)
		and c:IsSetCard(0x1cd,0x1ce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查目标卡是否在卡组且场上存在空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 检查目标卡是否在额外卡组且满足召唤条件
			or c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 怪兽效果②的发动目标设定函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的特殊召唤目标
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤目标卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 怪兽效果②的发动处理函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
