--疾風鳥人ジョー
-- 效果：
-- 用风属性怪兽为祭品作祭品召唤成功的场合，场上的魔法·陷阱卡全部回到持有者手卡。
function c81896370.initial_effect(c)
	-- 用风属性怪兽为祭品作祭品召唤成功的场合，场上的魔法·陷阱卡全部回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81896370,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c81896370.condition)
	e1:SetTarget(c81896370.target)
	e1:SetOperation(c81896370.operation)
	c:RegisterEffect(e1)
	-- 用风属性怪兽为祭品
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c81896370.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 在召唤成功前，检查解放（祭品）怪兽中是否存在风属性怪兽，并将结果记录在主效果中
function c81896370.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WIND) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 确认此卡是以上级召唤（祭品召唤）方式召唤成功，且解放素材中包含风属性怪兽
function c81896370.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 过滤场上的魔法·陷阱卡，且该卡可以回到手卡
function c81896370.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动的目标，检查场上是否存在可回手的魔陷，并向系统宣告将场上所有魔陷送回手卡
function c81896370.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查场上是否存在至少1张可以回到手卡的魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81896370.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上所有可以回到手卡的魔法和陷阱卡
	local sg=Duel.GetMatchingGroup(c81896370.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息，宣告将场上所有的魔法、陷阱卡送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理，获取场上所有的魔法、陷阱卡并将其全部送回持有者手卡
function c81896370.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上所有可以回到手卡的魔法和陷阱卡
	local sg=Duel.GetMatchingGroup(c81896370.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将这些魔法、陷阱卡全部送回持有者的手卡
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
