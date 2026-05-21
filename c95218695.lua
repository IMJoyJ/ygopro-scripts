--サブテラーマリス・アルラボーン
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合才能发动。这个回合，自己场上的「地中族」卡不会被对方的效果破坏。
function c95218695.initial_effect(c)
	-- ③：这张卡反转的场合才能发动。这个回合，自己场上的「地中族」卡不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95218695,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,95218695)
	e1:SetOperation(c95218695.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95218695,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c95218695.spcon)
	e2:SetTarget(c95218695.sptg)
	e2:SetOperation(c95218695.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95218695,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c95218695.postg)
	e3:SetOperation(c95218695.posop)
	c:RegisterEffect(e3)
end
-- 反转效果的处理：在自己场上注册一个「地中族」卡片不会被对方效果破坏的持续效果
function c95218695.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个卡名的③的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	-- 过滤受保护的卡片：属于「地中族」（0xed）的卡片
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xed))
	-- 设置破坏抗性：不会被对方的效果破坏
	e1:SetValue(aux.indoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该不会被破坏的场上效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：自己场上从表侧表示变成里侧表示的怪兽
function c95218695.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 特殊召唤效果的发动条件：自己场上有怪兽从表侧变成里侧，且自己场上没有表侧表示怪兽存在
function c95218695.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c95218695.cfilter,1,nil,tp)
		-- 检查自己场上是否存在表侧表示的怪兽（要求不存在）
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备：检查怪兽区域空位、自己场上无表侧怪兽，以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c95218695.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动准备阶段：检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动准备阶段：再次确认自己场上没有表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：若自身仍在手卡，则将自身以表侧守备表示特殊召唤
function c95218695.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 变成里侧守备表示效果的发动准备：检查自身是否能转为里侧，注册一回合一次的Flag，并设置改变表示形式的操作信息
function c95218695.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(95218695)==0 end
	c:RegisterFlagEffect(95218695,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置效果处理信息：改变自身的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的处理：若自身仍在场上且为表侧表示，则将其转为里侧守备表示
function c95218695.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡转为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
