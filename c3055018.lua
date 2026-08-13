--灰滅の都 オブシディム
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己回合内，对方场上的特殊召唤的表侧表示怪兽变成炎族。
-- ②：自己结束阶段，以自己墓地1张「灰灭之都 奥布西地暮」为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
-- ③：场地区域的这张卡被破坏的场合或者被除外的场合才能发动。从卡组把1只「灰灭」怪兽特殊召唤。
local s,id,o=GetID()
-- s.initial_effect是卡片的初始效果注册入口：依次创建并注册e1（场地魔法卡发动）、e2（①效果：对方场上特殊召唤的表侧怪兽变为炎族）、e3（②效果：自己结束阶段取自己墓地1张同名卡回卡组底并抽1）、e4（③效果：这张卡在场地区被破坏时从卡组特召1只「灰灭」怪兽）及e5（e4的克隆，补充③中被除外时的触发），并通过SetCountLimit实现②③效果各1回合1次。
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
-- s.ratg是①效果的对象筛选函数：判断当前回合是这张卡的控制者的回合，且被检查的怪兽是特殊召唤的怪兽，用于将对方场上满足条件的怪兽变为炎族。
function s.ratg(e,c)
	-- 判定当前回合玩家与效果持有者相同（即自己回合），且该怪兽是通过特殊召唤出场的怪兽。
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer() and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- s.tdcon是②效果的发动条件函数：检查当前回合玩家是否为效果发动者，从而保证只在己方结束阶段满足发动时机。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是tp，保证是自己回合的结束阶段。
	return Duel.GetTurnPlayer()==tp
end
-- s.tdfilter是②效果的取对象过滤函数：对象卡必须是卡名为「灰灭之都 奥布西地暮」（本卡id）且能够回到卡组的卡。
function s.tdfilter(c)
	return c:IsCode(id) and c:IsAbleToDeck()
end
-- s.tdtg是②效果的发动时处理：确认墓地存在可取对象且自己可以抽卡，选择自己墓地1张同名卡作为对象，并登记回卡组和抽卡的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 在效果发动时（chk==0）检查条件：自己墓地存在至少1张满足s.tdfilter的卡，且自己可以抽卡，二者都满足才可发动。
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerCanDraw(tp) end
	-- 显示选择提示，让操作者选择要返回卡组的卡（HINTMSG_TODECK对应的提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1张同名卡作为本次效果的对象（取对象），并记录到当前连锁的对象中。
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作信息：将选择的对象g（1张卡）送回持有者卡组（CATEGORY_TODECK），供相关效果参考。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 登记本次操作信息：持有者tp将因效果抽1张卡（CATEGORY_DRAW），供相关效果参考。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- s.tdop是②效果的处理函数：取得目标卡，若仍与效果关联，则将其送回持有者卡组最下面；送回成功后中断时点，然后让自己抽1张卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的目标卡（墓地中的同名卡）。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡仍与效果关联，且成功将其以效果原因送回持有者卡组最下面；同时确认有卡确实进入了卡组（未因其他效果转移）才继续处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 and Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0 then
		-- 中断当前效果处理，使后续抽卡成为独立时点，符合『那之后』的时间顺序。
		Duel.BreakEffect()
		-- 让发动者tp因效果抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- s.spcon是③效果的发动条件函数：检查被破坏或被除外的这张卡在离场前处于场地区域，确保是『场地区域的这张卡』被破坏或除外。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_FZONE)
end
-- s.spfilter是③特殊召唤的筛选函数：从卡组选择卡名含「灰灭」字段（0x1ad）且可以被效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1ad) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- s.sptg是③效果的发动目标设定函数：发动时检查自己主要怪兽区有可用区域，且卡组中存在可特殊召唤的「灰灭」怪兽，并登记特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否还有至少1个可用区域，用于放置要特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查卡组中是否存在至少1只满足s.spfilter且可特殊召唤的「灰灭」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次操作信息：将把1只怪兽从卡组特殊召唤到tp场上（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- s.spop是③效果的处理函数：显示选择提示，从卡组选择1只符合条件的「灰灭」怪兽，以表侧表示特殊召唤到自己场上，然后洗切卡组。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，让操作者选择要特殊召唤的卡（HINTMSG_SPSUMMON对应的提示文字）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足s.spfilter的「灰灭」怪兽（本次是在效果处理时选择，因此不取对象）。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「灰灭」怪兽以表侧表示特殊召唤到发动者tp的怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		-- 特殊召唤后洗切卡组，使卡组顺序随机化。
		Duel.ShuffleDeck(tp)
	end
end
