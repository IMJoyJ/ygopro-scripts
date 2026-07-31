--R.B.バルカンロケット
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 火神火箭」的这个方法的特殊召唤1回合只能有1次。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1000基本分，以对方场上最多2张卡为对象；那些卡破坏。这张卡破坏。给与对方这个效果破坏的卡的数量×500的伤害。「奏悦机组 火神火箭」的这个效果1回合只能使用1次。
-- 
local s,id,o=GetID()
-- 初始化卡片效果：注册①手牌特召规则、②连接区破坏与伤害效果
function s.initial_effect(c)
	-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 火神火箭」的这个方法的特殊召唤1回合只能有1次。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1000基本分，以对方场上最多2张卡为对象；那些卡破坏。这张卡破坏。给与对方这个效果破坏的卡的数量×500的伤害。「奏悦机组 火神火箭」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且非「奏悦机组」的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 手牌特召条件检查：怪兽区有空位且场上没有非「奏悦机组」的表侧怪兽
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查怪兽区域是否有空余位置
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在非「奏悦机组」的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：场上表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 破坏效果发动条件：检查此卡是否处于「奏悦机组」连接怪兽的所连接区
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历场上的「奏悦机组」连接怪兽并合并其所连接的区域卡片
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 破坏效果Cost：支付1000基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：检查玩家是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 破坏效果准备：选择对方场上最多2张卡为对象，并将自身纳入破坏目标，设置破坏与伤害信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	-- 发动条件检查：对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1~2张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	g:AddCard(e:GetHandler())
	-- 设置连锁操作信息：破坏目标卡片及自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置连锁操作信息：给予对方破坏卡数×500的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
-- 破坏效果处理：破坏对象卡片和自身，并根据实际破坏卡数给予对方伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取与当前连锁相关的目标卡片
	local tg=Duel.GetTargetsRelateToChain()
	if c:IsRelateToChain() then
		tg:AddCard(c)
	end
	-- 破坏目标卡片及自身，若成功破坏则继续处理
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的卡片数量
		local dam=Duel.GetOperatedGroup():GetCount()
		if dam>0 then
			-- 给予对方实际破坏数量×500的伤害
			Duel.Damage(1-tp,dam*500,REASON_EFFECT)
		end
	end
end
