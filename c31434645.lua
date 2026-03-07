--呪われしエルドランド
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不用不死族怪兽不能攻击宣言。
-- ②：支付800基本分才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡加入手卡。
-- ③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡送去墓地。
function c31434645.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不用不死族怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c31434645.tglimit)
	c:RegisterEffect(e2)
	-- ②：支付800基本分才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31434645,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,31434645)
	e3:SetCost(c31434645.cost)
	e3:SetTarget(c31434645.target)
	e3:SetOperation(c31434645.operation)
	c:RegisterEffect(e3)
	-- ③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(31434645,1))
	e4:SetCategory(CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,31434646)
	e4:SetCondition(c31434645.tgcon)
	e4:SetTarget(c31434645.tgtg)
	e4:SetOperation(c31434645.tgop)
	c:RegisterEffect(e4)
end
-- 效果作用：使非不死族怪兽不能攻击宣言
function c31434645.tglimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- 效果作用：支付800基本分
function c31434645.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则检查：支付800基本分是否足够
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 规则执行：支付800基本分
	Duel.PayLPCost(tp,800)
end
-- 效果作用：检索满足条件的「黄金国巫妖」怪兽或「黄金乡」魔法·陷阱卡
function c31434645.filter(c)
	return (c:IsSetCard(0x1142) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 效果作用：设置连锁操作信息为检索卡组并加入手牌
function c31434645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则检查：卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31434645.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择并加入手牌
function c31434645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c31434645.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方手牌
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果作用：判断此卡是否从魔法与陷阱区域送去墓地
function c31434645.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 效果作用：检索满足条件的「黄金国巫妖」怪兽或「黄金乡」魔法·陷阱卡
function c31434645.tgfilter(c)
	return (c:IsSetCard(0x1142) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToGrave()
end
-- 效果作用：设置连锁操作信息为检索卡组并送去墓地
function c31434645.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则检查：卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c31434645.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：将卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：选择并送去墓地
function c31434645.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c31434645.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
