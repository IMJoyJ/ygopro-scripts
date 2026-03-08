--リチュア・マーカー
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，可以选择名字带有「遗式」的自己墓地存在的1张仪式怪兽或者仪式魔法卡加入手卡。
function c39905966.initial_effect(c)
	-- 诱发选发效果，通常召唤成功时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39905966,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c39905966.tg)
	e1:SetOperation(c39905966.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的卡片：名字带有「遗式」且为仪式怪兽或仪式魔法卡且能加入手牌
function c39905966.filter(c)
	return c:IsSetCard(0x3a) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 设置效果的目标为满足条件的墓地中的卡片
function c39905966.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39905966.filter(chkc) end
	-- 检查是否有满足条件的墓地卡片
	if chk==0 then return Duel.IsExistingTarget(c39905966.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地卡片作为目标
	local g=Duel.SelectTarget(tp,c39905966.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息为将目标卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果发动时执行的操作：将目标卡片加入手牌并确认对方查看
function c39905966.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认查看该卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
