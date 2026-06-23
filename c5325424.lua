--牙竜転生
-- 效果：
-- 选择从游戏中除外的1只自己的龙族怪兽加入手卡。
function c5325424.initial_effect(c)
	-- 创建效果，设置为魔陷发动，选择对象，自由时点，指定目标和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c5325424.target)
	e1:SetOperation(c5325424.activate)
	c:RegisterEffect(e1)
end
-- 过滤器函数：检查怪兽是否表侧表示、龙族且能加入手牌
function c5325424.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsAbleToHand()
end
-- 效果处理的目标选择函数：判断目标是否满足条件并选择一个除外区的龙族怪兽
function c5325424.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c5325424.filter(chkc) end
	-- 检查是否有满足条件的除外区龙族怪兽可选
	if chk==0 then return Duel.IsExistingTarget(c5325424.filter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从除外区选择一只符合条件的龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c5325424.filter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，指定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时的处理函数：获取目标怪兽并将其送入手牌
function c5325424.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（即被选择的除外区怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认该怪兽加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
end
