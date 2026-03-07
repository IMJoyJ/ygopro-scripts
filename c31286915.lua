--K9-EX “Ripper／M”
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续，设置此卡为可特殊召唤，创建①③效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为9、数量为2的怪兽进行叠放
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
-- 效果条件：此卡是通过「K9」魔法·陷阱卡的效果特殊召唤的
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSpecialSummonSetCard(0x1cb) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤函数：满足条件的卡可以回到卡组
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- 效果目标选择：选择对方墓地或除外状态的1~2张卡作为目标
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的1~2张卡作为目标
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,2,nil)
	-- 设置操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：将目标卡送回卡组
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选定的目标卡，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(aux.NecroValleyFilter(Card.IsRelateToChain),nil)
	if g:GetCount()>0 then
		-- 将符合条件的卡送回卡组并洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果条件：对方发动怪兽效果且该效果可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		-- 对方发动的是怪兽卡且该连锁可被无效
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果费用：支付2个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 效果目标：选择场上的所有卡作为破坏对象，并设置使效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：使对方效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：使对方效果无效，并破坏场上的所有卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方效果无效
	if Duel.NegateEffect(ev) then
		-- 获取场上的所有卡
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if sg:GetCount()>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 破坏场上的所有卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
