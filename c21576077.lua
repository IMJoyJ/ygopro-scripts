--喰光の竜輝巧
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：把墓地的这张卡除外，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升2000。这个效果在这张卡送去墓地的回合不能发动。
function c21576077.initial_effect(c)
	-- ①：以自己墓地1只「龙辉巧」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21576077,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,21576077)
	e1:SetTarget(c21576077.target)
	e1:SetOperation(c21576077.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「龙辉巧」怪兽为对象才能发动。那只怪兽的攻击力直到对方回合结束时上升2000。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21576077,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,21576078)
	-- 设置效果条件为：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果的费用为：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21576077.atktg)
	e2:SetOperation(c21576077.atkop)
	c:RegisterEffect(e2)
end
-- 定义过滤函数，用于筛选墓地中的「龙辉巧」怪兽
function c21576077.filter(c)
	return c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果处理时的处理函数，用于选择目标怪兽并设置操作信息
function c21576077.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21576077.filter(chkc) end
	-- 判断是否满足发动条件：场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c21576077.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c21576077.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理函数，将目标怪兽加入手牌
function c21576077.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 定义攻击力变化效果的过滤函数，用于筛选场上正面表示的「龙辉巧」怪兽
function c21576077.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154)
end
-- 效果处理时的处理函数，用于选择目标怪兽并设置操作信息
function c21576077.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c21576077.atkfilter(chkc) end
	-- 判断是否满足发动条件：场上是否存在符合条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c21576077.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c21576077.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动时的处理函数，使目标怪兽攻击力上升2000
function c21576077.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 为对象怪兽添加攻击力上升2000的效果，持续到对方回合结束
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
	end
end
