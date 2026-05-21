--サブテラーマリス・バレスアッシュ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合才能发动。这张卡以外的场上的表侧表示怪兽全部变成里侧守备表示。
function c92970404.initial_effect(c)
	-- ③：这张卡反转的场合才能发动。这张卡以外的场上的表侧表示怪兽全部变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92970404,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92970404)
	e1:SetTarget(c92970404.target)
	e1:SetOperation(c92970404.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92970404,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c92970404.spcon)
	e2:SetTarget(c92970404.sptg)
	e2:SetOperation(c92970404.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92970404,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c92970404.postg)
	e3:SetOperation(c92970404.posop)
	c:RegisterEffect(e3)
end
-- 反转效果（③效果）的发动准备与目标确认函数
function c92970404.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只这张卡以外可以变成里侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取场上除这张卡以外所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	-- 设置操作信息为改变这些怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 反转效果（③效果）的效果处理函数
function c92970404.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上除这张卡（若仍在场）以外所有可以变成里侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,aux.ExceptThisCard(e))
	-- 将获取到的怪兽全部变成里侧守备表示
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
-- 过滤条件：原本是表侧表示、现在变成里侧表示且由自己控制的怪兽
function c92970404.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 特殊召唤效果（①效果）的发动条件函数
function c92970404.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c92970404.cfilter,1,nil,tp)
		-- 且自己场上没有表侧表示怪兽存在
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果（①效果）的发动准备与目标确认函数
function c92970404.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有怪兽区域的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上没有表侧表示怪兽存在
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息为将手牌中的这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果（①效果）的效果处理函数
function c92970404.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧守备表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 变成里侧守备表示效果（②效果）的发动准备与目标确认函数
function c92970404.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(92970404)==0 end
	c:RegisterFlagEffect(92970404,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息为改变这张卡自身的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果（②效果）的效果处理函数
function c92970404.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
