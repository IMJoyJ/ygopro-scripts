--R.B. VALCan Rocket
-- 效果：
-- 自己场上的表侧表示怪兽不存在的场合或者只有「奏悦机组」怪兽的场合，这张卡可以从手卡特殊召唤。自己对「奏悦机组 火神火箭」的这个方法的特殊召唤1回合只能有1次。
-- 这张卡在「奏悦机组」连接怪兽所连接区存在的场合：可以支付1000基本分，以对方场上最多2张卡为对象；那些卡破坏。这张卡破坏。给与对方这个效果破坏的卡的数量×500的伤害。「奏悦机组 火神火箭」的这个效果1回合只能使用1次。
-- 
local s,id,o=GetID()
-- 注册卡片效果：手卡特召的规则效果，以及在连接区发动、破坏场上卡片并造成伤害的起动效果
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
-- 过滤条件：表侧表示且不是「奏悦机组」的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsSetCard(0x1cf)
end
-- 特殊召唤规则的条件判断
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的非「奏悦机组」怪兽（即：不存在怪兽，或只有「奏悦机组」怪兽）
		and not Duel.IsExistingMatchingCard(s.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：表侧表示的「奏悦机组」连接怪兽
function s.ecfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cf) and c:IsType(TYPE_LINK)
end
-- 效果发动条件：检查自身是否处于「奏悦机组」连接怪兽所连接的区域
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的表侧表示「奏悦机组」连接怪兽
	local lg=Duel.GetMatchingGroup(s.ecfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local lg2=Group.CreateGroup()
	-- 遍历这些连接怪兽，合并它们所指向的区域
	for lc in aux.Next(lg) do
		lg2:Merge(lc:GetLinkedGroup())
	end
	return lg2 and lg2:IsContains(e:GetHandler())
end
-- 效果发动代价：支付1000基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 效果发动时的对象选择与操作信息注册
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的目标卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1到2张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,2,nil)
	g:AddCard(e:GetHandler())
	-- 设置破坏的操作信息，包含选择的对方卡片和这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 设置伤害的操作信息，数值为破坏卡片数量乘以500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*500)
end
-- 效果处理：破坏目标卡片与自身，并根据破坏数量给予对方伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍合法的对象卡片
	local tg=Duel.GetTargetsRelateToChain()
	if c:IsRelateToChain() then
		tg:AddCard(c)
	end
	-- 如果存在需要破坏的卡，则执行破坏操作
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)~=0 then
		-- 获取本次操作中实际被破坏的卡片数量
		local dam=Duel.GetOperatedGroup():GetCount()
		if dam>0 then
			-- 给与对方实际破坏卡片数量×500的伤害
			Duel.Damage(1-tp,dam*500,REASON_EFFECT)
		end
	end
end
