--F.A.シティGP
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段以及战斗阶段内上升2星。
-- ②：自己场上的「方程式运动员」怪兽不会成为对方的效果的对象。
-- ③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员市街大奖赛」以外的1张「方程式运动员」卡加入手卡。
function c1061200.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，场上的「方程式运动员」怪兽的等级只在主要阶段以及战斗阶段内上升2星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_LEVEL)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 筛选双方主要怪兽区上的「方程式运动员」怪兽作为等级上升的适用对象。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	e2:SetValue(2)
	e2:SetCondition(c1061200.lvcon)
	c:RegisterEffect(e2)
	-- ②：自己场上的「方程式运动员」怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	-- 筛选自己场上的「方程式运动员」怪兽作为“不会成为效果对象”的适用对象。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x107))
	-- 设置不能成为效果对象的判定函数，使对方发动的效果不能选择这些「方程式运动员」怪兽。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的③的效果1回合只能使用1次；③：场上的表侧表示的这张卡被效果破坏的场合才能发动。从卡组把「方程式运动员市街大奖赛」以外的1张「方程式运动员」卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,1061200)
	e4:SetCondition(c1061200.thcon)
	e4:SetTarget(c1061200.thtg)
	e4:SetOperation(c1061200.thop)
	c:RegisterEffect(e4)
end
-- 等级上升效果的适用条件：当前阶段必须处于主要阶段1、主要阶段2或战斗阶段中。
function c1061200.lvcon(e)
	-- 取得当前游戏阶段，用于判断是否满足“只在主要阶段以及战斗阶段内”的适用条件。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- ③效果的发动条件：这张卡被效果破坏，且破坏前位于场上表侧表示。
function c1061200.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索过滤条件：是「方程式运动员」卡、不是「方程式运动员市街大奖赛」自身、并且可以加入手卡。
function c1061200.thfilter(c)
	return c:IsSetCard(0x107) and not c:IsCode(1061200) and c:IsAbleToHand()
end
-- ③效果发动时的目标处理：确认卡组存在可检索的「方程式运动员」卡，并登记检索加入手卡的操作信息。
function c1061200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若卡组没有符合条件的卡，则不能发动此效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c1061200.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记本次操作的信息为“从卡组将1张卡加入手卡”，供后续效果处理和相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组把1张符合条件的「方程式运动员」卡加入手卡，并展示给对手确认。
function c1061200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手卡的卡”的提示，引导玩家进行检索选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从卡组选择1张满足 thfilter 条件的「方程式运动员」卡（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c1061200.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对手玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
