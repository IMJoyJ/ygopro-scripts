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
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 登记本卡关系代码列表：记载了「狱神影兽-涅瓦红化兽」自身以及融合怪兽「创狱神 涅瓦」
	aux.AddCodeList(c,17473466,53589300)
	-- 为灵摆怪兽添加灵摆怪兽属性与灵摆召唤手续
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
-- 灵摆效果①的发动条件判断
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	if ev<2 then return false end
	-- 获取前一个连锁的效果
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	return rp==1-tp and te and te:GetHandler():IsSetCard(0x1cd,0x1ce) and te:IsActiveType(TYPE_MONSTER)
		and re:IsActiveType(TYPE_MONSTER)
		-- 检查本回合是否还没有使用过该无效效果
		and Duel.GetFlagEffect(tp,id)==0
		-- 检查正在处理的连锁是否可以被无效，并且尚未被无效
		and Duel.IsChainDisablable(ev) and not Duel.IsChainDisabled(ev)
end
-- 灵摆效果①的效果处理操作
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 若本回合还未使用过该无效效果，且玩家选择发动此效果
	if Duel.GetFlagEffect(tp,id)==0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否适用「狱神影兽-涅瓦红化兽」的效果来无效？"
		-- 展示该卡的卡片发动动画效果
		Duel.Hint(HINT_CARD,0,id)
		-- 为玩家注册本回合使用过该效果的全局标识
		Duel.RegisterFlagEffect(tp,id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 尝试使对方发动的怪兽效果无效
		if Duel.NegateEffect(ev) then
			-- 中断效果处理，使后续的破坏步骤与前面的无效动作不视为同时处理
			Duel.BreakEffect()
			-- 将自己灵摆区域的这张卡破坏
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 代替除外过滤函数：过滤墓地中满足条件的「绝境的狱神域-威利亚」
function s.costfilter(c,e,tp)
	return e:GetHandler():IsSetCard(0x1ce) and c:IsAbleToRemove() and c:IsHasEffect(99311889,tp)
end
-- 怪兽效果①的发动代价判断：检查是否可以里侧除外卡组最上方3张卡，或存在墓地代替除外卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if chk==0 then return g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查卡组中是否有至少3张卡可供操作
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 检查墓地中是否存在可代替除外的卡片
		or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	if g:FilterCount(Card.IsAbleToRemoveAsCost,nil,POS_FACEDOWN)==3
		-- 检查卡组中是否有至少3张卡
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3
		-- 检查墓地中是否存在可代替除外的卡片
		and (not Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 让玩家选择是否适用墓地卡片的代替除外效果
		or not Duel.SelectYesNo(tp,aux.Stringid(99311889,1))) then  --"是否作为代替把「绝境的狱神域-威利亚」除外？"
		-- 关闭洗牌检测（为接下来的里侧除外做准备）
		Duel.DisableShuffleCheck()
		-- 将卡组最上方的3张卡里侧除外作为发动代价
		Duel.Remove(g,POS_FACEDOWN,REASON_COST)
	else
		-- 提示玩家选择从墓地除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家选择墓地中用于代替除外的卡片
		local sg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=sg:GetFirst()
		local te=tc:IsHasEffect(99311889,tp)
		if te then
			te:UseCountLimit(tp)
			-- 将选择的代替卡片除外作为发动代价
			Duel.Remove(tc,POS_FACEUP,REASON_COST+REASON_REPLACE)
		end
	end
end
-- 怪兽过滤函数：过滤额外卡组中的「创狱神 涅瓦」
function s.spfilter(c,e,tp,mc)
	return c:IsType(TYPE_FUSION) and c:IsCode(53589300) and c:CheckFusionMaterial()
		-- 检查目标融合怪兽是否可以被特殊召唤，以及额外怪兽区域是否有可用空格
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 怪兽效果①的发动目标：检查并设置破坏自己以及从额外卡组特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时，检查是否满足融合召唤特殊召唤的前置条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 检查额外卡组中是否存在合法的特殊召唤目标
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c) end
	-- 设置操作信息：将这张卡破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 怪兽效果①的效果处理：破坏自身并从额外卡组特殊召唤「创狱神 涅瓦」
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将这张卡自身破坏
	if not c:IsRelateToChain() or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 检查特殊召唤相关的规则限制
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择「创狱神 涅瓦」
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil)
	local tc=g:GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选择的怪兽当作融合召唤特殊召唤到场上
	Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
	tc:CompleteProcedure()
end
-- 怪兽效果②的发动条件判断：此卡表侧加入额外卡组
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA)
		and c:IsFaceup()
end
-- 特殊召唤怪兽过滤函数：过滤除自身外的「狱神」或「神艺」怪兽
function s.spfilter2(c,e,tp)
	return not c:IsCode(id)
		and c:IsSetCard(0x1cd,0x1ce) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查特殊召唤目标是否来自卡组且主怪兽区域有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 检查特殊召唤目标是否来自额外卡组且有空闲的额外怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 怪兽效果②的发动目标判断：检查卡组·额外卡组是否存在满足条件的特殊召唤怪兽并设置操作信息
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查是否存在合法的特殊召唤对象
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 怪兽效果②的效果处理：特殊召唤1只「狱神」或「神艺」怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组或额外卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
