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
	-- 这个卡名的②③的效果1回合各能使用1次。②：支付800基本分才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡加入手卡。
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
	-- 这个卡名的②③的效果1回合各能使用1次。③：这张卡从魔法与陷阱区域送去墓地的场合才能发动。从卡组把1只「黄金国巫妖」怪兽或1张「黄金乡」魔法·陷阱卡送去墓地。
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
-- ①效果的过滤条件：当攻击宣言的怪兽不是不死族时返回真，使该怪兽受到不能攻击宣言的限制，从而实现不用不死族怪兽不能攻击宣言。
function c31434645.tglimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
-- ②效果的发动代价函数：检查当前玩家能否支付800基本分，若能则实际支付800基本分作为代价。
function c31434645.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost检查阶段（chk==0）：确认当前玩家可以支付800基本分，否则不能发动。
	if chk==0 then return Duel.CheckLPCost(tp,800) end
	-- 实际支付800基本分作为效果发动的代价。
	Duel.PayLPCost(tp,800)
end
-- ②效果的检索过滤器：选择卡组中满足'黄金国巫妖'怪兽（0x1142且怪兽）或'黄金乡'魔法·陷阱卡（0x143且魔法/陷阱），且可以加入手卡的卡。
function c31434645.filter(c)
	return (c:IsSetCard(0x1142) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ②效果的发动目标：确认卡组存在符合过滤器的卡，并设置操作信息为将1张卡从卡组加入手卡。
function c31434645.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张满足filter的卡，存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31434645.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁处理涉及从卡组将1张卡加入手卡（CATEGORY_TOHAND），用于后续效果连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1张满足filter的卡加入手卡，并展示给对手确认。
function c31434645.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让当前玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 使用过滤函数从卡组选取1张满足条件的卡（由玩家选择）。
	local g=Duel.SelectMatchingCard(tp,c31434645.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入其持有者的手卡（nil表示由卡的原持有者获得），原因是效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡在从魔法与陷阱区域送去墓地时才能发动（通过IsPreviousLocation判断之前的所在区域）。
function c31434645.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- ③效果的送墓过滤器：选择卡组中满足'黄金国巫妖'怪兽或'黄金乡'魔法·陷阱卡，且可以被效果送去墓地的卡。
function c31434645.tgfilter(c)
	return (c:IsSetCard(0x1142) and c:IsType(TYPE_MONSTER) or c:IsSetCard(0x143) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToGrave()
end
-- ③效果的发动目标：确认卡组有符合tgfilter的卡，并设置操作信息为将1张卡从卡组送去墓地。
function c31434645.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中是否存在至少1张满足tgfilter的卡，存在才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31434645.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次连锁处理涉及从卡组将1张卡送去墓地（CATEGORY_TOGRAVE），用于后续效果连锁判断。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：玩家从卡组选择1张满足tgfilter的卡送去墓地。
function c31434645.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让当前玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 使用过滤函数从卡组选取1张满足条件的卡（由玩家选择）。
	local g=Duel.SelectMatchingCard(tp,c31434645.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡送去墓地，原因是效果（REASON_EFFECT）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
