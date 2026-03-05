--泉の精霊
-- 效果：
-- 从自己的墓地里选择1张装备魔法卡加入手卡。这张装备魔法卡本回合不能发动。
function c20188127.initial_effect(c)
	-- 效果原文内容：从自己的墓地里选择1张装备魔法卡加入手卡。这张装备魔法卡本回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20188127.target)
	e1:SetOperation(c20188127.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组，筛选出可加入手牌的装备魔法卡
function c20188127.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果作用：选择1张装备魔法卡加入手牌
function c20188127.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20188127.tgfilter(chkc) end
	-- 判断是否满足发动条件，检查自己墓地是否存在装备魔法卡
	if chk==0 then return Duel.IsExistingTarget(c20188127.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示“请选择要加入手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从自己墓地选择1张装备魔法卡作为目标
	local sg=Duel.SelectTarget(tp,c20188127.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选择的装备魔法卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果作用：将装备魔法卡加入手牌并使其本回合不能发动
function c20188127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标卡
		Duel.ConfirmCards(1-tp,tc)
		-- 效果原文内容：这张装备魔法卡本回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
