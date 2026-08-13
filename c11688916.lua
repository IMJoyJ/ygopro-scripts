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
-- 注册该卡的全部效果：灵摆区效果（怪兽灵摆召唤时回手自身灵摆区的七音服卡）、怪兽①检索效果（召唤/特殊召唤各1次）、②七音服效果免疫无效、③连接召唤后从额外表侧·墓地回收七音服卡。
function s.initial_effect(c)
	-- 为该卡附加灵摆怪兽属性，使其具备灵摆召唤、灵摆卡发动等基础功能。
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
-- 判断怪兽是否由tp玩家进行的灵摆召唤，用于筛选特殊召唤成功的怪兽。
function s.cfilter(c,tp)
	return c:IsSummonType(SUMMON_TYPE_PENDULUM) and c:IsSummonPlayer(tp)
end
-- 灵摆效果的发动条件：本次特殊召唤成功的怪兽中存在由tp玩家灵摆召唤的怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 选择对象的过滤条件：自己灵摆区域的表侧表示「七音服」卡，且能够加入手卡。
function s.rthfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- 灵摆效果发动时的取对象处理：指定自己灵摆区域1张符合条件的「七音服」卡为对象，并设置回手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and chkc:IsControler(tp) and s.rthfilter(chkc) end
	-- 检查是否存在合法对象：自己灵摆区域是否有至少1张满足条件的「七音服」卡，没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_PZONE,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择1张自己灵摆区域符合条件的「七音服」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_PZONE,0,1,1,nil)
	-- 设置操作信息：将对象卡回手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果处理：取得对象卡，若仍与当前连锁相关则将其送回持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将对象卡以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 检索过滤条件：卡名不是「七音服·普莉莫娅」，属于「七音服」系列且能加入手卡的卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- 怪兽①的发动目标检查：卡组存在符合条件的「七音服」卡，并设置操作信息为从卡组加入手卡。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足检索条件的「七音服」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（检索）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽①效果处理：从卡组选择1张符合条件的「七音服」卡加入手卡，并让对方确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张符合条件的「七音服」卡（不取对象）。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：表侧表示、属于「七音服」系列且原种类包含灵摆怪兽。
function s.scfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x162) and c:GetOriginalType()&TYPE_PENDULUM~=0
end
-- 判断卡的当前灵摆刻度是否为指定奇偶性（odevity=1为奇数，0为偶数）。
function s.chkfilter(c,odevity)
	return c:GetCurrentScale()%2==odevity
end
-- 检查组中是否同时存在灵摆刻度为奇数和偶数的「七音服」卡。
function s.chkcon(g)
	return g:IsExists(s.chkfilter,1,nil,1) and g:IsExists(s.chkfilter,1,nil,0)
end
-- ②效果的条件：自己灵摆区域同时存在刻度为奇数和偶数的「七音服」卡。
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己灵摆区域中所有满足条件的「七音服」卡。
	local g=Duel.GetMatchingGroup(s.scfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,nil)
	return s.chkcon(g)
end
-- ②效果的值函数：若当前连锁的效果由自己发动且其持有者为「七音服」卡，则保护该效果不被无效化。
function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	-- 获取当前连锁的效果和发动玩家，用于判断该效果是否是自己发动的「七音服」卡的效果。
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:GetHandler():IsSetCard(0x162)
end
-- 判断怪兽是否为由tp玩家进行的表侧表示「七音服」怪兽的连接召唤。
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp) and c:IsSetCard(0x162)
end
-- ③效果的发动条件：本次特殊召唤成功的怪兽中存在由tp玩家进行的「七音服」怪兽连接召唤。
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter2,1,nil,tp)
end
-- 回收过滤条件：表侧表示的「七音服」卡且能加入手卡。
function s.thfilter2(c)
	return c:IsFaceupEx() and c:IsSetCard(0x162) and c:IsAbleToHand()
end
-- ③效果的目标检查：自己的额外卡组表侧或墓地存在符合条件的「七音服」卡，并设置操作信息为回手卡。
function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组表侧或墓地是否存在符合条件的「七音服」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从额外卡组表侧或墓地加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE)
end
-- ③效果处理：从额外卡组表侧或墓地选择1张符合条件的「七音服」卡加入手卡（墓地选择需受王家长眠之谷影响），并让对方确认。
function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的额外卡组表侧或墓地选择1张符合条件的「七音服」卡，过滤时应用王家长眠之谷的限制。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入持有者手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
