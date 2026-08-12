--EM：Pグレニャード
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场上或者自己或对方的墓地有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡在手卡·墓地存在，自己场上的连接2怪兽被送去墓地的场合或者被表侧除外的场合，把这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括特殊召唤条件和返回手卡效果
function s.initial_effect(c)
	-- 注册卡片进入墓地时的监听效果，用于记录卡片是否已从场上送入墓地
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：场上或者自己或对方的墓地有连接怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡在手卡·墓地存在，自己场上的连接2怪兽被送去墓地的场合或者被表侧除外的场合，把这张卡除外，以对方场上1张卡为对象才能发动。那张卡回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+1)
	e2:SetLabelObject(e0)
	-- 支付将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件：场上存在连接怪兽且有空位
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上或墓地是否存在连接怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil,TYPE_LINK)
end
-- 过滤函数，用于筛选被送入墓地或除外的连接2怪兽
function s.cfilter(c,tp,se)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLink(2) and (se==nil or c:GetReasonEffect()~=se)
		and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup())) and c:IsPreviousControler(tp)
end
-- 判断是否满足返回手卡效果的发动条件：有符合条件的连接2怪兽被送入墓地或除外
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(s.cfilter,1,nil,tp,se)
end
-- 设置返回手卡效果的目标选择逻辑
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查是否有满足条件的对方场上卡片可以返回手牌
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择目标卡片
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，指定将目标卡片送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行返回手卡效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
