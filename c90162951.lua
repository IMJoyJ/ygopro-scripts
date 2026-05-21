--No.35 ラベノス・タランチュラ
-- 效果：
-- 10星怪兽×2
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升自己和对方的基本分差的数值。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把怪兽特殊召唤给与对方600伤害。
-- ③：1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的攻击力以下的攻击力的对方场上的怪兽全部破坏。
function c90162951.initial_effect(c)
	-- 设置XYZ召唤手续：10星怪兽×2
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的攻击力·守备力上升自己和对方的基本分差的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(c90162951.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，每次对方把怪兽特殊召唤给与对方600伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c90162951.damcon)
	e3:SetOperation(c90162951.damop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，把这张卡1个超量素材取除才能发动。持有这张卡的攻击力以下的攻击力的对方场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(90162951,0))  --"破坏怪兽"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCost(c90162951.descost)
	e4:SetTarget(c90162951.destg)
	e4:SetOperation(c90162951.desop)
	c:RegisterEffect(e4)
end
-- 设定该卡为“No.”怪兽，编号为35
aux.xyz_number[90162951]=35
-- 计算自己与对方基本分差值的数值函数
function c90162951.val(e,c)
	-- 返回双方玩家生命值之差的绝对值
	return math.abs(Duel.GetLP(0)-Duel.GetLP(1))
end
-- 过滤特殊召唤的怪兽是否由指定玩家进行召唤
function c90162951.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 检查自身是否持有超量素材以及对方是否特殊召唤了怪兽的发动条件函数
function c90162951.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetOverlayCount()>0 and eg:IsExists(c90162951.cfilter,1,nil,1-tp)
end
-- 伤害效果的执行函数，给与对方600点伤害
function c90162951.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了该卡的效果（显示卡片动画）
	Duel.Hint(HINT_CARD,0,90162951)
	-- 给与对方玩家600点效果伤害
	Duel.Damage(1-tp,600,REASON_EFFECT)
end
-- 破坏效果的代价处理函数，取除自身1个超量素材
function c90162951.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤对方场上表侧表示且攻击力在指定数值以下的怪兽
function c90162951.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 破坏效果的目标确认与操作信息设置函数
function c90162951.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否存在至少1只攻击力在自身攻击力以下的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90162951.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 获取对方场上所有攻击力在自身攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c90162951.desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	-- 设置效果处理的操作信息为破坏这些符合条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数，破坏对方场上所有攻击力在自身攻击力以下的表侧表示怪兽
function c90162951.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 效果处理时，重新获取对方场上所有攻击力在自身当前攻击力以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c90162951.desfilter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	-- 因效果破坏这些符合条件的怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
