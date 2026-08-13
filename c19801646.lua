--伝説のフィッシャーマン二世
-- 效果：
-- ①：这张卡的卡名只要在场上·墓地存在当作「传说的渔人」使用。
-- ②：只要场上有「海」存在，场上的这张卡不受其他怪兽的效果影响。
-- ③：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组把1只水属性·7星怪兽加入手卡。
function c19801646.initial_effect(c)
	-- 记录这张卡上记载着卡名「海」的代码列表，用于后续相关判断。
	aux.AddCodeList(c,22702055)
	-- 使这张卡在场上·墓地时将卡名视为「传说的渔人」使用。
	aux.EnableChangeCode(c,3643300,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：只要场上有「海」存在，场上的这张卡不受其他怪兽的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19801646.econ)
	e2:SetValue(c19801646.efilter)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡因对方的效果从场上离开的场合或者被战斗破坏的场合才能发动。从卡组把1只水属性·7星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19801646,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c19801646.thcon)
	e3:SetTarget(c19801646.thtg)
	e3:SetOperation(c19801646.thop)
	c:RegisterEffect(e3)
end
-- 免疫过滤器：只有对方怪兽（效果来源卡持有者与此卡持有者不同）且为怪兽效果时，免疫该效果。
function c19801646.efilter(e,te)
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwner()~=e:GetOwner()
end
-- 效果条件：检查场上是否存在「海」（每回合持续判定）。
function c19801646.econ(e)
	-- 检查当前场上生效的环境是否为「海」。
	return Duel.IsEnvironment(22702055)
end
-- 触发条件：这张卡因战斗破坏离场，或因对方玩家的效果离场，且离场前是表侧表示。
function c19801646.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)))
		and c:IsPreviousPosition(POS_FACEUP)
end
-- 检索过滤器：从卡组中筛选出1只水属性·7星且可以加入手卡的怪兽。
function c19801646.thfilter(c)
	return c:IsLevel(7) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 发动目标的判定与操作信息设置：确认卡组中存在符合条件的怪兽，并将本次操作登记为从卡组检索加入手卡。
function c19801646.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查卡组中是否存在1张满足水属性·7星且能加入手卡的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19801646.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把卡组的1只怪兽加入手牌，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1只水属性·7星怪兽加入手牌，并让对手确认。
function c19801646.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己的卡组中选择1张满足条件的水属性·7星怪兽。
	local g=Duel.SelectMatchingCard(tp,c19801646.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
