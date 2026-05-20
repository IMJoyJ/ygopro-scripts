--炎王獣 ヤクシャ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被破坏送去墓地的场合才能发动。自己的手卡·场上1张卡破坏。
function c66413481.initial_effect(c)
	-- ①：自己场上的表侧表示的「炎王」怪兽被效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(66413481,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c66413481.spcon)
	e1:SetTarget(c66413481.sptg)
	e1:SetOperation(c66413481.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被破坏送去墓地的场合才能发动。自己的手卡·场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(66413481,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,66413481)
	e2:SetCondition(c66413481.descon)
	e2:SetTarget(c66413481.destg)
	e2:SetOperation(c66413481.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：检查被破坏的卡是否为自己场上表侧表示的「炎王」怪兽，且是被效果破坏
function c66413481.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_EFFECT) and c:IsSetCard(0x81)
end
-- 效果①的发动条件：检查被破坏的卡片中是否存在满足过滤条件的卡
function c66413481.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c66413481.cfilter,1,nil,tp)
end
-- 效果①的发动检测：检查自己场上是否有可用的怪兽区域空格，且这张卡是否可以特殊召唤
function c66413481.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：若自身仍存在于手卡，则将自身特殊召唤
function c66413481.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的发动条件：检查这张卡是否是被破坏送去墓地
function c66413481.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 效果②的发动检测与操作信息设置：检查自己手卡或场上是否有卡可以破坏，并设置破坏的操作信息
function c66413481.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡或场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil) end
	-- 获取自己手卡及场上的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	-- 设置连锁处理的操作信息：破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理：从自己的手卡或场上选择1张卡破坏
function c66413481.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从自己的手卡或场上选择1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
