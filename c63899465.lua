--R－ACEヘッドクオーター
-- 效果：
-- ①：只要对方场上有怪兽存在，自己场上的「救援ACE队」怪兽的攻击力·守备力上升500。
-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「救援ACE队」怪兽召唤。
-- ③：1回合1次，以自己的墓地·除外状态的4张「救援ACE队」卡为对象才能发动。那些卡回到卡组。那之后，自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果：①攻守上升、②追加召唤、③回收抽卡
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：只要对方场上有怪兽存在，自己场上的「救援ACE队」怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_FZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.condition)
	-- 过滤受攻击力上升效果影响的卡，限定为「救援ACE队」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x18b))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「救援ACE队」怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"使用「救援ACE队总部」的效果召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 过滤可以进行追加召唤的怪兽，限定为「救援ACE队」怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x18b))
	c:RegisterEffect(e3)
	-- ③：1回合1次，以自己的墓地·除外状态的4张「救援ACE队」卡为对象才能发动。那些卡回到卡组。那之后，自己抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.drtg)
	e4:SetOperation(s.drop)
	c:RegisterEffect(e4)
end
-- 攻击力·守备力上升效果的适用条件：对方场上有怪兽存在
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	-- 检查对方场上怪兽区域的卡片数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤可以作为回收对象的卡：自己墓地或表侧除外的「救援ACE队」卡，且可以回到卡组
function s.tdfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToDeck()
		and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
-- 效果③的发动准备与目标选择（Target函数）
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.tdfilter(chkc) end
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查自己墓地及除外区是否存在4张满足条件的「救援ACE队」卡作为对象
		and Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,nil) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择4张墓地或除外状态的「救援ACE队」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,4,4,nil)
	-- 设置连锁操作信息：将选中的卡片送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置连锁操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果③的效果处理（Operation函数）
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与该效果相关的对象卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg==0 then return end
	-- 将对象卡片送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果有卡片实际回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断效果处理，使后续的抽卡处理与回卡组处理不视为同时进行
		Duel.BreakEffect()
		-- 玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
