--ヴェルズ・ケルキオン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把自己墓地1只「入魔」怪兽除外，以自己墓地1只「入魔」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡的①的效果适用的回合的主要阶段才能发动。把1只「入魔」怪兽召唤。
-- ③：这张卡被送去墓地的回合，「入魔」怪兽召唤的场合需要的解放可以减少1只。
function c4756629.initial_effect(c)
	-- ①：把自己墓地1只「入魔」怪兽除外，以自己墓地1只「入魔」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(4756629,0))  --"选择自己墓地1只名字带有「入魔」的怪兽加入手卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4756629)
	e1:SetCost(c4756629.thcost)
	e1:SetTarget(c4756629.thtg)
	e1:SetOperation(c4756629.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的回合的主要阶段才能发动。把1只「入魔」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4756629,1))  --"把1只名字带有「入魔」的怪兽召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c4756629.sumcon)
	e2:SetTarget(c4756629.sumtg)
	e2:SetOperation(c4756629.sumop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合，「入魔」怪兽召唤的场合需要的解放可以减少1只。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c4756629.decop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断是否满足除外条件（名字带有「入魔」的怪兽且能除外，并且自己墓地存在可加入手卡的「入魔」怪兽）
function c4756629.rmfilter(c,tp)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在满足filter条件的「入魔」怪兽
		and Duel.IsExistingTarget(c4756629.filter,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤函数，用于判断是否满足加入手卡条件（名字带有「入魔」的怪兽且能加入手卡）
function c4756629.filter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的费用支付处理，选择1只满足条件的「入魔」怪兽除外作为代价
function c4756629.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足除外条件的「入魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4756629.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足除外条件的「入魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c4756629.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的卡以除外形式移出游戏
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果目标，选择1只满足条件的「入魔」怪兽作为效果对象
function c4756629.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c4756629.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「入魔」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4756629.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息，指定效果将使目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数，将目标怪兽加入手牌并确认对方可见
function c4756629.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认该怪兽已加入手牌
		Duel.ConfirmCards(1-tp,tc)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:RegisterFlagEffect(4756629,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判断是否满足②效果发动条件（即①效果已适用）
function c4756629.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(4756629)~=0
end
-- 过滤函数，用于判断是否满足召唤条件（名字带有「入魔」且可通常召唤）
function c4756629.sumfilter(c)
	return c:IsSetCard(0xa) and c:IsSummonable(true,nil)
end
-- 设置召唤效果的目标，检查是否有满足条件的「入魔」怪兽
function c4756629.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足召唤条件的「入魔」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4756629.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁操作信息，指定效果将召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理函数，选择并召唤1只满足条件的「入魔」怪兽
function c4756629.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足召唤条件的「入魔」怪兽
	local g=Duel.SelectMatchingCard(tp,c4756629.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 执行召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 当此卡被送去墓地时触发的效果处理，注册减少召唤所需解放数的效果
function c4756629.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否已注册过该效果（防止重复注册）
	if Duel.GetFlagEffect(tp,4756630)~=0 then return end
	-- 注册一个使「入魔」怪兽召唤时减少1点召唤所需解放数的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(c4756629.rfilter)
	e1:SetCondition(c4756629.econ)
	e1:SetCountLimit(1)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果e1注册到玩家tp的场上
	Duel.RegisterEffect(e1,tp)
	-- 注册一个标记效果，用于触发条件判断
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FLAG_EFFECT+4756631)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	-- 为玩家tp注册标识效果，防止重复触发
	Duel.RegisterFlagEffect(tp,4756630,RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足减少召唤所需解放数的触发条件
function c4756629.econ(e)
	-- 检查玩家是否已注册过标记效果4756631
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),4756631)~=0
end
-- 过滤函数，用于判断是否为「入魔」怪兽
function c4756629.rfilter(e,c)
	return c:IsSetCard(0xa)
end
