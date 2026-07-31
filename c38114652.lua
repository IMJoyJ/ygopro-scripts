--封神の剣鬼 ミクマリ
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤条件、起动效果、诱发效果
function s.initial_effect(c)
	-- 特殊召唤效果：从手牌特殊召唤，条件为场上有里侧怪兽且能作为cost送入手牌或额外卡组，目标为选择的里侧怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 起动效果：检索满足条件的怪兽卡并加入手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 诱发效果：当作为同步素材时，可以将墓地一张陷阱卡盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件过滤函数：判断场上里侧怪兽是否能作为cost送入手牌或额外卡组且有可用怪兽区
function s.spcfilter(c,tp)
	return c:IsFacedown() and (c:IsAbleToHandAsCost() or c:IsAbleToExtraAsCost())
		-- 判断场上是否有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤条件函数：检查场上是否存在满足条件的怪兽
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足特殊召唤条件的怪兽
	return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_ONFIELD,0,1,nil,tp)
end
-- 特殊召唤目标选择函数：获取满足条件的怪兽并提示选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足特殊召唤条件的怪兽组
	local g=Duel.GetMatchingGroup(s.spcfilter,tp,LOCATION_ONFIELD,0,nil,tp)
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤执行函数：确认对方查看卡牌并将卡送入手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 确认对方查看卡牌
	Duel.ConfirmCards(1-tp,g)
	-- 将卡送入手牌，原因特殊召唤
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 检索效果过滤函数：判断是否为非龙族、神兽族、怪兽类型且可送入手牌的卡
function s.thfilter(c)
	return not c:IsRace(RACE_WYRM) and c:IsSetCard(0x1e4) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果目标选择函数：检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，指定将要处理的卡牌类别为回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果执行函数：提示玩家选择卡牌并送入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足检索条件的卡牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将卡送入手牌，原因效果
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看卡牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 诱发效果条件函数：判断卡片是否在墓地且因同步召唤成为素材且来源为神兽族卡
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
		and e:GetHandler():GetReasonCard():IsSetCard(0x1e4)
end
-- 盖放效果过滤函数：判断是否为陷阱卡且可盖放
function s.setfilter(c)
	return c:GetType()==TYPE_TRAP and c:IsSSetable()
end
-- 盖放效果目标选择函数：检查墓地是否存在满足条件的卡并提示选择
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.setfilter(chkc) end
	-- 检查墓地是否存在满足盖放条件的卡
	if chk==0 then return Duel.IsExistingTarget(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择满足盖放条件的卡牌
	local g=Duel.SelectTarget(tp,s.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，指定将要处理的卡牌类别为离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 诱发效果执行函数：获取目标卡并判断是否可盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否与当前连锁相关且不受王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将卡盖放
		Duel.SSet(tp,tc)
	end
end
