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
	-- 把自己·对方场上表侧表示存在的仪式·融合·同调·超量怪兽各1只从游戏中除外的场合才能特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e3)
	-- 这张卡特殊召唤成功时，这张卡以外的双方的手卡·场上·墓地的卡全部从游戏中除外。不能对应这个效果的发动让魔法·陷阱·效果怪兽的效果发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(4335427,0))  --"除外"
	e4:SetCategory(CATEGORY_REMOVE)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetTarget(c4335427.rmtg)
	e4:SetOperation(c4335427.rmop)
	c:RegisterEffect(e4)
end
-- 为仪式、融合、同调、超量四种怪兽种类生成对应的类型判定函数，供后续筛选素材时分别检查是否满足每种类型。
c4335427.spchecks=aux.CreateChecks(Card.IsType,{TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ})
-- 筛选可作为除外素材的怪兽：必须表侧表示在场上、能作为代价除外，且属于仪式、融合、同调、超量怪兽之一。
function c4335427.spcostfilter(c)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 判定当前是否存在包含仪式·融合·同调·超量各1只的素材组合，且除外这些素材后自己场上仍有可用的怪兽区域，以满足规则特殊召唤条件。
function c4335427.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有符合除外素材条件的怪兽集合（包括对方怪兽区）。
	local g=Duel.GetMatchingGroup(c4335427.spcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 检查怪兽集合中能否选出一组卡，使仪式、融合、同调、超量各至少1只，并且除外后自己场上仍有怪兽区空位。
	return g:CheckSubGroupEach(c4335427.spchecks,aux.mzctcheck,tp)
end
-- 规则特殊召唤的选材阶段：让玩家从候选素材中选出仪式·融合·同调·超量各1只，确认满足条件后保存所选素材组供后续除外使用。
function c4335427.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取双方场上所有可作为素材的表侧表示仪式·融合·同调·超量怪兽集合。
	local g=Duel.GetMatchingGroup(c4335427.spcostfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 向玩家显示“请选择要除外的卡”的提示，并指定选择消息为除外类型。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 由玩家选择一组卡，要求同时包含仪式、融合、同调、超量怪兽各至少1只，并校验除外后自己场上仍有怪兽区空位；选不出则无法特殊召唤。
	local sg=g:SelectSubGroupEach(tp,c4335427.spchecks,true,aux.mzctcheck,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 规则特殊召唤的处理：取出选材阶段保存的素材组，将其从游戏中除外，从而完成这次特殊召唤的代价。
function c4335427.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的素材组以表侧表示从游戏中除外，作为这次特殊召唤的召唤手续。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 特殊召唤成功时的诱发必发效果：确定并登记要除外的对象（这张卡以外的双方手卡·场上·墓地所有可除外的卡），同时设置连锁限制，禁止任何卡连锁发动。
function c4335427.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取除这张卡本身以外的双方手卡、场上、墓地的所有可被除外的卡，作为效果处理时的对象集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler())
	-- 向系统登记本次效果将除外上述对象及其数量，用于后续连锁判定和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
	-- 设置连锁限制为始终返回假，表示任何魔法·陷阱·效果怪兽的效果都不能对应这个效果的发动而发动。
	Duel.SetChainLimit(aux.FALSE)
end
-- 效果处理时实际执行除外：将这张卡以外的双方手卡·场上·墓地的所有可除外卡全部从游戏中除外。
function c4335427.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取除外对象范围，并用辅助函数排除这张卡自身，避免把发动效果的这张卡也除外。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,aux.ExceptThisCard(e))
	-- 将收集到的所有卡以表侧表示从游戏中除外，完成全场除外的效果处理。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
