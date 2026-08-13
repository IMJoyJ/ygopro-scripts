--氷結界に至る晶域
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能对应自己的「冰结界」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：从额外卡组有怪兽特殊召唤的场合才能发动。选自己场上1只「冰结界」怪兽回到手卡或卡组。那之后，可以让自己或对方的场上·墓地1张卡回到卡组最下面。
-- ③：自己结束阶段发动。从额外卡组把3只卡名不同的「冰结界」怪兽给对方观看或这张卡破坏。
local s,id,o=GetID()
-- 初始化效果注册：e0为魔法卡发动本身的空效果；e1为持续监视连锁的效果，用于实现①封锁对方对应；e2为②的诱发效果，在额外卡组怪兽特殊召唤成功时触发，选自己场上1只冰结界怪兽回手或回卡组并可选追加；e3为③的结束阶段必发效果，展示额外3只不同名冰结界怪兽或破坏自身。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：对方不能对应自己的「冰结界」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.chainop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从额外卡组有怪兽特殊召唤的场合才能发动。选自己场上1只「冰结界」怪兽回到手卡或卡组。那之后，可以让自己或对方的场上·墓地1张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回到卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tdcon)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
	-- ③：自己结束阶段发动。从额外卡组把3只卡名不同的「冰结界」怪兽给对方观看或这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"维持这张卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 当任意效果发动进入连锁时，若该效果是怪兽效果且其发动者操控的怪兽持有「冰结界」字段，则为本连锁设置限制，使对方不能对应此类效果的发动而发动魔法·陷阱·怪兽效果。
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x2f) then
		-- 设定当前连锁的连锁限制条件为s.chainlm，即只允许特定玩家进行连锁。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制条件：仅当尝试连锁的玩家与原效果发动者为同一人时允许连锁，从而让对方不能对应自己的「冰结界」怪兽效果的发动来发动卡牌效果。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：判断一只怪兽的特殊召唤位置是否为额外卡组，即是否是从额外卡组特殊召唤的怪兽。
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ②的触发条件：本次特殊召唤成功的怪兽集合中存在至少1只从额外卡组特殊召唤的怪兽。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 选择条件：自己场上表侧表示、持有「冰结界」字段，且能够回到手卡或卡组的怪兽（用于②的返回对象）。
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
-- ②的发动目标条件：在发动时检查自己场上是否存在至少1只满足s.thfilter的「冰结界」怪兽，以此决定能否发动。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若存在至少1只表侧表示且可回手/回卡组的「冰结界」怪兽，则②满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②的效果处理：先选择自己场上1只「冰结界」怪兽，将其返回手卡或卡组（额外怪兽返回额外卡组、衍生物送去手卡等）；若成功移动，则可以选择双方场上或墓地1张卡返回持有者卡组最下面。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时选择自己场上1只满足s.thfilter的「冰结界」怪兽，该选择在处理时进行，不是发动时取对象。
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	local res=false
	-- 手动展示被选中的怪兽并记录其为该连锁的对象，用于动画和对象关联判定。
	Duel.HintSelection(tg)
	if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		-- 若选中融合/同调/XYZ/连接怪兽，则将其返回额外卡组最顶端；返回成功且该卡现在位于额外卡组时，标记本次移动成功。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
			res=true
		end
	elseif tc:IsType(TYPE_TOKEN) then
		-- 若选中衍生物，则将其直接送去手卡（衍生物实际无法进入手卡，处理中会因离场而消灭）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 否则，当该怪兽可以回到手卡，且（不能回卡组或玩家选择“回到手卡”选项）时，选择回手卡处理。
	elseif tc:IsAbleToHand() and (not tc:IsAbleToDeck() or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then  --"回到手卡/回到卡组"
		-- 执行回手卡处理，若实际返回手卡成功且该卡位于手卡，则标记本次移动成功。
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			res=true
		end
	else
		-- 否则执行回卡组处理，将怪兽返回持有者卡组并洗切；若返回成功且位于卡组，则标记移动成功。
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
			res=true
			-- 由于卡组被插入/洗切，手动洗切该怪兽持有者的卡组，确保卡组顺序正确。
			Duel.ShuffleDeck(tc:GetControler())
		end
	end
	-- 在②的返回处理成功后，检查双方场上、墓地中是否存在不受王家长眠之谷影响且可以返回卡组的卡，以便进行后续追加处理。
	if res and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
		-- 询问当前玩家是否要追加“选双方场上或墓地1张卡回到卡组最下面”的处理。
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否再选1张卡回到卡组？"
		-- 中断当前效果，使后续的追加处理视为不同时进行，避免错误时点，同时可用于连锁的重新判定。
		Duel.BreakEffect()
		-- 双方场上、墓地中选择1张满足条件且不受王家长眠之谷影响的卡，作为追加返回卡组最下面的对象。
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		-- 手动展示选中的追加返回对象并记录其与该连锁的联系。
		Duel.HintSelection(g2)
		-- 将选中的追加卡返回其持有者卡组最下面，完成②的后半段效果。
		Duel.SendtoDeck(g2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- ③的发动条件：仅在己方回合的结束阶段时满足（该字段效果为必发，触发阶段条件）。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是本卡的控制者，即只有自己的结束阶段才发动③。
	return Duel.GetTurnPlayer()==tp
end
-- 用于③的附加计数：筛选额外卡组中表侧表示且持有「冰结界」字段的怪兽。
function s.sfilter(c)
	return c:IsSetCard(0x2f) and c:IsFaceup()
end
-- ③的发动时目标设定：若额外卡组中可展示的「冰结界」怪兽不足3种（表侧不同名数量+里侧卡数量之和小于3），则将“破坏这张卡”作为本效果的预定操作信息告知系统。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得额外卡组中表侧表示的「冰结界」怪兽集合，用于统计可展示的不同名数量。
	local g1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil)
	-- 取得额外卡组中所有里侧表示的卡，这些卡无法判断卡名，但作为无法展示的部分计入总数量。
	local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)
	if (g1:GetClassCount(Card.GetCode)+#g2)<3 then
		-- 当可展示的「冰结界」怪兽不足3种时，设置操作信息为破坏自身，以便「星尘龙」等能正确对应。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
-- ③的效果处理：先获取额外卡组所有「冰结界」怪兽，若存在至少3种不同卡名且玩家选择展示，则从中选择3张卡名不同的「冰结界」怪兽给对方确认；否则破坏这张卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取我方额外卡组中所有持有「冰结界」字段的怪兽（含表侧与可判定字段的卡）。
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,0x2f)
	-- 若额外卡组中不同卡名的「冰结界」怪兽数量达到3张或以上，并且玩家确认要进行展示，则进入选择展示的处理。
	if g:GetClassCount(Card.GetCode)>=3 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then  --"是否把卡给对方观看？"
		-- 给当前玩家发送“选择要给对方确认的卡”的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 从符合条件的「冰结界」怪兽中，利用aux.dncheck确保所选3张卡的卡名互不相同。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 将选中的3张卡给对方玩家确认，完成“给对方观看”的效果要求。
		Duel.ConfirmCards(1-tp,sg)
	-- 当无法展示3只不同名的「冰结界」怪兽或玩家选择不展示时，这张卡因效果被破坏。
	else Duel.Destroy(c,REASON_EFFECT) end
end
