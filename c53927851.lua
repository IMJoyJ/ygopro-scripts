--絢嵐渦麗ヴァルルーン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己墓地有「旋风」存在，对方把怪兽的效果发动时才能发动。那个效果无效。自己墓地有「旋风」2张以上存在的场合，可以再把那只怪兽破坏。
-- ③：这张卡在墓地存在的状态，「旋风」发动的场合才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「旋风」的卡名
	aux.AddCodeList(c,5318639)
	-- ①：速攻魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己墓地有「旋风」存在，对方把怪兽的效果发动时才能发动。那个效果无效。自己墓地有「旋风」2张以上存在的场合，可以再把那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，「旋风」发动的场合才能发动。这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.spcon2)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：对方发动速攻魔法卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_QUICKPLAY)
end
-- 效果③的发动条件：对方发动「旋风」
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(5318639)
end
-- 效果①的发动时处理：判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的OperationInfo信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果③的发动处理：将自身特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件（排除王家长眠之谷影响）
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤器函数：判断是否为正面表示的「旋风」
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(5318639)
end
-- 效果②的发动条件：己方墓地存在「旋风」且对方发动怪兽效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方墓地是否存在至少1张「旋风」
	if not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,1,nil) then return end
	-- 判断对方发动的是怪兽效果且该效果可以被无效
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果②的发动时处理：设置OperationInfo信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的OperationInfo信息
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果②的发动处理：使对方效果无效并可选择破坏对方怪兽
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 尝试使对方效果无效
	if not Duel.NegateEffect(ev) then return end
	-- 判断己方墓地是否存在至少2张「旋风」
	if Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_GRAVE,0,2,nil)
		and rc:IsRelateToChain(ev) and rc:IsType(TYPE_MONSTER) and rc:IsDestructable()
		-- 询问玩家是否破坏对方怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否把卡破坏？"
		-- 中断当前连锁处理
		Duel.BreakEffect()
		-- 破坏对方怪兽
		Duel.Destroy(rc,REASON_EFFECT)
	end
end
