--メルフィーのかくれんぼ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的兽族怪兽在1回合各有1次不会被效果破坏。
-- ②：以自己墓地3只兽族怪兽为对象才能发动（同名卡最多1张）。那些怪兽回到卡组。那之后，自己抽1张。
function c63644830.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己场上的兽族怪兽在1回合各有1次不会被效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c63644830.indtg)
	e2:SetValue(c63644830.indct)
	c:RegisterEffect(e2)
	-- ②：以自己墓地3只兽族怪兽为对象才能发动（同名卡最多1张）。那些怪兽回到卡组。那之后，自己抽1张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(63644830,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,63644830)
	e3:SetTarget(c63644830.drtg)
	e3:SetOperation(c63644830.drop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的兽族怪兽
function c63644830.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 抗性次数判定：如果是因效果破坏，则提供1次免于破坏的次数
function c63644830.indct(e,re,r,rp)
	if bit.band(r,REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 过滤条件：墓地的兽族怪兽且可以回到卡组
function c63644830.tdfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToDeck()
end
-- 效果②的发动准备与合法性检测（包含抽卡检测、墓地不同名兽族怪兽数量检测）
function c63644830.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有可以作为效果对象的兽族怪兽
	local g=Duel.GetMatchingGroup(c63644830.tdfilter,tp,LOCATION_GRAVE,0,nil):Filter(Card.IsCanBeEffectTarget,nil,e)
	if chkc then return false end
	-- 在发动准备阶段，检测玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and g:GetClassCount(Card.GetCode)>=3 end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从符合条件的卡片中选择3张卡名不同的卡
	local tg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 将选择的卡片设置为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置连锁的操作信息：将这3张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,3,0,0)
	-- 设置连锁的操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的效果处理：将对象怪兽回到卡组，洗牌并抽1张卡
function c63644830.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象卡片送回持有者的卡组
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取上一步实际操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果实际操作的卡片中有卡片回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组不视为同时进行（造成错时点）
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
