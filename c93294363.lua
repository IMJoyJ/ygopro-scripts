--見えざる誘い手
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「不可见之手」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以把破坏的怪兽在自己场上特殊召唤。
local s,id,o=GetID()
-- 注册卡片发动时的效果：无效怪兽效果并破坏，之后可特殊召唤
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「不可见之手」怪兽存在，对方把怪兽的效果发动时才能发动。那个发动无效并破坏。那之后，可以把破坏的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「不可见之手」怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1d3)
end
-- 发动条件：对方发动怪兽效果时，且自己场上有「不可见之手」怪兽存在
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该发动可以被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「不可见之手」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的处理：设置无效与破坏的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效该发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动的卡可以被破坏且仍存在于连锁中，设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：无效发动并破坏，之后可选择将该怪兽特殊召唤
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 无效该效果的发动，若无效失败则结束处理
	if not Duel.NegateActivation(ev) then return end
	-- 若该卡仍与连锁关联，则将其破坏；若破坏成功，且该卡未回到手牌、卡组或里侧除外
	if rc:IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and not (rc:IsLocation(LOCATION_HAND+LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown())
		-- 且该卡不受「王家长眠之谷」的影响
		and aux.NecroValleyFilter()(rc) then
		-- 若该卡是怪兽，且其不在额外卡组时自己场上有空余的怪兽区域
		if rc:IsType(TYPE_MONSTER) and (not rc:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 或者其在额外卡组表侧表示存在时，自己场上有空余的额外怪兽区域
			or rc:IsLocation(LOCATION_EXTRA) and rc:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,rc)>0)
			and rc:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 且该怪兽可以特殊召唤，由玩家选择是否特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤不与破坏同时处理
			Duel.BreakEffect()
			-- 将破坏的怪兽在自己场上表侧表示特殊召唤
			Duel.SpecialSummon(rc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
