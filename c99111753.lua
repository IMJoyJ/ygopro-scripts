--セキュリティ・ドラゴン
-- 效果：
-- 怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：只在这张卡在场上表侧表示存在才有1次，这张卡是互相连接状态的场合以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c99111753.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只怪兽作为连接素材，素材无其他限制。
	aux.AddLinkProcedure(c,nil,2,2)
	-- 这个卡名的效果1回合只能使用1次。①：只在这张卡在场上表侧表示存在才有1次，这张卡是互相连接状态的场合以对方场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99111753,0))  --"回到持有者手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,99111753)
	e1:SetCondition(c99111753.thcon)
	e1:SetTarget(c99111753.thtg)
	e1:SetOperation(c99111753.thop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡处于互相连接状态（存在相互连接的怪兽）。
function c99111753.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetMutualLinkedGroupCount()>0
end
-- 效果发动时，从对方场上选择1只可回手的怪兽作为对象，设置回手牌操作信息，并给此卡记录已发动过效果的标记。
function c99111753.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 效果发动合法性检查：对方场上是否存在1只能够被效果返回手牌的怪兽，存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择提示，提示文字为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从对方场上选择1只可回手的怪兽，作为本效果的取对象目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_MZONE,1,1,nil)
	-- 将选中的对象设置为本连锁的回手牌处理对象，更新操作信息为回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(99111753,1))  --"已发动过效果"
end
-- 效果处理：取得对象怪兽，若该怪兽仍与此效果关联，则将其返回持有者手牌。
function c99111753.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽（连锁对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽送回其持有者手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
