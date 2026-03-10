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
-- 支付600基本分的检查
function c50642380.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 支付600基本分的执行
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600基本分
	Duel.PayLPCost(tp,600)
end
-- 检索满足条件的「朋克」魔法卡过滤器
function c50642380.thfilter(c)
	return c:IsSetCard(0x171) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 设置效果处理信息，确定要从卡组检索的卡片数量和位置
function c50642380.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(c50642380.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息，指定将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的效果
function c50642380.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c50642380.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否为己方场上的「朋克」怪兽被选为攻击对象
function c50642380.drcon1(e,tp,eg,ep,ev,re,r,rp)
	local bc=eg:GetFirst()
	return bc:IsSetCard(0x171) and bc:IsControler(tp)
end
-- 判断己方场上是否有「朋克」怪兽的过滤器
function c50642380.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x171)
end
-- 判断是否为己方场上的「朋克」怪兽成为对方效果的对象
function c50642380.drcon2(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c50642380.cfilter,1,nil,tp)
end
-- 设置抽卡效果处理信息
function c50642380.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置效果处理信息，指定将要抽卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c50642380.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 根据目标玩家和抽卡数量进行抽卡
	Duel.Draw(p,d,REASON_EFFECT)
end
