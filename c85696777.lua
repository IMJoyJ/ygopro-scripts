--ハーピィ・コンダクター
-- 效果：
-- 风属性怪兽2只
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「鹰身女郎」使用。
-- ②：自己场上的「鹰身」怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1张魔法·陷阱卡破坏。
-- ③：自己场上的其他的表侧表示的「鹰身」怪兽回到自己手卡的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽回到手卡。
function c85696777.initial_effect(c)
	-- 设置连接召唤手续：风属性怪兽2只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_WIND),2,2)
	c:EnableReviveLimit()
	-- 设置这张卡在场上·墓地存在时卡名当作「鹰身女郎」使用
	aux.EnableChangeCode(c,76812113,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：自己场上的「鹰身」怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85696777)
	e2:SetTarget(c85696777.desreptg)
	e2:SetValue(c85696777.desrepval)
	e2:SetOperation(c85696777.desrepop)
	c:RegisterEffect(e2)
	-- ③：自己场上的其他的表侧表示的「鹰身」怪兽回到自己手卡的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85696777,0))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_HAND)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,85696778)
	e3:SetCondition(c85696777.thcon)
	e3:SetTarget(c85696777.thtg)
	e3:SetOperation(c85696777.thop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上因战斗或效果破坏的表侧表示「鹰身」怪兽
function c85696777.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x64)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)) and not c:IsReason(REASON_REPLACE)
end
-- 过滤自己场上可以作为代替破坏的魔法·陷阱卡
function c85696777.desfilter(c,e,tp)
	return c:IsControler(tp) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的Target函数，检查是否有被破坏的「鹰身」怪兽以及自己场上是否有可代替破坏的魔陷
function c85696777.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c85696777.repfilter,1,nil,tp)
		-- 检查自己场上是否存在至少1张可以代替破坏的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(c85696777.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 玩家选择自己场上1张魔法·陷阱卡作为代替破坏的卡
		local g=Duel.SelectMatchingCard(tp,c85696777.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 确定该代替破坏效果适用于哪些被破坏的卡
function c85696777.desrepval(e,c)
	return c85696777.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏效果的Operation函数，将选中的魔陷卡破坏以代替怪兽的破坏
function c85696777.desrepop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替卡
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤从自己场上表侧表示回到手牌的「鹰身」怪兽
function c85696777.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsControler(tp) and c:IsSetCard(0x64)
end
-- 效果③的Condition函数，检查是否有自己场上的表侧表示「鹰身」怪兽回到手牌
function c85696777.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c85696777.cfilter,1,nil,tp)
end
-- 过滤对方场上特殊召唤且能回到手牌的怪兽
function c85696777.thfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToHand()
end
-- 效果③的Target函数，选择对方场上1只特殊召唤的怪兽作为对象并设置效果处理信息
function c85696777.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c85696777.thfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c85696777.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择对方场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c85696777.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的Operation函数，将作为对象的怪兽送回手牌
function c85696777.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（即对方场上被选中的特殊召唤的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽送回持有者手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
