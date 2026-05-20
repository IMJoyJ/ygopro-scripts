--真竜凰の使徒
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：以自己墓地3张「真龙」卡为对象才能发动。那些卡回到卡组。那之后，自己抽1张。
-- ②：自己主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
function c75425320.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己墓地3张「真龙」卡为对象才能发动。那些卡回到卡组。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75425320,0))  --"回收并抽卡"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,75425320)
	e2:SetTarget(c75425320.drtg)
	e2:SetOperation(c75425320.drop)
	c:RegisterEffect(e2)
	-- ②：自己主要阶段才能发动。表侧表示进行1只「真龙」怪兽的上级召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(75425320,1))  --"上级召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,75425321)
	e3:SetTarget(c75425320.sumtg)
	e3:SetOperation(c75425320.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合，以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75425320,2))  --"魔法·陷阱卡破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,75425322)
	e4:SetCondition(c75425320.descon)
	e4:SetTarget(c75425320.destg)
	e4:SetOperation(c75425320.desop)
	c:RegisterEffect(e4)
end
-- 过滤条件：墓地的「真龙」卡且能回到卡组
function c75425320.tdfilter(c)
	return c:IsSetCard(0xf9) and c:IsAbleToDeck()
end
-- 效果①（回收并抽卡）的发动准备与目标选择
function c75425320.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c75425320.tdfilter(chkc) end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地是否存在至少3张满足条件的「真龙」卡
		and Duel.IsExistingTarget(c75425320.tdfilter,tp,LOCATION_GRAVE,0,3,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择提示信息为：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地3张「真龙」卡作为效果对象
	local g=Duel.SelectTarget(tp,c75425320.tdfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	-- 设置操作信息：将选中的卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：自己抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①（回收并抽卡）的效果处理
function c75425320.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取仍与效果关联的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象卡片送回持有者卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 若有卡片确实回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤条件：手牌中的「真龙」怪兽且可以进行上级召唤
function c75425320.sumfilter(c)
	return c:IsSetCard(0xf9) and c:IsSummonable(true,nil,1)
end
-- 效果②（上级召唤）的发动准备
function c75425320.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可以上级召唤的「真龙」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c75425320.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：进行1次召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②（上级召唤）的效果处理
function c75425320.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 设置选择提示信息为：请选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择手牌中1只满足条件的「真龙」怪兽
	local g=Duel.SelectMatchingCard(tp,c75425320.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 进行该怪兽的上级召唤（忽略每回合通常召唤次数限制，至少使用1个祭品）
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 效果③的发动条件：这张卡从魔法与陷阱区域送去墓地
function c75425320.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 效果③（破坏魔陷）的发动准备与目标选择
function c75425320.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	-- 检查场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	-- 设置选择提示信息为：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP)
	-- 设置操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③（破坏魔陷）的效果处理
function c75425320.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
