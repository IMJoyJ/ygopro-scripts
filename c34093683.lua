--リヴェンデット・エグゼクター
-- 效果：
-- 「复仇死者」仪式魔法卡降临。这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡只要在怪兽区域存在，卡名当作「归魂复仇死者·屠魔侠」使用。
-- ②：只要仪式召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他卡作为效果的对象。
-- ③：仪式召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「复仇死者」卡加入手卡。
function c34093683.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册在怪兽区域时将卡名视为「归魂复仇死者·屠魔侠」（4388680）的永续效果，对应①的卡名当作效果。
	aux.EnableChangeCode(c,4388680)
	-- ②：只要仪式召唤的这张卡在怪兽区域存在，对方不能把自己场上的其他卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(c34093683.tgcon)
	e2:SetTarget(c34093683.tgtg)
	-- 设置“不能成为效果对象”的判定函数为aux.tgoval：只有对方发动的效果不能将这些受保护卡选为对象，自己发动的效果不受限制。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 这个卡名的③的效果1回合只能使用1次。③：仪式召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1张「复仇死者」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34093683,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,34093683)
	e3:SetCondition(c34093683.thcon)
	e3:SetTarget(c34093683.thtg)
	e3:SetOperation(c34093683.thop)
	c:RegisterEffect(e3)
end
-- 效果②的适用条件：这张卡必须是仪式召唤出场的（IsSummonType(SUMMON_TYPE_RITUAL)），即只有仪式召唤的这张卡在场时才给予场上其他卡保护。
function c34093683.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 效果②的保护对象筛选条件：排除这张卡自身以外的卡，即“自己场上的其他卡”才受保护。
function c34093683.tgtg(e,c)
	return c~=e:GetHandler()
end
-- 效果③的发动条件：这张卡是仪式召唤出场，破坏前位于怪兽区，且破坏原因属于战斗破坏或对方玩家的效果破坏（同时要求破坏前控制者为这张卡的持有者）。
function c34093683.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 检索过滤器：卡名含有「复仇死者」字段（0x106）且可以加入手卡的卡，用于③从卡组检索。
function c34093683.thfilter(c)
	return c:IsSetCard(0x106) and c:IsAbleToHand()
end
-- 效果③的发动目标检测：确认卡组存在符合条件的「复仇死者」卡，并设置本效果为检索并加入手卡的操作信息。
function c34093683.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检测（chk==0）：在自己卡组中检查是否存在至少1张满足检索条件的「复仇死者」卡，不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34093683.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：声明本次操作属于“加入手卡”和“检索”分类，预期从卡组将1张卡加入手卡，用于连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③处理：提示选择要加入手牌的卡，从卡组选出1张「复仇死者」卡加入手牌，并给对方确认。
function c34093683.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送选择提示消息，显示“请选择要加入手牌的卡”（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己卡组中选择1张满足条件的「复仇死者」卡（选择1张），结果存入g。
	local g=Duel.SelectMatchingCard(tp,c34093683.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者的手牌，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将刚加入手牌的卡展示给对方玩家确认（ConfirmCards）。
		Duel.ConfirmCards(1-tp,g)
	end
end
