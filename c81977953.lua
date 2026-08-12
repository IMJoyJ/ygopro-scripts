--デザート・ツイスター
-- 效果：
-- 这张卡不能通常召唤。把自己墓地2只风属性怪兽和1只地属性怪兽从游戏中除外才能特殊召唤。可以丢弃1张手卡把场上1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
function c81977953.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己墓地2只风属性怪兽和1只地属性怪兽从游戏中除外才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c81977953.spcon)
	e2:SetTarget(c81977953.sptg)
	e2:SetOperation(c81977953.spop)
	c:RegisterEffect(e2)
	-- 可以丢弃1张手卡把场上1张魔法·陷阱卡破坏。这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81977953,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c81977953.descost)
	e3:SetTarget(c81977953.destg)
	e3:SetOperation(c81977953.desop)
	c:RegisterEffect(e3)
end
-- 创建用于检查墓地除外怪兽属性的条件检查函数数组（2只风属性和1只地属性）
c81977953.spchecks=aux.CreateChecks(Card.IsAttribute,{ATTRIBUTE_WIND,ATTRIBUTE_WIND,ATTRIBUTE_EARTH})
-- 过滤墓地中可以作为特殊召唤Cost除外的风属性或地属性怪兽
function c81977953.spfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_EARTH) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件判断函数（检查怪兽区域空位以及墓地是否存在满足条件的卡片组合）
function c81977953.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己墓地中所有满足条件的风属性和地属性怪兽
	local g=Duel.GetMatchingGroup(c81977953.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查自己场上的怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroupEach(c81977953.spchecks)
end
-- 特殊召唤规则的目标选择函数（选择要除外的卡片并保存在LabelObject中）
function c81977953.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地中所有满足条件的风属性和地属性怪兽
	local g=Duel.GetMatchingGroup(c81977953.spfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroupEach(tp,c81977953.spchecks,true)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数（将选中的卡片除外）
function c81977953.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤为原因表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 破坏效果的发动Cost处理函数（丢弃1张手卡）
function c81977953.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌作为发动Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上的魔法·陷阱卡
function c81977953.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的目标选择与发动准备函数
function c81977953.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c81977953.filter(chkc) end
	-- 检查场上是否存在可以作为效果对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c81977953.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c81977953.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行操作函数
function c81977953.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 破坏作为效果对象的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
