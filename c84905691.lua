--ナチュル・ホーストニードル
-- 效果：
-- 对方对怪兽的特殊召唤成功时，把这张卡以外的自己场上表侧表示存在的1只名字带有「自然」的怪兽解放才能发动。那些怪兽破坏。这个效果在对方回合也能发动。
function c84905691.initial_effect(c)
	-- 对方对怪兽的特殊召唤成功时，把这张卡以外的自己场上表侧表示存在的1只名字带有「自然」的怪兽解放才能发动。那些怪兽破坏。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84905691,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCost(c84905691.cost)
	e1:SetTarget(c84905691.target)
	e1:SetOperation(c84905691.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的名字带有「自然」的怪兽
function c84905691.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2a)
end
-- 发动代价（Cost）处理函数，支持「自然神圣树」的代替送墓效果或正常解放自身以外的1只「自然」怪兽
function c84905691.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否受到卡号为29942771（自然神圣树）的代替解放效果的影响
	local fe=Duel.IsPlayerAffectedByEffect(tp,29942771)
	-- 检查是否可以使用「自然神圣树」的效果，将卡组最上方2张卡送去墓地作为代替代价
	local b1=fe and Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
	-- 检查场上是否存在除这张卡以外的、可解放的表侧表示「自然」怪兽
	local b2=Duel.CheckReleaseGroup(tp,c84905691.cfilter,1,e:GetHandler())
	if chk==0 then return b1 or b2 end
	-- 如果满足代替条件，且（没有可解放怪兽或玩家选择使用代替效果），则执行代替送墓
	if b1 and (not b2 or Duel.SelectYesNo(tp,fe:GetDescription())) then
		-- 向双方玩家展示「自然神圣树」的卡片，提示正在适用其代替效果
		Duel.Hint(HINT_CARD,0,29942771)
		fe:UseCountLimit(tp)
		-- 将自己卡组最上方的2张卡送去墓地作为发动代价
		Duel.DiscardDeck(tp,2,REASON_COST)
	else
		-- 让玩家选择自己场上1只除这张卡以外的表侧表示「自然」怪兽
		local g=Duel.SelectReleaseGroup(tp,c84905691.cfilter,1,1,e:GetHandler())
		-- 将选中的怪兽解放作为发动代价
		Duel.Release(g,REASON_COST)
	end
end
-- 过滤条件：对方特殊召唤成功的怪兽（且在效果处理时仍与效果相关联）
function c84905691.filter(c,e,tp)
	return c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
-- 效果的目标选择与发动条件检查函数，确认对方特殊召唤了怪兽且自身未处于连锁中
function c84905691.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) and not eg:IsContains(e:GetHandler())
		and eg:IsExists(c84905691.filter,1,nil,nil,tp) end
	local g=eg:Filter(c84905691.filter,nil,nil,tp)
	-- 将本次特殊召唤成功的怪兽群设为效果处理的对象
	Duel.SetTargetCard(eg)
	-- 设置连锁的操作信息，表示该效果的处理为破坏这些特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理（Operation）函数，破坏那些特殊召唤成功的怪兽
function c84905691.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c84905691.filter,nil,e,tp)
	if g:GetCount()>0 then
		-- 将符合条件的特殊召唤怪兽全部破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
