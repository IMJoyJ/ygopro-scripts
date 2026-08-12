--天威龍－マニラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：效果怪兽以外的自己场上的表侧表示怪兽为对象的对方的魔法·陷阱·怪兽的效果发动时，把手卡·墓地的这张卡除外才能发动。那个发动无效并破坏。
function c60942444.initial_effect(c)
	-- ①：自己场上没有效果怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(60942444,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,60942444)
	e1:SetCondition(c60942444.spcon)
	e1:SetTarget(c60942444.sptg)
	e1:SetOperation(c60942444.spop)
	c:RegisterEffect(e1)
	-- ②：效果怪兽以外的自己场上的表侧表示怪兽为对象的对方的魔法·陷阱·怪兽的效果发动时，把手卡·墓地的这张卡除外才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60942444,1))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,60942445)
	e2:SetCondition(c60942444.negcon)
	-- 将手卡或墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c60942444.negtg)
	e2:SetOperation(c60942444.negop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的效果怪兽
function c60942444.spcfilter(c)
	return c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件：自己场上没有效果怪兽存在
function c60942444.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的效果怪兽，若不存在则满足发动条件
	return not Duel.IsExistingMatchingCard(c60942444.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c60942444.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示该效果在处理时会特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理：将自身特殊召唤到场上
function c60942444.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示的效果怪兽以外的怪兽
function c60942444.negcfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and not c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 无效效果的发动条件：对方发动了以自己场上表侧表示的非效果怪兽为对象的效果
function c60942444.negcon(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
		-- 获取当前触发连锁的对象卡片组
		local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
		-- 检查对象卡片中是否存在自己场上表侧表示的非效果怪兽，且该连锁的发动可以被无效
		return tg and tg:IsExists(c60942444.negcfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
	end
	return false
end
-- 无效效果的发动准备：设置无效发动和破坏的操作信息
function c60942444.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效发动的操作信息，表示该效果在处理时会使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏的操作信息，表示该效果在处理时会破坏发动效果的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 无效效果的效果处理：使发动无效并破坏
function c60942444.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且该卡在场上或原本位置与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将发动无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
