--“罪宝狩りの悪魔”
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽加入手卡。
-- ②：自己主要阶段把墓地的这张卡除外，以「“罪宝狩猎之恶魔”」以外的自己的墓地·除外状态的1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化函数，注册该卡片的①和②效果
function s.initial_effect(c)
	-- ①：从自己的卡组·墓地把1只「迪亚贝尔斯塔尔」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段把墓地的这张卡除外，以「“罪宝狩猎之恶魔”」以外的自己的墓地·除外状态的1张「罪宝」魔法·陷阱卡为对象才能发动。那张卡回到卡组最下面。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果的发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组或墓地中可加入手卡的「迪亚贝尔斯塔尔」怪兽
function s.filter(c)
	return c:IsSetCard(0x119b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动准备与合法性检测
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1只满足条件的「迪亚贝尔斯塔尔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理信息为：将1张卡从卡组或墓地加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果的处理函数：从卡组或墓地将1只「迪亚贝尔斯塔尔」怪兽加入手卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1张满足过滤条件且不受王家长眠之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己墓地或除外状态的、除「“罪宝狩猎之恶魔”」以外的、可回到卡组的「罪宝」魔法·陷阱卡
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x19e) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToDeck()
		and not c:IsCode(id)
end
-- ②效果的发动准备与合法性检测
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.cfilter(chkc) end
	-- 检查自己墓地或除外状态是否存在至少1张符合条件的「罪宝」魔陷作为对象
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
		-- 并且检查当前玩家是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张符合条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息为：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置效果处理信息为：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的处理函数：将对象卡回到卡组最下面，并抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象卡
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果相关，并将其送回持有者卡组最下面
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理，使后续的抽卡处理与回卡组不视为同时进行
		Duel.BreakEffect()
		-- 玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
