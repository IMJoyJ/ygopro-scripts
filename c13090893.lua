--グリッド・スィーパー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场地魔法卡表侧表示存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把墓地的这张卡以及自己场上1只连接怪兽除外才能发动。选对方场上1张卡破坏。
function c13090893.initial_effect(c)
	-- ①：场地魔法卡表侧表示存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13090893,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,13090893)
	e1:SetCondition(c13090893.spcon)
	e1:SetTarget(c13090893.sptg)
	e1:SetOperation(c13090893.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡以及自己场上1只连接怪兽除外才能发动。选对方场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13090893,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,13090894)
	e2:SetCost(c13090893.descost)
	e2:SetTarget(c13090893.destg)
	e2:SetOperation(c13090893.desop)
	c:RegisterEffect(e2)
end
-- 检查场地魔法区域是否存在表侧表示的场地魔法卡
function c13090893.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足条件则效果可用
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 设置特殊召唤的发动条件
function c13090893.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤的操作
function c13090893.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否有可作为除外代价的连接怪兽
function c13090893.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost()
end
-- 设置效果的发动代价
function c13090893.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查场上是否存在满足条件的连接怪兽
		and Duel.IsExistingMatchingCard(c13090893.cfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择场上满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c13090893.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选中的卡除外作为代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置破坏效果的发动条件
function c13090893.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在可破坏的卡
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果的操作
function c13090893.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的卡
	local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显示选中的卡被破坏的动画
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
