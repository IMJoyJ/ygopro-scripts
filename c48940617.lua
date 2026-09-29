--光器の降雷
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有通常怪兽或「塞尼特」仪式怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
-- ②：自己场上的通常怪兽卡的攻击力合计比3000高的场合，把墓地的这张卡除外才能发动。从自己的卡组·墓地把「光器之降雷」以外的1张「塞尼特」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：注册反击效果（无效魔陷发动并破坏）以及墓地除外盖放「塞尼特」魔陷效果
function s.initial_effect(c)
	-- ①：自己场上有通常怪兽或「塞尼特」仪式怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的通常怪兽卡的攻击力合计比3000高的场合，把墓地的这张卡除外才能发动。从自己的卡组·墓地把「光器之降雷」以外的1张「塞尼特」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(s.setcon)
	-- 发动代价：将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的通常怪兽或「塞尼特」仪式怪兽
function s.cfilter(c)
	return c:IsFaceup() and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x1eb) and c:IsType(TYPE_RITUAL))
end
-- 效果①的发动条件判定
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在通常怪兽或「塞尼特」仪式怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查是否为对方发动的魔法·陷阱卡且发动可以被无效
		and rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
end
-- 效果①的目标判定与操作信息设置
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该发动的卡作为无效对象
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：若该卡与效果仍有关联则将其破坏
	if re:GetHandler():IsRelateToEffect(re) then Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0) end
end
-- 效果①的操作处理：使魔法·陷阱卡的发动无效并破坏
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁的发动无效并确认该卡与连锁关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏该卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤场上表侧表示的通常怪兽卡
function s.csfilter(c)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
end
-- 获取通常怪兽卡的攻击力
function s.getatk(c)
	if c:IsType(TYPE_MONSTER) then
		return c:GetAttack()
	else
		return c:GetBaseAttack()
	end
end
-- 效果②的发动条件：自己场上的通常怪兽卡的攻击力合计比3000高
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有的表侧表示通常怪兽卡
	local g=Duel.GetMatchingGroup(s.csfilter,tp,LOCATION_ONFIELD,0,nil)
	return g:GetSum(s.getatk)>3000
end
-- 过滤卡组·墓地中同名卡以外可以盖放的「塞尼特」魔法·陷阱卡
function s.setfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1eb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的目标判定
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地是否存在可以盖放的「塞尼特」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
-- 效果②的操作处理：从卡组·墓地把1张「塞尼特」魔陷在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组·墓地选择1张同名卡以外的「塞尼特」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
