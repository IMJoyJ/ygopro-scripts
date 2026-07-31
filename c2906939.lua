--艮神鬼門 三千世界
local s,id,o=GetID()
-- 创建场地卡的发动效果和起动效果，使场地卡可以被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 起动效果：支付1点魔法计数器，选择场上1张以上里侧表示的卡送去墓地，从卡组检索相同数量的「艮神」怪兽加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 诱发效果：当对方把魔陷放置到场上时，可以选择场上1张卡返回手牌
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SSET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_MSET)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_CHANGE_POS)
	e5:SetCondition(s.thcon2)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	e6:SetCondition(s.thcon2)
	c:RegisterEffect(e6)
end
-- 过滤函数：判断是否为「艮神」且非场地卡且可以加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1e4) and not c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 过滤函数：判断是否为里侧表示且可以送去墓地
function s.tgfilter(c)
	return c:IsFacedown() and c:IsAbleToGrave()
end
-- 效果处理的条件判断函数：检索满足条件的卡组卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(tp) and s.tgfilter(chkc) end
	-- 判断是否满足发动条件：场上有里侧表示的卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上满足条件的目标卡
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,ct,nil)
	-- 设置操作信息：将目标卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：将检索到的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,g:GetCount(),tp,LOCATION_DECK)
end
-- 效果处理函数：执行起动效果的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组卡片
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 获取与连锁相关的里侧表示卡
	local sg=Duel.GetTargetsRelateToChain():Filter(Card.IsFacedown,nil)
	local sct=sg:GetCount()
	if sct>0 and g:GetClassCount(Card.GetCode)>=sct then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从满足条件的卡中选择指定数量的卡
		local tg=g:SelectSubGroup(tp,aux.dncheck,false,sct,sct)
		if tg:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tg)
			if tg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
				-- 将选中的里侧表示卡送去墓地
				Duel.SendtoGrave(sg,REASON_EFFECT)
			end
		end
	end
end
-- 过滤函数：判断是否为表侧表示且为「艮神」的怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1e4)
end
-- 诱发效果的发动条件：场上存在「艮神」表侧表示怪兽，且场上有里侧表示的卡
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在「艮神」表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 判断场上是否存在里侧表示的卡
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
end
-- 诱发效果的发动条件：场上存在「艮神」表侧表示怪兽，且场上有里侧表示的卡，且本次连锁对象中有里侧表示的卡
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在「艮神」表侧表示怪兽
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,eg)
		-- 判断场上是否存在里侧表示的卡
		and Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_ONFIELD,0,1,eg)
		and eg:IsExists(Card.IsFacedown,1,nil)
end
-- 诱发效果的目标选择函数：选择场上1张可以返回手牌的卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 判断是否满足发动条件：场上有可以返回手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上满足条件的目标卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将目标卡返回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 诱发效果的操作函数：执行返回手牌的效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsOnField() then
		-- 将目标卡返回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
