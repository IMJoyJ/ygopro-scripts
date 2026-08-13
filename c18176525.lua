--巳剣之尊 佐士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把1张「巳剑」魔法·陷阱卡加入手卡。
-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
local s,id,o=GetID()
-- 初始化效果注册：为①效果创建召唤/特殊召唤/解放时触发的检索效果，为②效果创建代替破坏的永续效果，并设置各自1回合1次限制。
function s.initial_effect(c)
	-- 对应①效果：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把1张「巳剑」魔法·陷阱卡加入手卡。
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
	-- 对应②效果原文：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
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
-- 定义①效果的检索过滤器：筛选持有「巳剑」字段的魔法·陷阱卡且该卡能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动条件检查和操作信息登记：若卡组存在符合条件的「巳剑」魔法·陷阱卡则允许发动，并将“加入手卡”的操作信息登记为从卡组选1张。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时点检查自己卡组是否存在至少1张满足s.thfilter的「巳剑」魔法·陷阱卡，作为发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记效果处理时将执行的“加入手卡”操作信息，用于连锁判定等场合。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1张符合条件的「巳剑」魔法·陷阱卡加入手卡，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家弹出选择提示“请选择要加入手牌的卡”，用于检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选出1张满足s.thfilter的「巳剑」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果的适用对象过滤器：被破坏的卡须为表侧表示、自己场上、爬虫类族、位于怪兽区域，且破坏原因是战斗/效果，并非由代替破坏造成。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_REPTILE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②效果发动时点判定：存在将被战斗/效果破坏的其他爬虫类族怪兽，且这张卡可被效果解放、未被预定破坏。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp)
		and c:IsReleasableByEffect() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否将这张卡解放以代替其他爬虫类族怪兽被破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果的判定回调：确认实际被破坏的卡是否符合②的替代条件，返回true表示可用这张卡代替。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②效果处理：展示这张卡的动画，并将这张卡解放作为代替破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示这张卡的卡图动画，提示正在发动②效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 解放这张卡，代替其他爬虫类族怪兽被破坏。
	Duel.Release(e:GetHandler(),REASON_EFFECT)
end
