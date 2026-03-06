--超重武者カゲボウ－C
-- 效果：
-- 「超重武者 影法师-C」的①②的效果1回合各能使用1次。
-- ①：把这张卡解放才能发动。从手卡把1只「超重武者」怪兽特殊召唤。
-- ②：自己场上的「超重武者」怪兽成为效果的对象时，把墓地的这张卡除外才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
function c27978707.initial_effect(c)
	-- ①：把这张卡解放才能发动。从手卡把1只「超重武者」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27978707,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27978707)
	e1:SetCost(c27978707.spcost)
	e1:SetTarget(c27978707.sptg)
	e1:SetOperation(c27978707.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「超重武者」怪兽成为效果的对象时，把墓地的这张卡除外才能发动。那个发动无效并破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27978707,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27978708)
	e2:SetCondition(c27978707.negcon)
	-- 将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27978707.negtg)
	e2:SetOperation(c27978707.negop)
	c:RegisterEffect(e2)
end
-- 检查是否可以将此卡解放作为费用
function c27978707.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将此卡解放作为费用
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选「超重武者」卡组中可以特殊召唤的怪兽
function c27978707.filter(c,e,tp)
	return c:IsSetCard(0x9a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件
function c27978707.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断手牌中是否存在满足条件的「超重武者」怪兽
		and Duel.IsExistingMatchingCard(c27978707.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果
function c27978707.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「超重武者」怪兽
	local g=Duel.SelectMatchingCard(tp,c27978707.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于筛选自己场上的「超重武者」怪兽
function c27978707.negfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x9a) and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
end
-- 判断是否满足无效效果的条件
function c27978707.negcon(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁效果的目标卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断目标卡片组中是否存在满足条件的「超重武者」怪兽且该连锁可被无效
	return g and g:IsExists(c27978707.negfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 设置无效并破坏的效果操作信息
function c27978707.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置使发动无效的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏的效果操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 处理无效并破坏效果
function c27978707.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁发动无效且目标卡存在
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏目标卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
