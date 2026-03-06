--暗黒よりの軍勢
-- 效果：
-- ①：以自己墓地2只「暗黑界」怪兽为对象才能发动。那些怪兽加入手卡。
function c29826127.initial_effect(c)
	-- 效果原文内容：①：以自己墓地2只「暗黑界」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c29826127.target)
	e1:SetOperation(c29826127.activate)
	c:RegisterEffect(e1)
end
-- 规则层面作用：定义过滤函数，用于筛选满足条件的怪兽（暗黑界、怪兽类型、可加入手卡）
function c29826127.filter(c)
	return c:IsSetCard(0x6) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 规则层面作用：处理效果发动时的取对象判定，检查是否满足条件并选择目标
function c29826127.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c29826127.filter(chkc) end
	-- 规则层面作用：检查是否满足发动条件（自己墓地存在2只符合条件的怪兽）
	if chk==0 then return Duel.IsExistingTarget(c29826127.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择满足条件的2只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c29826127.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 规则层面作用：设置当前连锁的操作信息，指定效果处理时将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果原文内容：①：以自己墓地2只「暗黑界」怪兽为对象才能发动。那些怪兽加入手卡。
function c29826127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中已选定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 规则层面作用：将符合条件的目标怪兽以效果原因送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 规则层面作用：向对方确认被送入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
