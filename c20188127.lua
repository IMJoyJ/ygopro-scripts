--泉の精霊
-- 效果：
-- 从自己的墓地里选择1张装备魔法卡加入手卡。这张装备魔法卡本回合不能发动。
function c20188127.initial_effect(c)
	-- 从自己的墓地里选择1张装备魔法卡加入手卡。这张装备魔法卡本回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c20188127.target)
	e1:SetOperation(c20188127.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选函数：用于判断一张卡是否为装备魔法卡，且该卡能够被加入手卡。
function c20188127.tgfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果的目标设定函数：在发动时检查墓地是否存在符合条件的装备魔法卡，若存在则让玩家选择其中1张作为对象，并登记回手牌的操作信息。
function c20188127.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c20188127.tgfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在至少1张满足条件的装备魔法卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c20188127.tgfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的装备魔法卡，并将其登记为该效果的对象。
	local sg=Duel.SelectTarget(tp,c20188127.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将“回手牌”的操作信息写入当前连锁，指定对象为已选卡片，数量为其张数，供其他卡/效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,sg:GetCount(),0,0)
end
-- 效果处理函数：将对象卡加入手卡、展示给对手，并对其附加本回合不能发动效果的封印。
function c20188127.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象装备魔法卡送去其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,tc)
		-- 这张装备魔法卡本回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
