--巳剣之尊 麁正
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把「巳剑之尊 麁正」以外的1只「巳剑」怪兽加入手卡。
-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
local s,id,o=GetID()
-- 创建并注册多个效果，分别对应①②效果的触发条件和处理方式
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把「巳剑之尊 麁正」以外的1只「巳剑」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e3)
	-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
-- 定义检索过滤条件：满足「巳剑」属性、怪兽类型、可加入手牌且非自身
function s.thfilter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 设置检索效果的发动条件：检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件：卡组中存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息：准备将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作：选择并加入手牌，确认对方查看
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义代替破坏的过滤条件：场上表侧表示的爬虫类族怪兽因战斗或效果被破坏
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_REPTILE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 设置代替破坏效果的发动条件：检查是否有满足条件的怪兽被破坏且自身可被解放
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp)
		and c:IsReleasableByEffect() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置代替破坏效果的值：返回满足条件的卡
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果的操作：解放自身
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动代替破坏效果的卡号
	Duel.Hint(HINT_CARD,0,id)
	-- 以效果原因解放自身
	Duel.Release(e:GetHandler(),REASON_EFFECT)
end
