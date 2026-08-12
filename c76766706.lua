--混沌の種
-- 效果：
-- 自己场上有光属性以及暗属性怪兽存在的场合，选择除外的1只自己的光属性或者暗属性的战士族怪兽才能发动。选择的怪兽加入手卡。「混沌之种」在1回合只能发动1张。
function c76766706.initial_effect(c)
	-- 自己场上有光属性以及暗属性怪兽存在的场合，选择除外的1只自己的光属性或者暗属性的战士族怪兽才能发动。选择的怪兽加入手卡。「混沌之种」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,76766706+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c76766706.condition)
	e1:SetTarget(c76766706.target)
	e1:SetOperation(c76766706.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且为指定属性的怪兽
function c76766706.cfilter(c,att)
	return c:IsFaceup() and c:IsAttribute(att)
end
-- 发动条件：自己场上同时存在表侧表示的光属性和暗属性怪兽
function c76766706.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的光属性怪兽
	return Duel.IsExistingMatchingCard(c76766706.cfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_LIGHT)
		-- 并且检查自己场上是否存在表侧表示的暗属性怪兽
		and Duel.IsExistingMatchingCard(c76766706.cfilter,tp,LOCATION_MZONE,0,1,nil,ATTRIBUTE_DARK)
end
-- 过滤条件：除外状态的表侧表示、光属性或暗属性的战士族怪兽，且能加入手卡
function c76766706.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与处理
function c76766706.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c76766706.filter(chkc) end
	-- 在发动阶段，检查除外区是否存在符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c76766706.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 设置提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只自己的光属性或暗属性战士族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c76766706.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理的执行函数
function c76766706.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
