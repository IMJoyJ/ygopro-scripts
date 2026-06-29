--K9-EX “Ripper／M”
-- 效果：
-- 9星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡用「K9」魔法·陷阱卡的效果特殊召唤的场合，以对方的墓地·除外状态的最多2张卡为对象才能发动。那些卡回到卡组。
-- ②：这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材取除才能发动。那个效果无效。那之后，场上的卡全部破坏。
local s,id,o=GetID()
-- 注册超量召唤素材、K9魔陷特召时回收对方卡片、贯穿伤害、以及去除素材无效怪兽效果并破坏全场的效果
function s.initial_effect(c)
	-- 为卡片注册超量召唤的素材要求规程
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
	-- ③：对方把怪兽的效果发动时，把这张卡2个超量素材去除才能发动。那个效果无效。那之后，场上的卡全部破坏。
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
-- K9魔法·陷阱卡效果特召成功的分支条件判断
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSpecialSummonSetCard(0x1cb) and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 可返回卡组的对方墓地/除外状态卡片过滤条件
function s.tdfilter(c)
	return c:IsAbleToDeck()
end
-- 返回卡组效果的发动准备与对象选择
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(1-tp) and s.tdfilter(chkc) end
	-- 检查对方墓地或除外状态是否存在可以返回卡组的卡片
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 向玩家发送提示，请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择对方墓地或除外状态中最多2张卡片为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,0,LOCATION_GRAVE+LOCATION_REMOVED,1,2,nil)
	-- 设置操作信息为将选中的卡片返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 返回卡组效果的执行
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中关联且未受墓地无效影响的作为对象的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送回卡组并重新洗牌
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 对方发动怪兽效果的触发条件判断
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
		-- 检查对方发动的怪兽效果是否可以被无效化
		and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 去除此卡的2个超量素材作为效果发动的代价
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 无效并全场破坏效果的发动准备
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上的所有卡片
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息为破坏场上所有的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息为将对方发动的怪兽效果无效化
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 无效并全场破坏效果的执行
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若成功无效对方怪兽效果，则继续处理
	if Duel.NegateEffect(ev) then
		-- 获取场上所有可以被效果破坏的卡片
		local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if sg:GetCount()>0 then
			-- 切断效果处理的连锁时点
			Duel.BreakEffect()
			-- 破坏场上的所有卡片
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
