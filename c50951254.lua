--マグマッチョ・ドラゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把最多3只炎属性怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外数量×400。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己抽1张。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c50951254.initial_effect(c)
	-- ①：从自己墓地把最多3只炎属性怪兽除外才能发动。这张卡的攻击力直到回合结束时上升除外数量×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50951254,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50951254)
	e1:SetCost(c50951254.atkcost)
	e1:SetOperation(c50951254.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的炎属性怪兽被效果破坏的场合才能发动。这张卡特殊召唤。那之后，自己抽1张。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50951254,1))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,86346363)
	e2:SetCondition(c50951254.spcon)
	e2:SetTarget(c50951254.sptg)
	e2:SetOperation(c50951254.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为可作为除外代价的炎属性怪兽
function c50951254.costfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：选择1~3只墓地的炎属性怪兽除外作为发动代价
function c50951254.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的炎属性怪兽可以作为除外代价
	if chk==0 then return Duel.IsExistingMatchingCard(c50951254.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 获取所有可作为除外代价的炎属性怪兽
	local g=Duel.GetMatchingGroup(c50951254.costfilter,tp,LOCATION_GRAVE,0,nil)
	local sg=g:Select(tp,1,3,nil)
	-- 将选中的怪兽除外，并记录除外数量
	e:SetLabel(Duel.Remove(sg,POS_FACEUP,REASON_COST))
end
-- 效果处理：使自身攻击力上升除外数量×400
function c50951254.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将攻击力提升效果应用到自身，直到回合结束
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断被破坏的怪兽是否满足特殊召唤条件
function c50951254.sfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_FIRE)~=0
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 判断是否有满足条件的怪兽被破坏且不是自己
function c50951254.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c50951254.sfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 设置特殊召唤和抽卡的效果处理信息
function c50951254.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以将自身特殊召唤到场上
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将自身从墓地特殊召唤并抽一张卡
function c50951254.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以被特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 将特殊召唤后离开场上的效果设置为除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 使玩家抽一张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
