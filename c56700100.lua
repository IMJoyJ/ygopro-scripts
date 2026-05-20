--ピュアリィ・マイフレンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付500基本分才能发动。从卡组把「我的纯爱妖精朋友」以外的3张「纯爱妖精」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
-- ②：自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合才能发动（伤害步骤也能发动）。从自己墓地选最多3张「纯爱妖精」速攻魔法卡加入手卡（同名卡最多1张）。
local s,id,o=GetID()
-- 初始化卡片效果，注册魔陷发动效果、①效果（起动效果）和②效果（场上怪兽离场诱发效果）
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：支付500基本分才能发动。从卡组把「我的纯爱妖精朋友」以外的3张「纯爱妖精」卡给对方观看，对方从那之中随机选1张。那1张加入自己手卡，剩余回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己场上的表侧表示的「纯爱妖精」超量怪兽因对方从场上离开的场合才能发动（伤害步骤也能发动）。从自己墓地选最多3张「纯爱妖精」速攻魔法卡加入手卡（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价（Cost）处理函数，检查并支付500基本分
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分作为发动代价
	Duel.PayLPCost(tp,500)
end
-- 过滤条件：卡组中「我的纯爱妖精朋友」以外的「纯爱妖精」卡
function s.thfilter(c)
	return c:IsSetCard(0x18c) and c:IsAbleToHand() and not c:IsCode(id)
end
-- ①效果的发动准备（Target）处理函数，检查卡组中是否存在至少3张满足条件的卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少3张「我的纯爱妖精朋友」以外的「纯爱妖精」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- ①效果的效果处理（Operation）函数，从卡组选3张给对方观看并随机选1张加入手卡，其余洗回卡组
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的「纯爱妖精」卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>=3 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选出的3张卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
		-- 将自己的卡组洗牌
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将随机选出的那1张卡加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的「纯爱妖精」超量怪兽因对方从场上离开（非因规则离场）
function s.thcfilter(c,tp)
	return c:IsSetCard(0x18c) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp and c:IsType(TYPE_XYZ)
		and not c:IsReason(REASON_RULE)
end
-- ②效果的发动条件，检查是否有符合条件的怪兽因对方从场上离开
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.thcfilter,1,nil,tp)
end
-- 过滤条件：墓地中的「纯爱妖精」速攻魔法卡
function s.thfilter2(c)
	return c:IsSetCard(0x18c) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target）处理函数，检查墓地中是否存在至少1张「纯爱妖精」速攻魔法卡，并设置回收的操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少1张「纯爱妖精」速攻魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将自己墓地的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的效果处理（Operation）函数，从自己墓地选择最多3张同名卡最多1张的「纯爱妖精」速攻魔法卡加入手卡
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取自己墓地中满足条件且不受「王家之谷」影响的「纯爱妖精」速攻魔法卡
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,nil)
	-- 让玩家从满足条件的卡中选择1到3张卡名互不相同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,3)
	-- 如果成功选择卡片，则将这些卡加入手卡
	if sg and Duel.SendtoHand(sg,nil,REASON_EFFECT)>0 then
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,sg)
	end
end
