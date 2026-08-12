--ドレミコード・プリモア
-- 效果：
-- ←0 【灵摆】 0→
-- ①：自己把怪兽灵摆召唤时，以自己的灵摆区域1张「七音服」卡为对象才能发动。那张卡回到手卡。
-- 【怪兽效果】
-- 这个卡名的①③的怪兽效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「七音服·普莉莫娅」以外的1张「七音服」卡加入手卡。
-- ②：只要自己的灵摆区域有灵摆刻度是奇数和偶数的「七音服」卡各存在，自己发动的「七音服」卡的效果不会被无效化。
-- ③：自己把「七音服」怪兽连接召唤的场合才能发动。从自己的额外卡组（表侧）·墓地把1张「七音服」卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册所有效果
function s.initial_effect(c)
	-- 为卡片添加灵摆属性，使其可以灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：自己把怪兽灵摆召唤时，以自己的灵摆区域1张「七音服」卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回到手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「七音服·普莉莫娅」以外的1张「七音服」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：只要自己的灵摆区域有灵摆刻度是奇数和偶数的「七音服」卡各存在，自己发动的「七音服」卡的效果不会被无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_DISEFFECT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.effcon)
	e4:SetValue(s.effectfilter)
	c:RegisterEffect(e4)
	-- ③：自己把「七音服」怪兽连接召唤的场合才能发动。从自己的额外卡组（表侧）·墓地把1张「七音服」卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"回收效果"
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetCondition(s.thcon3)
	e5:SetTarget(s.thtg3)
	e5:SetOperation(s.thop3)
	c:RegisterEffect(e5)
end
-- 过滤函数：判断是否为灵摆召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp)
end
-- 效果条件：判断是否有灵摆召唤的怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数：判断是否为「七音服」且可送回手牌的灵摆卡
function s.rthfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- 效果目标选择：选择灵摆区域的「七音服」卡作为目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.rthfilter(chkc) end
	-- 检查阶段：确认是否存在符合条件的灵摆卡
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示信息：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从灵摆区域选择一张符合条件的卡
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标卡送回手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标卡：获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将目标卡送回手牌：执行送回手牌的操作
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤函数：判断是否为「七音服」且可送回手牌的卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- 效果目标选择：从卡组选择一张「七音服」卡
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认卡组是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组检索并送回手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示信息：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡牌：从卡组选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将卡送回手牌：执行送回手牌的操作
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认卡牌：向对方玩家展示所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数：判断是否为「七音服」灵摆卡
function s.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 过滤函数：判断灵摆刻度是否为奇数或偶数
function s.chkfilter(c,odevity)
	return c:GetCurrentScale()%2==odevity
end
-- 条件函数：判断是否存在奇数和偶数刻度的灵摆卡
function s.chkcon(g)
	return g:IsExists(s.chkfilter,1,nil,1) and g:IsExists(s.chkfilter,1,nil,0)
end
-- 效果条件：判断是否满足灵摆刻度条件
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取灵摆区域的卡组
	local g=Duel.GetMatchingGroup(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,nil)
	return s.chkcon(g)
end
-- 效果过滤函数：判断是否为「七音服」卡的效果
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取连锁信息：获取触发效果和玩家信息
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(0x162)
end
-- 过滤函数：判断是否为「七音服」连接召唤的怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp) and c:IsSetCard(0x162)
end
-- 效果条件：判断是否有「七音服」连接召唤的怪兽
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- 过滤函数：判断是否为「七音服」且可送回手牌的卡
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- 效果目标选择：从额外卡组和墓地选择一张「七音服」卡
function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段：确认额外卡组和墓地是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- 效果处理：从额外卡组和墓地检索并送回手牌
function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	-- 提示信息：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡牌：从额外卡组和墓地选择一张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将卡送回手牌：执行送回手牌的操作
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认卡牌：向对方玩家展示所选卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
