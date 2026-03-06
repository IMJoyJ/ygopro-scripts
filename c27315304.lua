--ミスト・ウォーム
-- 效果：
-- 调整＋调整以外的怪兽2只以上
-- ①：这张卡同调召唤成功的场合，以对方场上最多3张卡为对象发动。那些对方的卡回到持有者手卡。
function c27315304.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和2只调整以外的怪兽参与同调
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合，以对方场上最多3张卡为对象发动。那些对方的卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27315304,0))  --"返回手牌"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c27315304.thcon)
	e1:SetTarget(c27315304.thtg)
	e1:SetOperation(c27315304.thop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：此卡必须是同调召唤成功
function c27315304.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果的对象选择函数，选择对方场上1~3张可送入手牌的卡
function c27315304.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 向玩家提示选择对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1~3张可送入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,3,nil)
	-- 设置连锁的操作信息，指定效果将把对象卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理函数，将符合条件的卡送入手牌
function c27315304.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中已选择的对象卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将符合条件的卡以效果原因送入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
