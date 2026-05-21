--虚竜魔王アモルファクターP
-- 效果：
-- 「无形阵·假面」降临。
-- ①：这张卡仪式召唤成功的场合，下次的对方回合的主要阶段1跳过。
-- ②：只要这张卡在怪兽区域存在，场上的表侧表示的融合·同调·超量怪兽的效果无效化。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「虚龙魔王 无形矢·心灵」以外的1只「龙魔王」怪兽加入手卡。
function c98287529.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：这张卡仪式召唤成功的场合，下次的对方回合的主要阶段1跳过。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c98287529.skipcon)
	e1:SetOperation(c98287529.skipop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，场上的表侧表示的融合·同调·超量怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetTarget(c98287529.distg)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把「虚龙魔王 无形矢·心灵」以外的1只「龙魔王」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c98287529.condition)
	e3:SetTarget(c98287529.target)
	e3:SetOperation(c98287529.operation)
	c:RegisterEffect(e3)
end
-- 检查此卡是否是通过仪式召唤特殊召唤成功的
function c98287529.skipcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
-- 仪式召唤成功时，注册一个跳过下次对方回合主要阶段1的全局效果
function c98287529.skipop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡仪式召唤成功的场合，下次的对方回合的主要阶段1跳过。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCode(EFFECT_SKIP_M1)
	-- 判断当前是否是对方回合（即在对方回合仪式召唤成功）
	if Duel.GetTurnPlayer()==1-tp then
		-- 将当前回合数记录在效果的Label中，用于后续判断
		e1:SetLabel(Duel.GetTurnCount())
		e1:SetCondition(c98287529.turncon)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	end
	-- 将跳过主要阶段1的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 定义跳过效果的生效条件，确保不在仪式召唤成功的当前回合生效
function c98287529.turncon(e)
	-- 检查当前回合数是否不等于记录的回合数，确保在下次对方回合才生效
	return Duel.GetTurnCount()~=e:GetLabel()
end
-- 过滤场上的融合、同调、超量怪兽
function c98287529.distg(e,c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 检查此卡是否是从场上送去墓地
function c98287529.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中除「虚龙魔王 无形矢·心灵」以外的「龙魔王」怪兽
function c98287529.filter(c)
	return c:IsSetCard(0xda) and not c:IsCode(98287529) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在符合条件的卡并设置操作信息
function c98287529.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「龙魔王」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c98287529.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组选择1只符合条件的「龙魔王」怪兽加入手牌并给对方确认
function c98287529.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张符合条件的「龙魔王」怪兽
	local g=Duel.SelectMatchingCard(tp,c98287529.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
