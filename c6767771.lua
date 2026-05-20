--壱世壊を劈く弦声
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上有怪兽召唤·特殊召唤的场合，若自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在则能发动。从自己卡组上面把3张卡送去墓地。这个回合，对方场上的怪兽的攻击力下降500。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「珠泪哀歌族」陷阱卡加入手卡。
function c6767771.initial_effect(c)
	-- 注册卡片记有「维萨斯-斯塔弗罗斯特」卡名的信息
	aux.AddCodeList(c,56099748)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上有怪兽召唤·特殊召唤的场合，若自己场上有「珠泪哀歌族」怪兽或者「维萨斯-斯塔弗罗斯特」存在则能发动。从自己卡组上面把3张卡送去墓地。这个回合，对方场上的怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCountLimit(1,6767771)
	e2:SetCondition(c6767771.discon)
	e2:SetTarget(c6767771.distg)
	e2:SetOperation(c6767771.disop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「珠泪哀歌族」陷阱卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,6767772)
	e4:SetCondition(c6767771.thcon)
	e4:SetTarget(c6767771.thtg)
	e4:SetOperation(c6767771.thop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」
function c6767771.disfilter(c)
	return ((c:IsSetCard(0x181) and c:IsLocation(LOCATION_MZONE)) or c:IsCode(56099748)) and c:IsFaceup()
end
-- 定义①号效果的发动条件
function c6767771.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「珠泪哀歌族」怪兽或「维萨斯-斯塔弗罗斯特」
	return Duel.IsExistingMatchingCard(c6767771.disfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 定义①号效果的发动准备
function c6767771.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能将卡组顶部的3张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,3) end
	-- 设置当前连锁的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为3
	Duel.SetTargetParam(3)
	-- 设置操作信息为“将卡组顶部的3张卡送去墓地”
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,3)
end
-- 定义①号效果的效果处理
function c6767771.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和送去墓地的卡片数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 将自己卡组顶部的3张卡送去墓地
	Duel.DiscardDeck(p,d,REASON_EFFECT)
	-- 这个回合，对方场上的怪兽的攻击力下降500。②：这张卡被效果送去墓地的场合才能发动。从卡组把1张「珠泪哀歌族」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册使对方场上怪兽攻击力下降500的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义②号效果的发动条件：这张卡因效果被送去墓地
function c6767771.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤卡组中的「珠泪哀歌族」陷阱卡
function c6767771.thfilter(c)
	return c:IsSetCard(0x181) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 定义②号效果的发动准备
function c6767771.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手卡的「珠泪哀歌族」陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6767771.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义②号效果的效果处理
function c6767771.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「珠泪哀歌族」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c6767771.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
