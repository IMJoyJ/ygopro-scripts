--Ga－P.U.N.K.ワゴン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付600基本分才能发动。从卡组把1张「朋克」魔法卡加入手卡。
-- ②：自己场上的「朋克」怪兽成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。自己抽1张。
function c50642380.initial_effect(c)
	-- ①：支付600基本分才能发动。从卡组把1张「朋克」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50642380,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50642380)
	e1:SetCost(c50642380.thcost)
	e1:SetTarget(c50642380.thtg)
	e1:SetOperation(c50642380.thop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「朋克」怪兽成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50642380,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50642381)
	e2:SetCondition(c50642380.drcon1)
	e2:SetTarget(c50642380.drtg)
	e2:SetOperation(c50642380.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_BECOME_TARGET)
	e3:SetCondition(c50642380.drcon2)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价函数：先检查玩家能否支付600基本分，若可以则在实际发动时扣除600LP。
function c50642380.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定阶段（chk=0）检查玩家tp能否支付600基本分，不能则①效果无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 实际扣除玩家tp的600基本分，作为发动①效果的代价。
	Duel.PayLPCost(tp,600)
end
-- 定义①效果的检索过滤条件：从卡组中筛选出卡名含有「朋克」、是魔法卡并且能够加入手卡的卡。
function c50642380.thfilter(c)
	return c:IsSetCard(0x171) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 定义①效果的发动目标阶段：确认卡组存在至少1张符合条件的「朋克」魔法卡，并声明本次操作是把1张卡加入手卡的检索效果。
function c50642380.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段检查卡组中是否存在至少1张满足thfilter条件的「朋克」魔法卡，作为发动①效果的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c50642380.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：本次效果属于回手牌/检索分类，将把持有者为tp的卡组中的1张卡加入手卡（此时具体卡片未确定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义①效果处理：由玩家从卡组选择1张符合条件的「朋克」魔法卡加入手卡，并给对方确认。
function c50642380.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择卡片提示，让玩家选择要加入手卡的「朋克」魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中筛选并选择1张符合条件的「朋克」魔法卡。
	local g=Duel.SelectMatchingCard(tp,c50642380.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义②效果在攻击对象时的发动条件：被选择为攻击对象的怪兽是自己场上的「朋克」怪兽。
function c50642380.drcon1(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	return bc:IsSetCard(0x171) and bc:IsControler(tp)
end
-- 定义②效果在成为效果对象时的判定过滤器：需为自己场上表侧表示且位于怪兽区域的「朋克」怪兽。
function c50642380.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x171)
end
-- 定义②效果在成为效果对象时的发动条件：对方发动效果，且自己场上的「朋克」怪兽成为那个效果的对象。
function c50642380.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c50642380.cfilter,1,nil,tp)
end
-- 定义②效果的目标阶段：确认自己可以抽1张卡；设置抽卡玩家为自己、抽卡张数为1，并声明抽卡分类信息。
function c50642380.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定阶段检查玩家tp是否允许抽1张卡，若不能则②效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁效果的对象玩家设为自己（tp），后续抽卡由该玩家执行。
	Duel.SetTargetPlayer(tp)
	-- 设置本次效果的对象参数为1，表示抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 设置连锁操作信息：本次效果为抽卡效果，将由玩家tp抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果处理：从当前连锁信息中取出对象玩家和抽卡参数，然后执行对应的抽卡操作。
function c50642380.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取对象玩家p和对象参数d，即抽卡的执行者和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
