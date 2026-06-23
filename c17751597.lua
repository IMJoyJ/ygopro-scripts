--烙印断罪
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。需以「阿不思的落胤」为融合素材的融合怪兽从自己场上的表侧表示怪兽之中选1只或者从自己墓地选2只回到额外卡组，那个发动无效并破坏。
-- ②：把墓地的这张卡除外，以「烙印断罪」以外的自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c17751597.initial_effect(c)
	-- 注册此卡的代码列表，记录其为「阿不思的落胤」的持有者
	aux.AddCodeList(c,68468459)
	-- ①：包含把怪兽特殊召唤效果的怪兽的效果·魔法·陷阱卡发动时才能发动。需以「阿不思的落胤」为融合素材的融合怪兽从自己场上的表侧表示怪兽之中选1只或者从自己墓地选2只回到额外卡组，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,17751597)
	e1:SetCondition(c17751597.condition)
	e1:SetTarget(c17751597.target)
	e1:SetOperation(c17751597.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以「烙印断罪」以外的自己墓地1张「烙印」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,17751597)
	-- 设置此效果的发动费用为将此卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17751597.thtg)
	e2:SetOperation(c17751597.thop)
	c:RegisterEffect(e2)
end
-- 判断连锁是否可以被无效，且发动的卡必须是怪兽效果或魔法/陷阱卡，并具有特殊召唤类别
function c17751597.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁是否可以被无效
	if not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON)
end
-- 定义过滤函数，用于筛选场上满足条件的融合怪兽（表侧表示、融合类型、以阿不思的落胤为素材、可送入额外卡组）
function c17751597.filter1(c)
	-- 返回满足条件的场上融合怪兽（表侧表示、融合类型、以阿不思的落胤为素材、可送入额外卡组）
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToExtra()
end
-- 定义过滤函数，用于筛选墓地满足条件的融合怪兽（融合类型、以阿不思的落胤为素材、可送入额外卡组）
function c17751597.filter2(c)
	-- 返回满足条件的墓地融合怪兽（融合类型、以阿不思的落胤为素材、可送入额外卡组）
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459) and c:IsAbleToExtra()
end
-- 设置效果目标，检查场上或墓地是否存在满足条件的融合怪兽
function c17751597.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c17751597.filter1,tp,LOCATION_MZONE,0,1,nil)
		-- 检查墓地是否存在满足条件的融合怪兽
		or Duel.IsExistingMatchingCard(c17751597.filter2,tp,LOCATION_GRAVE,0,2,nil) end
	-- 设置效果操作信息，标记将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果操作信息，标记将破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义选择融合怪兽的筛选函数，用于判断选择的怪兽是否来自场上或墓地
function c17751597.fselect(sg)
	if #sg==1 then
		return sg:GetFirst():IsLocation(LOCATION_MZONE)
	else
		return sg:GetFirst():IsLocation(LOCATION_GRAVE) and sg:GetNext():IsLocation(LOCATION_GRAVE)
	end
end
-- 执行效果操作，检索满足条件的融合怪兽并送回额外卡组，然后无效发动并破坏
function c17751597.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上满足条件的融合怪兽组
	local g1=Duel.GetMatchingGroup(c17751597.filter1,tp,LOCATION_MZONE,0,nil)
	-- 获取墓地满足条件的融合怪兽组（排除王家长眠之谷影响）
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c17751597.filter2),tp,LOCATION_GRAVE,0,nil)
	if #g1==0 and #g2==0 then return end
	g1:Merge(g2)
	-- 提示玩家选择要送回卡组的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=g1:SelectSubGroup(tp,c17751597.fselect,false,1,2)
	-- 显示所选融合怪兽被选为对象的动画
	Duel.HintSelection(g)
	-- 将选中的融合怪兽送回额外卡组
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	local fg=g:Filter(Card.IsLocation,nil,LOCATION_EXTRA)
	if #fg~=#g then return end
	-- 判断是否成功使发动无效且发动的卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动的卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 定义过滤函数，用于筛选墓地中的「烙印」魔法/陷阱卡（非烙印断罪本身）
function c17751597.thfilter(c)
	return not c:IsCode(17751597) and c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置效果目标，选择墓地中的「烙印」魔法/陷阱卡作为对象
function c17751597.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c17751597.thfilter(chkc) end
	-- 检查墓地是否存在满足条件的「烙印」魔法/陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c17751597.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,c17751597.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置效果操作信息，标记将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将目标卡加入手牌
function c17751597.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
