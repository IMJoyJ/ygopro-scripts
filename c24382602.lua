--光の霊堂
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性·1星调整召唤。
-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只通常怪兽送去墓地，作为对象的怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的等级×100。
-- ③：把墓地的这张卡除外才能发动。从卡组把1张「毁灭之爆裂疾风弹」加入手卡。
function c24382602.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只光属性·1星调整召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24382602,0))  --"使用「光之灵堂」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetTarget(c24382602.extg)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。从手卡·卡组把1只通常怪兽送去墓地，作为对象的怪兽的攻击力·守备力直到回合结束时上升送去墓地的怪兽的等级×100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetTarget(c24382602.atktg)
	e3:SetOperation(c24382602.atkop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。从卡组把1张「毁灭之爆裂疾风弹」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 将此卡除外作为cost
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(c24382602.thtg)
	e4:SetOperation(c24382602.thop)
	c:RegisterEffect(e4)
end
-- 过滤满足调整、光属性、1星条件的卡
function c24382602.extg(e,c)
	return c:IsType(TYPE_TUNER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(1)
end
-- 过滤表侧表示的怪兽
function c24382602.tgfilter(c)
	return c:IsFaceup()
end
-- 过滤通常怪兽且能送去墓地的卡
function c24382602.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果发动时的取对象和过滤条件
function c24382602.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c24382602.tgfilter(chkc) end
	-- 检查场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c24382602.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查手卡或卡组是否存在通常怪兽
		and Duel.IsExistingMatchingCard(c24382602.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c24382602.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 处理效果的发动和结算
function c24382602.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择要送去墓地的通常怪兽
	local g=Duel.SelectMatchingCard(tp,c24382602.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		local gc=g:GetFirst()
		local lv=gc:GetLevel()
		-- 判断是否成功将卡送去墓地且目标怪兽仍然有效
		if Duel.SendtoGrave(gc,REASON_EFFECT)~=0 and gc:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 使目标怪兽的攻击力上升其等级×100
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(lv*100)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
		end
	end
end
-- 过滤「毁灭之爆裂疾风弹」且能加入手牌的卡
function c24382602.thfilter(c)
	return c:IsCode(17655904) and c:IsAbleToHand()
end
-- 设置检索效果的过滤条件
function c24382602.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在「毁灭之爆裂疾风弹」
	if chk==0 then return Duel.IsExistingMatchingCard(c24382602.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理检索效果的发动和结算
function c24382602.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择要加入手牌的「毁灭之爆裂疾风弹」
	local g=Duel.SelectMatchingCard(tp,c24382602.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
