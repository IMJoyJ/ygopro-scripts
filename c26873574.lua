--カオス・ダイダロス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要场地魔法卡表侧表示存在，自己场上的光·暗属性怪兽不会成为对方的效果的对象。
-- ②：场地魔法卡表侧表示存在的场合，以最多有那个数量的场上的卡为对象才能发动。那些卡除外。
function c26873574.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c26873574.spcon)
	e1:SetTarget(c26873574.sptg)
	e1:SetOperation(c26873574.spop)
	c:RegisterEffect(e1)
	-- ①：只要场地魔法卡表侧表示存在，自己场上的光·暗属性怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(c26873574.tgcon)
	e2:SetTarget(c26873574.target)
	-- 设置保护判定值：将『不会成为对方的效果的对象』的判定条件指定为aux.tgoval，即只有对方发动的效果不能选择这些光·暗属性怪兽为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：场地魔法卡表侧表示存在的场合，以最多有那个数量的场上的卡为对象才能发动。那些卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26873574,0))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1,26873574)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c26873574.rmtg)
	e3:SetOperation(c26873574.rmop)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤素材的过滤条件：墓地中能够除外的光属性或暗属性怪兽。
function c26873574.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤规则条件：自己场上有空余怪兽区域，且墓地中存在光属性与暗属性怪兽各1只可作为除外素材。
function c26873574.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若自己场上没有可用的怪兽区域，则无法进行特殊召唤。
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取自己墓地中所有可以作为除外成本的光·暗属性怪兽。
	local g=Duel.GetMatchingGroup(c26873574.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查素材组能否选出2张，使其中一张为光属性、另一张为暗属性（即凑齐光暗各1只）。
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤规则的目标选择：从符合条件的墓地怪兽中选择1张光属性和1张暗属性怪兽作为除外的代价，并保存选择结果。
function c26873574.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得自己墓地中可作为除外素材的光·暗属性怪兽集合。
	local g=Duel.GetMatchingGroup(c26873574.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 给玩家显示『请选择要除外的卡』的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从候选怪兽中选出2张，满足光属性和暗属性各1张，作为特殊召唤的除外素材。
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则处理：将选出的光·暗怪兽各1只从墓地除外，然后引擎完成这张卡的特殊召唤。
function c26873574.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的素材以表侧表示除外，除外原因为特殊召唤的代价。
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 定义场地魔法卡过滤条件：表侧表示且为场地魔法卡。
function c26873574.ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FIELD)
end
-- ①效果的适用条件：场上存在表侧表示的场地魔法卡时，该保护效果生效。
function c26873574.tgcon(e)
	-- 检查双方场上是否存在至少1张表侧表示的场地魔法卡，作为①效果的适用条件。
	return Duel.IsExistingMatchingCard(c26873574.ffilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- ①效果的保护对象限定为光属性或暗属性的怪兽。
function c26873574.target(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- ②效果的发动与目标选择：根据场上表侧表示的场地魔法卡数量，选择场上1到该数量张可以除外的卡为对象，并设置除外处理信息。
function c26873574.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 统计场上表侧表示的场地魔法卡数量，作为②效果可选对象的最大数量。
	local ct=Duel.GetMatchingGroupCount(c26873574.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- ②效果的发动合法性检查：场上存在表侧表示场地魔法卡且至少存在1张可以除外的卡可供选择。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示『请选择要除外的卡』的对象选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从场上选择1到ct张可以除外的卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息：本次连锁为除外效果，并记录目标卡组及数量。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- ②效果处理：将发动时选择且仍与效果关联的卡除外。
function c26873574.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择的对象卡，并过滤掉已与效果失去关联的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将有效对象卡以表侧表示除外，完成②效果的处理。
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
