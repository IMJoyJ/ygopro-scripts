--SRカールターボ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有风属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。
-- ②：从自己墓地把这张卡和1只「疾行机人」怪兽除外才能发动。自己场上的全部风属性怪兽的攻击力直到回合结束时上升800。
function c96945958.initial_effect(c)
	-- ①：自己场上有风属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96945958,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,96945958)
	e1:SetCondition(c96945958.spcon)
	e1:SetTarget(c96945958.sptg)
	e1:SetOperation(c96945958.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只「疾行机人」怪兽除外才能发动。自己场上的全部风属性怪兽的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96945958,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,96945959)
	e2:SetCost(c96945958.atkcost)
	e2:SetTarget(c96945958.atktg)
	e2:SetOperation(c96945958.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的风属性怪兽
function c96945958.filter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果①的发动条件：自己场上有风属性怪兽存在
function c96945958.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的风属性怪兽
	return Duel.IsExistingMatchingCard(c96945958.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与可行性检查
function c96945958.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：特殊召唤自身并适用后续限制效果
function c96945958.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不能把风属性以外的怪兽的效果发动。②：从自己墓地把这张卡和1只「疾行机人」怪兽除外才能发动。自己场上的全部风属性怪兽的攻击力直到回合结束时上升800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c96945958.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家发动风属性以外怪兽效果的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能发动风属性以外的怪兽的效果
function c96945958.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsNonAttribute(ATTRIBUTE_WIND)
end
-- 过滤条件：墓地的「疾行机人」怪兽且可以作为代价除外
function c96945958.costfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动代价：将这张卡和1只「疾行机人」怪兽从墓地除外
function c96945958.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身和墓地中另一只「疾行机人」怪兽是否都可以作为代价除外
	if chk==0 then return Duel.IsExistingMatchingCard(c96945958.costfilter,tp,LOCATION_GRAVE,0,1,c) and c:IsAbleToRemoveAsCost() end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中除自身以外的1只「疾行机人」怪兽
	local g=Duel.SelectMatchingCard(tp,c96945958.costfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选中的怪兽和这张卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与可行性检查
function c96945958.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在表侧表示的风属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96945958.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果②的效果处理：使自己场上全部风属性怪兽的攻击力直到回合结束时上升800
function c96945958.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有的表侧表示风属性怪兽
	local g=Duel.GetMatchingGroup(c96945958.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力直到回合结束时上升800
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
