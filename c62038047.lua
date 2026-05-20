--不知火の鍛師
-- 效果：
-- 「不知火的锻师」的①的效果1回合只能使用1次。
-- ①：场上的这张卡作为同调素材送去墓地的场合才能发动。从卡组把「不知火的锻师」以外的1张「不知火」卡加入手卡。
-- ②：这张卡被除外的场合才能发动。这个回合，自己的不死族怪兽不会被战斗破坏。
function c62038047.initial_effect(c)
	-- ①：场上的这张卡作为同调素材送去墓地的场合才能发动。从卡组把「不知火的锻师」以外的1张「不知火」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62038047,0))  --"加入手牌"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,62038047)
	e1:SetCondition(c62038047.thcon)
	e1:SetTarget(c62038047.thtg)
	e1:SetOperation(c62038047.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合才能发动。这个回合，自己的不死族怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62038047,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetOperation(c62038047.operation)
	c:RegisterEffect(e2)
end
-- 过滤卡组中除「不知火的锻师」以外的「不知火」卡片且能加入手牌的过滤条件
function c62038047.filter(c)
	return c:IsSetCard(0xd9) and not c:IsCode(62038047) and c:IsAbleToHand()
end
-- 判断此卡是否作为同调素材从场上送去墓地
function c62038047.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousLocation(LOCATION_ONFIELD) and r==REASON_SYNCHRO
end
-- ①效果的发动准备与合法性检测（检查卡组中是否存在符合条件的卡，并设置检索的操作信息）
function c62038047.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查己方卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c62038047.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理（从卡组选择1张「不知火」卡加入手牌并给对方确认）
function c62038047.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送“请选择要加入手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c62038047.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的效果处理（注册一个本回合内己方场上不死族怪兽不会被战斗破坏的全局效果）
function c62038047.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己的不死族怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c62038047.target)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 向全局环境注册该不会被战斗破坏的字段效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤受不会被战斗破坏效果影响的怪兽（必须是不死族怪兽）
function c62038047.target(e,c)
	return c:IsRace(RACE_ZOMBIE)
end
