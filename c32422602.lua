--戦華の智－諸葛孔
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡用「战华」卡的效果从卡组加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：魔法·陷阱卡发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
-- ③：自己场上有「战华之德-刘玄」存在，怪兽的效果发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
function c32422602.initial_effect(c)
	-- ①：这张卡用「战华」卡的效果从卡组加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32422602,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,32422602)
	e1:SetCondition(c32422602.spcon)
	e1:SetTarget(c32422602.sptg)
	e1:SetOperation(c32422602.spop)
	c:RegisterEffect(e1)
	-- ②：魔法·陷阱卡发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32422602,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,32422603)
	e2:SetCondition(c32422602.negcon1)
	e2:SetCost(c32422602.negcost)
	e2:SetTarget(c32422602.negtg)
	e2:SetOperation(c32422602.negop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(32422602,2))
	e3:SetCountLimit(1,32422604)
	e3:SetCondition(c32422602.negcon2)
	c:RegisterEffect(e3)
end
-- 满足①的效果发动条件：通过效果从卡组加入手牌且来源为战华卡
function c32422602.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,REASON_EFFECT)~=0 and re:GetHandler():IsSetCard(0x137)
		and c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 准备发动①效果：检查是否有特殊召唤的空位和自身能否特殊召唤
function c32422602.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有怪兽区域可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果：将自身特殊召唤
function c32422602.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③：自己场上有「战华之德-刘玄」存在，怪兽的效果发动时，把自己场上1张表侧表示的「战华」永续魔法·永续陷阱卡送去墓地才能发动。那个发动无效。
function c32422602.negcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 满足②效果发动条件：发动的是魔法或陷阱卡且连锁可被无效
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查场上的「战华之德-刘玄」是否存在
function c32422602.cfilter(c)
	return c:IsFaceup() and c:IsCode(40428851)
end
-- 满足③效果发动条件：发动的是怪兽效果且连锁可被无效，且场上有「战华之德-刘玄」
function c32422602.negcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 发动的是怪兽效果
	return re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查场上有「战华之德-刘玄」
		and Duel.IsExistingMatchingCard(c32422602.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤满足条件的「战华」永续魔法·永续陷阱卡
function c32422602.costfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- ②③效果的发动费用：选择1张场上的「战华」永续魔法·永续陷阱卡送去墓地
function c32422602.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有满足条件的「战华」永续魔法·永续陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c32422602.costfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择1张场上的「战华」永续魔法·永续陷阱卡
	local g=Duel.SelectMatchingCard(tp,c32422602.costfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置②③效果处理信息：使发动无效
function c32422602.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行②③效果：使发动无效
function c32422602.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行使发动无效的操作
	Duel.NegateActivation(ev)
end
