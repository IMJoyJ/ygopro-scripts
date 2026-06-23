--創星神 sophia
-- 效果：
-- 这张卡不能通常召唤。把自己·对方场上表侧表示存在的仪式·融合·同调·超量怪兽各1只从游戏中除外的场合才能特殊召唤。这张卡的特殊召唤不会被无效化。这张卡特殊召唤成功时，这张卡以外的双方的手卡·场上·墓地的卡全部从游戏中除外。不能对应这个效果的发动让魔法·陷阱·效果怪兽的效果发动。
function c4335427.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。把自己·对方场上表侧表示存在的仪式·融合·同调·超量怪兽各1只从游戏中除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4335427.spcon)
	e1:SetTarget(c4335427.sptg)
	e1:SetOperation(c4335427.spop)
	c:RegisterEffect(e1)
	-- 这张卡的特殊召唤不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤成功时，这张卡以外的双方的手卡·场上·墓地的卡全部从游戏中除外。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- 不能对应这个效果的发动让魔法·陷阱·效果怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4335427,0))  --"除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c4335427.rmtg)
	e4:SetOperation(c4335427.rmop)
	c:RegisterEffect(e4)
end
-- 创建一个检查函数数组，用于判断是否满足仪式·融合·同调·超量怪兽的类型条件。
c4335427.spchecks=aux.CreateChecks(Card.IsType,{TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ})
-- 过滤函数，用于筛选场上正面表示且可作为除外费用的仪式·融合·同调·超量怪兽。
function c4335427.spcostfilter(c)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 判断特殊召唤条件是否满足，即是否能将自己和对方场上的仪式·融合·同调·超量怪兽各1只除外。
function c4335427.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有正面表示的怪兽。
	local g=Duel.GetMatchingGroup(c4335427.spcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查是否能将这些怪兽分组，每组包含一个仪式·融合·同调·超量怪兽。
	return g:CheckSubGroupEach(c4335427.spchecks,aux.mzctcheck,tp)
end
-- 设置特殊召唤的目标选择函数，用于选择要除外的怪兽。
function c4335427.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有正面表示的怪兽。
	local g=Duel.GetMatchingGroup(c4335427.spcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从符合条件的怪兽中选择满足条件的组合。
	local sg=g:SelectSubGroupEach(tp,c4335427.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，将选中的怪兽除外。
function c4335427.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽以特殊召唤的方式除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置特殊召唤成功时的除外效果目标。
function c4335427.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方手卡、场上和墓地的所有可除外卡。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	-- 设置连锁操作信息，表示将要除外的卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 设置连锁限制为无限制，允许任意连锁发动。
	Duel.SetChainLimit(aux.FALSE)
end
-- 执行特殊召唤成功后的除外效果。
function c4335427.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方手卡、场上和墓地的所有可除外卡（排除自身）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 将符合条件的卡以效果的方式除外。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
