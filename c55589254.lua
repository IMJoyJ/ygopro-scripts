--氷炎の双竜
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只水属性怪兽和1只炎属性怪兽从游戏中除外的场合才能特殊召唤。1回合1次，丢弃1张手卡才能发动。选择场上1只怪兽破坏。
function c55589254.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地2只水属性怪兽和1只炎属性怪兽从游戏中除外的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c55589254.spcon)
	e2:SetTarget(c55589254.sptg)
	e2:SetOperation(c55589254.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，丢弃1张手卡才能发动。选择场上1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(55589254,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c55589254.descost)
	e3:SetTarget(c55589254.destg)
	e3:SetOperation(c55589254.desop)
	c:RegisterEffect(e3)
end
-- 创建用于检查特殊召唤所需素材属性（2只水属性和1只炎属性）的条件检查函数数组
c55589254.spchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_WATER,ATTRIBUTE_WATER,ATTRIBUTE_FIRE})
-- 过滤自身墓地中可以作为特殊召唤Cost除外的水属性或炎属性怪兽
function c55589254.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER+ATTRIBUTE_FIRE) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断函数，检查怪兽区域是否有空位，以及墓地中是否存在满足条件的除外素材
function c55589254.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家墓地中所有满足特殊召唤过滤条件（水属性或炎属性且能被除外）的卡片组
	local g=Duel.GetMatchingGroup(c55589254.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查玩家场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c55589254.spchecks)
end
-- 特殊召唤规则的素材选择函数，从墓地中选择符合条件的2只水属性和1只炎属性怪兽，并将其保存在效果对象中
function c55589254.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地中所有满足特殊召唤过滤条件（水属性或炎属性且能被除外）的卡片组
	local g=Duel.GetMatchingGroup(c55589254.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c55589254.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行函数，将选定的素材怪兽除外以完成特殊召唤
function c55589254.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏效果的发动代价（Cost）处理函数，检查并执行丢弃1张手卡的操作
function c55589254.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查玩家手牌中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动效果的代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 破坏效果的目标选择（Target）与信息注册函数，用于确认是否能选择场上的怪兽为对象，并进行取对象和注册操作信息
function c55589254.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动效果前，检查场上是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果包含破坏1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际执行（Operation）函数，将选定的对象怪兽破坏
function c55589254.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将选定的对象怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
