--K9-EX “Ripper／M”
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化效果：添加9星×2的超量召唤手续并设置苏生限制，注册①回卡组效果（特殊召唤成功时诱发选发、取对象、1回合1次）、②贯穿伤害永续效果、③无效并破坏的诱发即时效果（1回合1次）
function s.initial_effect(c)
	-- 设置超量召唤手续：用2只9星怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tdcon)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"破坏"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- ①效果发动条件：确认这张卡是用「K9」魔法·陷阱卡的效果特殊召唤的（超量素材中包含「K9」卡且本次特殊召唤的原因是魔法·陷阱卡的效果）
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSpecialSummonSetCard(0x1cb) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤条件：可以回到卡组的卡
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- ①效果取对象处理：确认对方的墓地·除外状态存在可以回到卡组的卡，提示并选择最多2张作为对象，设置回卡组的操作信息
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 发动可行性检查：对方的墓地·除外状态存在至少1张可以成为对象的可以回到卡组的卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 以对方的墓地·除外状态的最多2张可以回到卡组的卡为对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,2,nil)
	-- 设置操作信息：将所选对象的卡回到卡组（数量为对象数）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ①效果处理：取得与当前连锁相关的对象卡（并排除受王家长眠之谷影响的卡），将它们回到卡组并洗切
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与当前连锁相关的对象卡，过滤掉受王家长眠之谷影响而不能成为对象的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 把那些卡回到持有者的卡组并洗切卡组
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③效果发动条件：对方发动怪兽的效果且该连锁的效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		-- 发动的是怪兽的效果，且该连锁的效果可以被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- ③效果发动代价：确认可以把这张卡的2个超量素材取除，作为代价取除2个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- ③效果目标处理：取得场上所有的卡，设置破坏场上全部卡以及无效对方效果的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有的卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏场上的全部卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：无效对方发动的1个效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ③效果处理：使对方发动的效果无效，无效成功的场合中断效果处理，那之后将场上的卡全部破坏
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方发动的怪兽效果无效，成功则继续后续处理
	if Duel.NegateEffect(ev) then
		-- 取得双方场上所有的卡
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使之后的破坏与无效不同时处理
			Duel.BreakEffect()
			-- 以效果原因破坏场上的全部卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
