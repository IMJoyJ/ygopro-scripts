--カオス・ダイダロス
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光属性和暗属性的怪兽各1只除外的场合可以特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：只要场地魔法卡表侧表示存在，自己场上的光·暗属性怪兽不会成为对方的效果的对象。
-- ②：场地魔法卡表侧表示存在的场合，以最多有那个数量的场上的卡为对象才能发动。那些卡除外。
function c26873574.initial_effect(c)
	c:EnableReviveLimit()
	-- ②：场地魔法卡表侧表示存在的场合，以最多有那个数量的场上的卡为对象才能发动。那些卡除外。
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
	-- 设置效果值为aux.tgoval函数，用于判断是否不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：场地魔法卡表侧表示存在的场合，以最多有那个数量的场上的卡为对象才能发动。那些卡除外。
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
-- 过滤函数：用于筛选可以作为特殊召唤cost的光属性和暗属性怪兽
function c26873574.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤条件函数：检查是否满足特殊召唤的条件，包括是否有足够的怪兽区和墓地是否有符合条件的怪兽组合
function c26873574.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有足够的怪兽区来特殊召唤
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 获取玩家墓地里所有可以作为cost的光暗属性怪兽
	local g=Duel.GetMatchingGroup(c26873574.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 检查获取的怪兽组中是否存在一个由光属性和暗属性怪兽组成的子组
	return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
end
-- 特殊召唤目标函数：选择满足条件的光暗属性怪兽组合作为特殊召唤的cost
function c26873574.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家墓地里所有可以作为cost的光暗属性怪兽
	local g=Duel.GetMatchingGroup(c26873574.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽组中选择一个由光属性和暗属性怪兽组成的子组
	local sg=g:SelectSubGroup(tp,aux.gfcheck,true,2,2,Card.IsAttribute,ATTRIBUTE_LIGHT,ATTRIBUTE_DARK)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤操作函数：将选中的怪兽除外并完成特殊召唤
function c26873574.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	-- 将选中的怪兽组以除外形式移除
	Duel.Remove(sg,POS_FACEUP,REASON_SPSUMMON)
	sg:DeleteGroup()
end
-- 场地魔法卡过滤函数：用于判断是否场上存在表侧表示的场地魔法卡
function c26873574.ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FIELD)
end
-- 效果条件函数：判断是否场上存在表侧表示的场地魔法卡
function c26873574.tgcon(e)
	-- 检查场上是否存在表侧表示的场地魔法卡
	return Duel.IsExistingMatchingCard(c26873574.ffilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果目标函数：判断目标怪兽是否为光属性或暗属性
function c26873574.target(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 除外效果目标函数：选择场上最多等于场地魔法卡数量的卡作为除外对象
function c26873574.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上表侧表示的场地魔法卡数量
	local ct=Duel.GetMatchingGroupCount(c26873574.ffilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToRemove() end
	-- 检查是否满足发动除外效果的条件
	if chk==0 then return ct>0 and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上最多等于场地魔法卡数量的卡作为除外对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置操作信息，记录本次效果将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
-- 除外效果操作函数：将选中的卡除外
function c26873574.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果选择的除外对象卡组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将选中的卡组以除外形式移除
		Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
	end
end
