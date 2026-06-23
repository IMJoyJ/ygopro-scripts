--蒼穹を睨めるダーク
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在墓地存在的状态，对方发动的怪兽的效果从卡组或额外卡组让怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
-- ②：包含把怪兽特殊召唤效果的怪兽的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个效果无效并破坏。
-- ③：这张卡被除外的回合的结束阶段才能发动。自己的除外状态的1只其他怪兽回到墓地。
local s,id,o=GetID()
-- 初始化卡片效果，创建三个触发效果分别对应①②③效果
function s.initial_effect(c)
	-- ①：这张卡在墓地存在的状态，对方发动的怪兽的效果从卡组或额外卡组让怪兽特殊召唤的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：包含把怪兽特殊召唤效果的怪兽的效果发动时，从自己的手卡·场上把1张卡除外才能发动。那个效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的回合的结束阶段才能发动。自己的除外状态的1只其他怪兽回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_REMOVE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②③的效果1回合各能使用1次。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收除外"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_REMOVED)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
end
-- 用于过滤对方特殊召唤的怪兽是否满足条件（来自卡组或额外卡组）
function s.cfilter(c,tp)
	local typ,se,sp=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT,SUMMON_INFO_REASON_PLAYER)
	return se and typ&TYPE_MONSTER~=0 and se:IsActivated() and sp==1-tp
		and c:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 判断是否有满足条件的怪兽被特殊召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置特殊召唤效果的目标和条件检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与连锁相关且未受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否为包含特殊召唤的连锁效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该连锁是否可以被无效且为怪兽类型
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
		and re:IsActiveType(TYPE_MONSTER)
end
-- 设置除外cost的处理函数
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡可除外作为cost
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张可除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡除外作为cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果无效并破坏的目标和信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，表示将要破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果无效并破坏的操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功使连锁效果无效且目标卡存在
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏目标怪兽
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 注册除外时的标记，用于记录被除外的回合
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为被除外的回合
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤可回收的除外怪兽
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 设置回收除外怪兽的目标和条件检查
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的除外怪兽可以回收
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler()) end
end
-- 执行回收除外怪兽的操作
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张可回收的除外怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_REMOVED,0,1,1,aux.ExceptThisCard(e))
	if g:GetCount()>0 then
		-- 将选中的卡送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_RETURN)
	end
end
