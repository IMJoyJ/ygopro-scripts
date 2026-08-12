--ヴァンパイア帝国
-- 效果：
-- 场上的不死族怪兽的攻击力只在伤害计算时上升500。此外，1回合1次，从对方卡组有卡被送去墓地时，从自己的手卡·卡组把1只名字带有「吸血鬼」的暗属性怪兽送去墓地，选择场上1张卡破坏。
function c62188962.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 场上的不死族怪兽的攻击力只在伤害计算时上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果影响的对象为场上的不死族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ZOMBIE))
	e2:SetCondition(c62188962.atkcon)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 1回合1次，从对方卡组有卡被送去墓地时，从自己的手卡·卡组把1只名字带有「吸血鬼」的暗属性怪兽送去墓地，选择场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(62188962,0))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c62188962.descon)
	e3:SetTarget(c62188962.destg)
	e3:SetOperation(c62188962.desop)
	c:RegisterEffect(e3)
end
-- 攻击力上升效果的生效条件函数
function c62188962.atkcon(e)
	-- 判断当前阶段是否为伤害计算时
	return Duel.GetCurrentPhase()==PHASE_DAMAGE_CAL
end
-- 过滤从卡组送去墓地的卡的条件函数
function c62188962.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsPreviousControler(tp)
end
-- 破坏效果的发动条件函数，判断是否有对方卡组的卡被送去墓地
function c62188962.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c62188962.cfilter,1,nil,1-tp)
end
-- 过滤手卡或卡组中名字带有「吸血鬼」的暗属性且能送去墓地的怪兽
function c62188962.tgfilter(c)
	return c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGrave()
end
-- 破坏效果的发动准备与目标选择函数
function c62188962.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该效果包含从手卡或卡组将1张卡送去墓地的处理
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置操作信息，表示该效果包含破坏选定卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的实际处理函数
function c62188962.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己的手卡或卡组选择1只名字带有「吸血鬼」的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c62188962.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 获取发动时选择的破坏对象卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将该对象卡破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
