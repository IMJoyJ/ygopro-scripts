--ネオフレムベル・ヘッジホッグ
-- 效果：
-- 这张卡被战斗破坏的场合，选择对方墓地存在的1张卡从游戏中除外。场上存在的这张卡被卡的效果破坏的场合，选择自己墓地存在的「新炎狱刺猬」以外的1只守备力200以下的炎属性怪兽加入手卡。
function c2377034.initial_effect(c)
	-- 效果原文：这张卡被战斗破坏的场合，选择对方墓地存在的1张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2377034,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetTarget(c2377034.rmtg)
	e1:SetOperation(c2377034.rmop)
	c:RegisterEffect(e1)
	-- 效果原文：场上存在的这张卡被卡的效果破坏的场合，选择自己墓地存在的「新炎狱刺猬」以外的1只守备力200以下的炎属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2377034,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c2377034.thcon)
	e2:SetTarget(c2377034.thtg)
	e2:SetOperation(c2377034.thop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的对方墓地卡片组用于除外。
function c2377034.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 向玩家提示“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的对方墓地卡片。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 设置本次连锁操作信息为除外效果。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),1-tp,LOCATION_GRAVE)
end
-- 处理除外效果的执行操作。
function c2377034.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片以正面表示形式从游戏中除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 判断该卡是否因效果破坏离场。
function c2377034.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(e:GetHandler():GetReason(),0x41)==0x41
end
-- 定义过滤函数，筛选守备力200以下的炎属性怪兽且非自身。
function c2377034.filter(c)
	local def=c:GetDefense()
	return def>=0 and def<=200 and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(2377034) and c:IsAbleToHand()
end
-- 检索满足条件的己方墓地卡片组用于加入手牌。
function c2377034.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c2377034.filter(chkc) end
	if chk==0 then return true end
	-- 向玩家提示“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的己方墓地卡片。
	local g=Duel.SelectTarget(tp,c2377034.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁操作信息为加入手牌效果。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 处理加入手牌效果的执行操作。
function c2377034.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁选择的目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标卡片送入玩家手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
