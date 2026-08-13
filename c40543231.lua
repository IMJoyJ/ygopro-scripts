--巳剣之尊 麁正
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把「巳剑之尊 麁正」以外的1只「巳剑」怪兽加入手卡。
-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
local s,id,o=GetID()
-- 为卡片注册全部效果：①为可选的诱发效果，分为召唤成功、特殊召唤成功、被解放三个时点各1个效果（克隆e1），用于检索「巳剑」怪兽；②为代替破坏的持续效果，在自己场上的其他爬虫类族怪兽将被战斗/效果破坏时，可将此卡解放代替破坏，且②带有1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合才能发动。从卡组把「巳剑之尊 麁正」以外的1只「巳剑」怪兽加入手卡。
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
-- 定义检索的过滤条件：必须为「巳剑」怪兽（SetCard 0x1c3）、是怪兽卡、能够加入手卡，且卡名不能是「巳剑之尊 麁正」自身。
function s.thfilter(c)
	return c:IsSetCard(0x1c3) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果发动的目标函数：在发动时（chk==0）检查卡组中是否存在满足条件的「巳剑」怪兽；若存在则登记本次操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段，确认卡组中存在至少1张满足s.thfilter检索条件的「巳剑」怪兽，否则该效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理时将从卡组把1张卡加入手卡（CATEGORY_TOHAND），用于连锁中其他效果的判定；因具体卡片在效果处理时才选定，targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组挑选1只符合条件的「巳剑」怪兽加入手卡，并向对方展示加入手卡的卡片。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示‘请选择要加入手牌的卡’的提示，并写入选择消息缓存，供选择卡片时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从卡组中选择1张满足s.thfilter的「巳剑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「巳剑」怪兽加入其持有者的手卡（player=nil表示回到持有者手卡），移动原因记为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家（1-tp）展示被加入手卡的卡片，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义可被代替破坏的怪兽的过滤条件：表侧表示、属于tp控制、位于主要怪兽区、爬虫类族、破坏原因为战斗或效果，且不是由其他代替效果产生的破坏。
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_REPTILE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的触发判定：eg中存在满足s.repfilter且不是此卡自身的其他爬虫类族怪兽，同时此卡自身可被效果解放且尚未被预定破坏；条件满足后让玩家选择是否发动代替效果。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp)
		and c:IsReleasableByEffect() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 弹出是/否询问，让玩家决定是否将此卡解放以代替破坏；选择是则返回true并发动代替效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 作为EFFECT_DESTROY_REPLACE的Value判定函数，返回被破坏的怪兽是否满足代替条件，控制者取此卡的控制者（e:GetHandlerPlayer()）。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的实际处理：先播放此卡的效果发动动画，然后解放此卡，以代替预定被破坏的爬虫类族怪兽。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示「巳剑之尊 麁正」的卡片动画，用于宣告并提示正在发动代替破坏效果。
	Duel.Hint(HINT_CARD,0,id)
	-- 将效果持有者（此卡）解放，作为代替破坏的代价，实际执行解放动作。
	Duel.Release(e:GetHandler(),REASON_EFFECT)
end
