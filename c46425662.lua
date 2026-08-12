--エレメントセイバー・ナル
-- 效果：
-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·波涛」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
function c46425662.initial_effect(c)
	-- ①：1回合1次，从手卡把1只「元素灵剑士」怪兽送去墓地，以自己墓地1只「元素灵剑士·波涛」以外的「元素灵剑士」怪兽或者「灵神」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46425662,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCost(c46425662.thcost)
	e1:SetTarget(c46425662.thtg)
	e1:SetOperation(c46425662.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，1回合1次，宣言1个属性才能发动。墓地的这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46425662,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetTarget(c46425662.atttg)
	e2:SetOperation(c46425662.attop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查手牌或卡组中是否含有「元素灵剑士」怪兽且能作为效果的代价送去墓地
function c46425662.costfilter(c)
	return c:IsSetCard(0x400d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 处理效果①的发动费用，选择并送入墓地一张符合条件的「元素灵剑士」怪兽
function c46425662.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否受到效果61557074（卡名：命运英雄 火焰翼）的影响
	local fe=Duel.IsPlayerAffectedByEffect(tp,61557074)
	local loc=LOCATION_HAND
	if fe then loc=LOCATION_HAND+LOCATION_DECK end
	-- 检查在手牌或卡组中是否存在至少一张满足条件的「元素灵剑士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c46425662.costfilter,tp,loc,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的卡中选择一张作为效果的代价送入墓地
	local tc=Duel.SelectMatchingCard(tp,c46425662.costfilter,tp,loc,0,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_DECK) then
		-- 向对手显示卡号61557074（命运英雄 火焰翼）的发动动画
		Duel.Hint(HINT_CARD,0,61557074)
		fe:UseCountLimit(tp)
	end
	-- 将选中的卡以REASON_COST原因送去墓地
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 过滤函数，用于检查墓地中是否含有「元素灵剑士」或「灵神」怪兽且能加入手牌
function c46425662.thfilter(c)
	return c:IsSetCard(0x400d,0x113) and c:IsType(TYPE_MONSTER) and not c:IsCode(46425662) and c:IsAbleToHand()
end
-- 处理效果①的发动目标选择，选择一个满足条件的墓地怪兽作为对象
function c46425662.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c46425662.thfilter(chkc) end
	-- 检查在墓地中是否存在至少一张满足条件的「元素灵剑士」或「灵神」怪兽
	if chk==0 then return Duel.IsExistingTarget(c46425662.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的墓地怪兽中选择一张作为效果的对象
	local g=Duel.SelectTarget(tp,c46425662.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，表示将要处理的效果是让目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果①的发动效果，将选中的目标怪兽加入手牌
function c46425662.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被指定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以REASON_EFFECT原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 处理效果②的发动目标选择，让玩家宣言一个属性
function c46425662.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言一个属性（不能与当前卡属性相同）
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置连锁操作信息，表示将要处理的效果是使墓地中的卡改变属性
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- 处理效果②的发动效果，使墓地中的卡在回合结束前变成宣言的属性
function c46425662.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 创建一个用于改变卡牌属性的永续效果，并在回合结束时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
