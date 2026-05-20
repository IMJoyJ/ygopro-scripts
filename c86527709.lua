--虫だけエリアー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这个回合没有召唤·反转召唤·特殊召唤的对方场上的表侧表示怪兽变成昆虫族。
-- ②：以自己的除外状态的3只昆虫族怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
-- ③：这张卡从手卡送去墓地的回合的结束阶段才能发动。这张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡片初始化效果，包括①效果（种族改变永续）、②效果（回收抽卡起动效果）、以及③效果的送墓诱发准备
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这个回合没有召唤·反转召唤·特殊召唤的对方场上的表侧表示怪兽变成昆虫族。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.racetg)
	e2:SetCode(EFFECT_CHANGE_RACE)
	e2:SetValue(RACE_INSECT)
	c:RegisterEffect(e2)
	-- ②：以自己的除外状态的3只昆虫族怪兽为对象才能发动。那些怪兽回到卡组。那之后，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回收"
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	-- ③：这张卡从手卡送去墓地的回合的结束阶段才能发动。这张卡在自己场上表侧表示放置。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(s.regcon)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
end
-- 筛选出本回合没有进行过召唤、反转召唤、特殊召唤的怪兽
function s.racetg(e,c)
	return not c:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 筛选自己除外状态的表侧表示昆虫族且能回到卡组的怪兽
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
-- ②效果的发动准备，检查是否能抽卡、是否存在3只符合条件的除外怪兽，并进行取对象和效果分类声明
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 在发动时，检查自身是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 在发动时，检查自己的除外状态是否存在至少3只符合条件的昆虫族怪兽
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己除外状态的3只昆虫族怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置连锁信息，声明该效果包含将选中的卡片送回卡组的处理
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁信息，声明该效果包含抽1张卡的处理
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理，将作为对象的怪兽洗回卡组，若成功洗回则抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将对象卡片送回持有者的卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果实际操作的卡片中有卡片回到了主卡组，则洗切该玩家的卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组处理不视为同时进行（防止错时点）
		Duel.BreakEffect()
		-- 让发动效果的玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 检查这张卡是否是从手卡送去墓地
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND)
end
-- 在结束阶段注册一个诱发效果，用于将这张卡在场上表侧表示放置
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ③：这张卡从手卡送去墓地的回合的结束阶段才能发动。这张卡在自己场上表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))  --"表侧表示放置"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id+o)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- ③效果的发动准备，检查魔法与陷阱区域是否有空位，并声明包含从墓地移开卡片的操作
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己的魔法与陷阱区域是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	-- 设置连锁信息，声明该效果包含将自身从墓地移开的处理
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③效果的处理，在魔法与陷阱区域有空位且不受王家之谷影响的情况下，将这张卡在自己场上表侧表示放置
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己的魔法与陷阱区域已无空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 检查这张卡是否仍与效果相关，且不受“王家长眠之谷”的影响
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己的魔法与陷阱区域表侧表示放置，并立刻适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
