--超化合獣メタン・ハイド
-- 效果：
-- 8星二重怪兽×2
-- ①：这张卡超量召唤成功时，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把自己场上的二重怪兽作为攻击对象，也不能作为效果的对象。
-- ③：二重怪兽召唤成功时，把这张卡1个超量素材取除才能发动。对方必须把自身的手卡·场上1张卡送去墓地。
function c38026562.initial_effect(c)
	-- 为这张卡添加超量召唤规则，素材为等级8的二重怪兽×2
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsXyzType,TYPE_DUAL),8,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤成功时，以自己墓地1只二重怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38026562,0))  --"特殊召唤墓地二重怪兽"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c38026562.spcon)
	e1:SetTarget(c38026562.sptg)
	e1:SetOperation(c38026562.spop)
	c:RegisterEffect(e1)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方不能把自己场上的二重怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c38026562.con)
	e2:SetValue(c38026562.atlimit)
	c:RegisterEffect(e2)
	-- ②：只要持有超量素材的这张卡在怪兽区域存在，对方也不能把自己场上的二重怪兽作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(c38026562.con)
	-- 设置该保护效果的作用对象为二重怪兽，即只有二重怪兽受到“不能成为效果对象”的保护。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	-- 设置效果值，使此效果只对对方玩家的效果适用：对方不能把我方二重怪兽作为效果对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：二重怪兽召唤成功时，把这张卡1个超量素材取除才能发动。对方必须把自身的手卡·场上1张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38026562,1))  --"对方卡送去墓地"
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c38026562.tgcon)
	e4:SetCost(c38026562.tgcost)
	e4:SetTarget(c38026562.tgtg)
	e4:SetOperation(c38026562.tgop)
	c:RegisterEffect(e4)
end
-- 效果发动条件判定：这张卡是超量召唤成功时才能发动。
function c38026562.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 过滤函数：选择自己墓地1只是二重怪兽且可以被特殊召唤的怪兽。
function c38026562.spfilter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时检查与目标选择：需要自己墓地存在1只可特殊召唤的二重怪兽，且自己场上存在可用的怪兽区域。
function c38026562.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c38026562.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己场上有空余的怪兽区，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在至少1只满足特殊召唤条件的二重怪兽。
		and Duel.IsExistingTarget(c38026562.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择要特殊召唤的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的二重怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c38026562.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，标记本效果将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为对象的墓地二重怪兽以表侧表示特殊召唤到自己场上。
function c38026562.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到其持有者（自己）的场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果持续条件判定：这张卡持有超量素材时，②效果适用。
function c38026562.con(e)
	return e:GetHandler():GetOverlayCount()>0
end
-- 攻击对象限制的判定：对方不能选择自己场上表侧表示的二重怪兽作为攻击对象。
function c38026562.atlimit(e,c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- ③的触发条件判定：有二重怪兽（通常）召唤成功时触发。
function c38026562.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_DUAL)
end
-- 发动代价：取除这张卡的1个超量素材作为COST。
function c38026562.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标设定：处理时将对方手卡·场上1张卡送去墓地。
function c38026562.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方手卡·场上合计有至少1张卡，才能让对方送墓。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD+LOCATION_HAND)>0 end
	-- 设置操作信息：效果处理时将对方手卡·场上1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_ONFIELD+LOCATION_HAND)
end
-- 效果处理：由对方从自身手卡·场上选择1张卡送去墓地。
function c38026562.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手卡·场上的所有卡，作为可选择的集合。
	local g=Duel.GetMatchingGroup(nil,1-tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil)
	if g:GetCount()>0 then
		-- 向对方玩家显示选择要送去墓地的卡的提示。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 展示被选择的卡作为对象（广义）的动画。
		Duel.HintSelection(sg)
		-- 将对方选择的卡以规则效果送去墓地。
		Duel.SendtoGrave(sg,REASON_RULE,1-tp)
	end
end
