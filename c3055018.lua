--灰滅の都 オブシディム
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己回合内，对方场上的特殊召唤的表侧表示怪兽变成炎族。
-- ②：自己结束阶段，以自己墓地1张「灰灭之都 奥布西地暮」为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
-- ③：场地区域的这张卡被破坏的场合或者被除外的场合才能发动。从卡组把1只「灰灭」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地卡通用的发动效果、种族变更效果、结束阶段效果和破坏/除外时的特殊召唤效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己回合内，对方场上的特殊召唤的表侧表示怪兽变成炎族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.ratg)
	e2:SetValue(RACE_PYRO)
	c:RegisterEffect(e2)
	-- ②：自己结束阶段，以自己墓地1张「灰灭之都 奥布西地暮」为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
	-- ③：场地区域的这张卡被破坏的场合或者被除外的场合才能发动。从卡组把1只「灰灭」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetDescription(1152)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e5)
end
-- 种族变更效果的目标过滤函数，仅对当前回合玩家的特殊召唤怪兽生效
function s.ratg(e,c)
	-- 当前回合玩家为发动者且目标怪兽为特殊召唤
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 结束阶段效果的发动条件函数，仅在自己回合结束时可发动
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为发动者
	return Duel.GetTurnPlayer()==tp
end
-- 墓地返回卡组效果的目标过滤函数，筛选自身卡号且可返回卡组的卡
function s.tdfilter(c)
	return c:IsCode(id) and c:IsAbleToDeck()
end
-- 结束阶段效果的目标选择函数，检查是否有满足条件的墓地卡并确认玩家可抽卡
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查是否有满足条件的墓地卡并确认玩家可抽卡
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的墓地卡作为目标
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 结束阶段效果的处理函数，将目标卡返回卡组最底端并抽1张卡
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且已返回卡组最底端且卡组有卡
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 让发动者抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 破坏/除外时特殊召唤效果的发动条件函数，仅在该卡从场地区域被破坏或除外时发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_FZONE)
end
-- 特殊召唤效果的目标过滤函数，筛选「灰灭」卡且可特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择函数，检查是否有满足条件的卡且场上空间足够
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否有满足条件的卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的处理函数，从卡组选择1只「灰灭」怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡组卡作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将目标卡特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 洗切发动者的卡组
		Duel.ShuffleDeck(tp)
	end
end
