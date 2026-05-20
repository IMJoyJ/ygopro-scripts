--始祖神鳥シムルグ
-- 效果：
-- 这张卡在手卡的场合，当作通常怪兽使用。只要这张卡在场上表侧表示存在，风属性怪兽的祭品召唤需要的祭品变少1只。只用风属性怪兽作为祭品对这张卡的祭品召唤成功时，对方场上最多2张卡回到持有者手卡。
function c86489182.initial_effect(c)
	-- 这张卡在手卡的场合，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，风属性怪兽的祭品召唤需要的祭品变少1只。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DECREASE_TRIBUTE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	-- 设置减少祭品效果的对象为风属性怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WIND))
	e3:SetValue(c86489182.decval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DECREASE_TRIBUTE_SET)
	c:RegisterEffect(e4)
	-- 只用风属性怪兽作为祭品对这张卡的祭品召唤成功时，对方场上最多2张卡回到持有者手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(86489182,0))  --"返回手牌"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetCondition(c86489182.condition)
	e5:SetTarget(c86489182.target)
	e5:SetOperation(c86489182.operation)
	c:RegisterEffect(e5)
	-- 只用风属性怪兽作为祭品对这张卡的祭品召唤成功时
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_MATERIAL_CHECK)
	e6:SetValue(c86489182.valcheck)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 检查召唤素材是否全部为风属性怪兽，并在效果5上设置对应的标记值。
function c86489182.valcheck(e,c)
	local g=c:GetMaterial()
	if g:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WIND)==#g and #g>0 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 返回减少祭品的值（减少1个祭品，且该效果由本卡适用）。
function c86489182.decval(e,c)
	return 0x10001,86489182
end
-- 判定发动条件：必须是上级召唤成功，且祭品全部为风属性怪兽。
function c86489182.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 判定效果发动目标：选择对方场上最多2张卡作为效果对象，并设置操作信息。
function c86489182.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 判定是否可以发动效果：对方场上必须存在至少1张可以回到手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1到2张可以回到手牌的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置当前连锁的操作信息为将选择的卡片送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：将仍存在于场上的效果对象卡送回持有者手牌。
function c86489182.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 因效果将目标卡片组送回持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
