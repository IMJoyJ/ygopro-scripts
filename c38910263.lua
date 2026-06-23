--炎王獣 ハヌマーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡在怪兽区域存在，魔法·陷阱卡的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
local s,id,o=GetID()
-- 创建两个效果，分别对应卡片效果①和②的发动条件与处理
function s.initial_effect(c)
	-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在，魔法·陷阱卡的效果发动时才能发动。那个发动无效，这张卡以外的自己的手卡·场上（表侧表示）1只炎属性怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.negcon)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于判断被破坏的怪兽是否满足条件（在场上、正面表示、是炎王卡组、因效果破坏）
function s.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
-- 判断是否有满足条件的怪兽被破坏，用于效果①的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置效果①的发动时点处理，检查是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果①的处理，将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身从手牌特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义效果②的发动条件，判断是否为魔法或陷阱卡发动且未被战斗破坏
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 判断发动的是否为魔法或陷阱卡，且自身未被战斗破坏，且该连锁可被无效
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not c:IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 定义破坏目标的过滤函数，用于选择炎属性的正面表示怪兽
function s.desfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsFaceupEx()
end
-- 设置效果②的发动时点处理，检查是否可以无效发动并选择破坏对象
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上或手牌是否存在满足条件的炎属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,e:GetHandler()) end
	-- 设置无效发动的处理信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置破坏怪兽的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE+LOCATION_HAND)
end
-- 执行效果②的处理，无效发动并选择破坏对象
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使连锁发动无效
	if Duel.NegateActivation(ev) then
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择满足条件的炎属性怪兽作为破坏对象
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
		if g:GetCount()>0 then
			-- 将选中的怪兽破坏
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
