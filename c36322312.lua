--起動提督デストロイリボルバー
-- 效果：
-- 这张卡不能通常召唤。从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。
-- ①：只要自己场上有「零件」怪兽或者当作装备卡使用的「零件」怪兽存在，这张卡不会被战斗·效果破坏。
-- ②：1回合1次，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏。
function c36322312.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 从手卡以及自己场上的表侧表示的卡之中把2张「零件」怪兽卡送去墓地的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c36322312.sprcon)
	e2:SetTarget(c36322312.sprtg)
	e2:SetOperation(c36322312.sprop)
	c:RegisterEffect(e2)
	-- 只要自己场上有「零件」怪兽或者当作装备卡使用的「零件」怪兽存在，这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c36322312.indcon)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	-- 1回合1次，以这张卡以外的场上1张卡为对象才能发动。那张卡破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(36322312,0))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetTarget(c36322312.destg)
	e5:SetOperation(c36322312.desop)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的「零件」怪兽卡，包括手牌和场上表侧表示的卡，且必须是怪兽卡类型。
function c36322312.sprfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x51) and bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:IsAbleToGraveAsCost()
end
-- 检查玩家手牌和场上的「零件」怪兽卡是否至少有2张满足条件，并且有足够怪兽区空位。
function c36322312.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家手牌和场上的所有「零件」怪兽卡。
	local g=Duel.GetMatchingGroup(c36322312.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 检查这些卡中是否存在2张满足条件且能放入怪兽区的组合。
	return g:CheckSubGroup(aux.mzctcheck,2,2,tp)
end
-- 选择2张满足条件的「零件」怪兽卡并将其送去墓地，用于特殊召唤。
function c36322312.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家手牌和场上的所有「零件」怪兽卡。
	local g=Duel.GetMatchingGroup(c36322312.sprfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选择2张组成一组并进行处理。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 将之前选择的卡组送去墓地并清除其引用。
function c36322312.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将卡组送去墓地，作为特殊召唤的代价。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤满足条件的「零件」怪兽卡，包括场上表侧表示的卡和装备卡。
function c36322312.indfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x51) and (c:IsLocation(LOCATION_MZONE) or (bit.band(c:GetOriginalType(),TYPE_MONSTER)~=0 and c:GetEquipTarget()))
end
-- 检查玩家场上是否存在至少1张满足条件的「零件」怪兽卡。
function c36322312.indcon(e)
	-- 检查玩家场上是否存在至少1张满足条件的「零件」怪兽卡。
	return Duel.IsExistingMatchingCard(c36322312.indfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,1,nil)
end
-- 设置破坏效果的目标选择逻辑，允许选择场上任意一张非自身卡。
function c36322312.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	-- 判断是否满足破坏效果的发动条件，即场上存在至少1张可破坏的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张卡作为破坏目标。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置破坏效果的操作信息，确定要破坏的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡破坏。
function c36322312.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
