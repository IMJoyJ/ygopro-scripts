--氷結界に至る晶域
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：对方不能对应自己的「冰结界」怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
-- ②：从额外卡组有怪兽特殊召唤的场合才能发动。选自己场上1只「冰结界」怪兽回到手卡或卡组。那之后，可以让自己或对方的场上·墓地1张卡回到卡组最下面。
-- ③：自己结束阶段发动。从额外卡组把3只卡名不同的「冰结界」怪兽给对方观看或这张卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动、连锁限制、特殊召唤时的效果和结束阶段效果
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
	-- ②：从额外卡组有怪兽特殊召唤的场合才能发动。选自己场上1只「冰结界」怪兽回到手卡或卡组。那之后，可以让自己或对方的场上·墓地1张卡回到卡组最下面。
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
-- 连锁处理函数，当对方发动怪兽效果时，若该怪兽属于冰结界，则限制其连锁
function s.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if re:IsActiveType(TYPE_MONSTER) and rc:IsSetCard(0x2f) then
		-- 设置连锁限制条件，仅允许发动者自身连锁
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制函数，返回是否允许连锁
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤函数，检查是否为从额外卡组召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 判断是否为从额外卡组特殊召唤的怪兽
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤函数，检查是否为冰结界怪兽且处于表侧表示
function s.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
-- 设置效果目标，检查场上是否存在符合条件的冰结界怪兽
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在符合条件的冰结界怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 处理效果发动，选择目标怪兽并执行返回手牌或卡组的操作
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择场上符合条件的冰结界怪兽
	local tg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=tg:GetFirst()
	if not tc then return end
	local res=false
	-- 显示选中怪兽的动画效果
	Duel.HintSelection(tg)
	if tc:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) then
		-- 若为融合/同步/超量/连接怪兽，则将其送回卡组顶部
		if Duel.SendtoDeck(tc,nil,SEQ_DECKTOP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_EXTRA) then
			res=true
		end
	elseif tc:IsType(TYPE_TOKEN) then
		-- 若为衍生物，则将其送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	-- 若可送回手牌或卡组，则选择送回方式
	elseif tc:IsAbleToHand() and (not tc:IsAbleToDeck() or Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))==0) then  --"回到手卡/回到卡组"
		-- 若选择送回手牌，则将其送回手牌
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
			res=true
		end
	else
		-- 若选择送回卡组，则将其送回卡组底部
		if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK) then
			res=true
			-- 送回卡组底部后洗切卡组
			Duel.ShuffleDeck(tc:GetControler())
		end
	end
	-- 若已执行操作且场上或墓地存在可送回卡组的卡
	if res and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
		-- 询问是否再选择一张卡送回卡组
		and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否再选1张卡回到卡组？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 选择一张可送回卡组的卡
		local g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(Card.IsAbleToDeck),tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
		-- 显示选中卡的动画效果
		Duel.HintSelection(g2)
		-- 将选中卡送回卡组底部
		Duel.SendtoDeck(g2,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 结束阶段效果的触发条件，仅在自己回合时触发
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数，检查是否为冰结界怪兽且处于表侧表示
function s.sfilter(c)
	return c:IsSetCard(0x2f) and c:IsFaceup()
end
-- 设置结束阶段效果的目标，若额外卡组中冰结界怪兽不足3种则破坏此卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取额外卡组中所有冰结界怪兽
	local g1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_EXTRA,0,nil)
	-- 获取额外卡组中所有里侧表示的怪兽
	local g2=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)
	if (g1:GetClassCount(Card.GetCode)+#g2)<3 then
		-- 设置操作信息，若冰结界怪兽不足3种则破坏此卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
-- 处理结束阶段效果，若额外卡组中冰结界怪兽不少于3种则展示给对方，否则破坏此卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取额外卡组中所有冰结界怪兽
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,0x2f)
	-- 判断额外卡组中冰结界怪兽是否不少于3种且询问是否展示
	if g:GetClassCount(Card.GetCode)>=3 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then  --"是否把卡给对方观看？"
		-- 提示玩家选择要展示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择3张卡名不同的冰结界怪兽
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
		-- 向对方确认展示的卡
		Duel.ConfirmCards(1-tp,sg)
	-- 若不满足条件则破坏此卡
	else Duel.Destroy(c,REASON_EFFECT) end
end
