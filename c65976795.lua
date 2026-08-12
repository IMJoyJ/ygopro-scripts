--サブテラーマリス・アクエドリア
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ③：这张卡反转的场合，以自己场上的「地中族邪界」怪兽数量的场上盖放的卡为对象才能发动。那些卡破坏。
function c65976795.initial_effect(c)
	-- ③：这张卡反转的场合，以自己场上的「地中族邪界」怪兽数量的场上盖放的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65976795,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,65976795)
	e1:SetTarget(c65976795.target)
	e1:SetOperation(c65976795.operation)
	c:RegisterEffect(e1)
	-- ①：自己场上的表侧表示怪兽变成里侧表示时，自己场上没有表侧表示怪兽存在的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65976795,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_HAND)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(c65976795.spcon)
	e2:SetTarget(c65976795.sptg)
	e2:SetOperation(c65976795.spop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65976795,2))
	e3:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c65976795.postg)
	e3:SetOperation(c65976795.posop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「地中族邪界」怪兽
function c65976795.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x10ed)
end
-- 反转效果的发动准备与对象选择
function c65976795.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上表侧表示的「地中族邪界」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c65976795.filter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsOnField() and chkc:IsFacedown() end
	-- 在发动阶段，检查场上是否存在至少对应数量的里侧表示卡片作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择与自己场上「地中族邪界」怪兽数量相同的场上里侧表示的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置连锁信息，表示该效果的操作为破坏所选的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 反转效果的效果处理
function c65976795.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将选中的对象卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤从表侧表示变成里侧表示的自己场上的怪兽
function c65976795.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown() and c:IsControler(tp)
end
-- 特殊召唤效果的发动条件判定
function c65976795.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65976795.cfilter,1,nil,tp)
		-- 且自己场上不存在表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动准备
function c65976795.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查自己主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己场上不存在表侧表示的怪兽
		and not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁信息，表示该效果的操作为特殊召唤这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理
function c65976795.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡从手卡往自己场上表侧守备表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 变成里侧守备表示效果的发动准备
function c65976795.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(65976795)==0 end
	c:RegisterFlagEffect(65976795,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置连锁信息，表示该效果的操作为改变这张卡的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的效果处理
function c65976795.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将这张卡变成里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
