--ギアギアギア XG
-- 效果：
-- 3星怪兽×3
-- 自己场上的机械族怪兽进行战斗的战斗步骤时，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的卡的效果直到那次伤害步骤结束时无效，直到那次伤害步骤结束时对方不能把魔法·陷阱·效果怪兽的效果发动。此外，这张卡从场上离开时，可以从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡加入手卡。
function c19891310.initial_effect(c)
	-- 为这张卡设定XYZ召唤手续：以3只3星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,3,3)
	c:EnableReviveLimit()
	-- 自己场上的机械族怪兽进行战斗的战斗步骤时，把这张卡1个超量素材取除才能发动。对方场上表侧表示存在的卡的效果直到那次伤害步骤结束时无效，直到那次伤害步骤结束时对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19891310,0))  --"效果无效"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_BATTLE_PHASE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c19891310.condition)
	e1:SetCost(c19891310.cost)
	e1:SetOperation(c19891310.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡从场上离开时，可以从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19891310,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c19891310.thcon)
	e2:SetTarget(c19891310.thtg)
	e2:SetOperation(c19891310.thop)
	c:RegisterEffect(e2)
end
-- 发动条件判定：当前战斗步骤中，自己场上的机械族怪兽是攻击怪兽或攻击对象时，满足条件。
function c19891310.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local bt=Duel.GetAttacker()
	if bt and bt:IsControler(tp) then return bt:IsRace(RACE_MACHINE) end
	-- 获取当前战斗的攻击对象怪兽。
	bt=Duel.GetAttackTarget()
	return bt and bt:IsControler(tp) and bt:IsRace(RACE_MACHINE)
end
-- 代价判定与支付：确认自己场上这张卡有1个超量素材可去除；发动时去除这张卡1个超量素材作为代价。
function c19891310.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 处理第一个效果：无效对方场上表侧表示的卡的效果；直到伤害步骤结束前，对方不能发动魔法·陷阱·效果怪兽的效果。
function c19891310.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上表侧表示存在的卡的效果直到那次伤害步骤结束时无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetTargetRange(0,LOCATION_ONFIELD)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将无效对方场上表侧表示卡效果的领域效果e1注册到当前玩家，效果持续到伤害步骤结束。
	Duel.RegisterEffect(e1,tp)
	-- 直到那次伤害步骤结束时对方不能把魔法·陷阱·效果怪兽的效果发动。此外，这张卡从场上离开时，可以从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡加入手卡。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c19891310.aclimit)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 将禁止对方发动魔法·陷阱·效果怪兽效果的领域效果e2注册到当前玩家，效果持续到伤害步骤结束。
	Duel.RegisterEffect(e2,tp)
end
-- 禁止发动的判定：被尝试发动的效果若是魔法·陷阱卡的发动或怪兽效果，则禁止其发动。
function c19891310.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)
end
-- 离场检索效果的发动条件：这张卡以表侧表示状态从场上离开。
function c19891310.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤条件：卡片是名字带有「齿轮齿轮」的卡，且可以加入手卡。
function c19891310.thfilter(c)
	return c:IsSetCard(0x72) and c:IsAbleToHand()
end
-- 离场检索效果的发动目标选择：从自己墓地选择这张卡以外的1张名字带有「齿轮齿轮」的卡作为对象，并设置回手牌操作信息。
function c19891310.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19891310.thfilter(chkc) and chkc~=e:GetHandler() end
	-- 效果发动时确认：自己墓地是否存在至少1张这张卡以外的名字带有「齿轮齿轮」且能加入手卡的卡。
	if chk==0 then return Duel.IsExistingTarget(c19891310.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向当前玩家显示选择提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让当前玩家从自己墓地选择1张符合条件的「齿轮齿轮」卡，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,c19891310.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置操作信息：本次处理涉及将对象卡加入手牌（CATEGORY_TOHAND），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 离场检索效果的处理：将效果对象加入手牌，并让对手确认该卡。
function c19891310.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时当前连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对手确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end
