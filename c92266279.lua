--潤いの風
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：支付1000基本分才能发动。从卡组把1只「芳香」怪兽加入手卡。
-- ②：自己基本分比对方少的场合才能发动。自己回复500基本分。
function c92266279.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。①：支付1000基本分才能发动。从卡组把1只「芳香」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92266279,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,92266279)
	e2:SetCost(c92266279.thcost)
	e2:SetTarget(c92266279.thtg)
	e2:SetOperation(c92266279.thop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己基本分比对方少的场合才能发动。自己回复500基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92266279,2))  --"LP回复"
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCountLimit(1,92266280)
	e3:SetCondition(c92266279.reccon)
	e3:SetTarget(c92266279.rectg)
	e3:SetOperation(c92266279.recop)
	c:RegisterEffect(e3)
end
-- ①效果的发动代价（Cost）函数：支付1000基本分
function c92266279.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能够支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除1000基本分作为发动的代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤条件：卡组中属于「芳香」系列的怪兽，且能加入手卡
function c92266279.thfilter(c)
	return c:IsSetCard(0xc9) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动检测与效果分类（Target）函数
function c92266279.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足条件的「芳香」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92266279.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理（Operation）函数：从卡组检索「芳香」怪兽
function c92266279.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只满足条件的「芳香」怪兽
	local g=Duel.SelectMatchingCard(tp,c92266279.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件（Condition）函数
function c92266279.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的基本分是否比对方少
	return Duel.GetLP(tp)<Duel.GetLP(1-tp)
end
-- ②效果的发动检测与效果分类（Target）函数
function c92266279.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置回复基本分的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置回复基本分的数值为500
	Duel.SetTargetParam(500)
	-- 设置连锁信息，表示该效果包含回复自己500基本分的操作
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ②效果的处理（Operation）函数：回复基本分
function c92266279.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行回复基本分的操作
	Duel.Recover(p,d,REASON_EFFECT)
end
