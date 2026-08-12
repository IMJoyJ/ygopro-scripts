--セイクリッド・ソンブレス
-- 效果：
-- 「星圣·草帽星系」的①②③的效果1回合各能使用1次。
-- ①：把自己墓地1只「星圣」怪兽除外，以自己墓地1只「星圣」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡的①的效果适用的回合的主要阶段才能发动。把1只「星圣」怪兽召唤。
-- ③：这张卡被送去墓地的回合，「星圣」怪兽召唤的场合需要的解放可以减少1只。
function c78358521.initial_effect(c)
	-- ①：把自己墓地1只「星圣」怪兽除外，以自己墓地1只「星圣」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(78358521,0))  --"选择自己墓地1只名字带有「星圣」的怪兽加入手卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,78358521)
	e1:SetCost(c78358521.thcost)
	e1:SetTarget(c78358521.thtg)
	e1:SetOperation(c78358521.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果适用的回合的主要阶段才能发动。把1只「星圣」怪兽召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78358521,1))  --"把1只名字带有「星圣」的怪兽召唤"
	e2:SetCategory(CATEGORY_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c78358521.sumcon)
	e2:SetTarget(c78358521.sumtg)
	e2:SetOperation(c78358521.sumop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合，「星圣」怪兽召唤的场合需要的解放可以减少1只。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c78358521.decop)
	c:RegisterEffect(e3)
end
-- 过滤自己墓地中可作为发动代价除外的「星圣」怪兽，且墓地中还存在其他可作为效果对象的「星圣」怪兽
function c78358521.rmfilter(c,tp)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查除外当前卡片后，墓地中是否还存在至少1只可作为效果对象的「星圣」怪兽
		and Duel.IsExistingTarget(c78358521.filter,tp,LOCATION_GRAVE,0,1,c)
end
-- 过滤自己墓地中可以加入手牌的「星圣」怪兽
function c78358521.filter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的代价处理函数：将自己墓地1只「星圣」怪兽除外
function c78358521.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否能支付将墓地1只「星圣」怪兽除外的代价
	if chk==0 then return Duel.IsExistingMatchingCard(c78358521.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地1只满足条件的「星圣」怪兽作为代价
	local g=Duel.SelectMatchingCard(tp,c78358521.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选中的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果①的对象选择与操作信息设置函数
function c78358521.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c78358521.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己墓地1只「星圣」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c78358521.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理函数：将对象怪兽加入手牌，并为自身注册“①的效果适用”的标记
function c78358521.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:RegisterFlagEffect(78358521,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果②的发动条件：这张卡已适用过①的效果
function c78358521.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(78358521)~=0
end
-- 过滤手牌或场上可以进行通常召唤的「星圣」怪兽
function c78358521.sumfilter(c)
	return c:IsSetCard(0x53) and c:IsSummonable(true,nil)
end
-- 效果②的发动准备：检查是否存在可召唤的「星圣」怪兽，并设置召唤的操作信息
function c78358521.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手牌或场上是否存在可以进行通常召唤的「星圣」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c78358521.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果处理信息：进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果②的效果处理函数：选择1只「星圣」怪兽进行通常召唤
function c78358521.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择1只手牌或场上的「星圣」怪兽
	local g=Duel.SelectMatchingCard(tp,c78358521.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 忽略每回合通常召唤次数限制，将选中的怪兽进行通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果③的效果处理函数：注册减少解放数量的全局效果，并为墓地的这张卡注册标记以关联该效果
function c78358521.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查本回合是否已注册过该减少解放的效果，若有则不再重复注册
	if Duel.GetFlagEffect(tp,78358522)~=0 then return end
	-- ③：这张卡被送去墓地的回合，「星圣」怪兽召唤的场合需要的解放可以减少1只。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(c78358521.rfilter)
	e1:SetCondition(c78358521.econ)
	e1:SetCountLimit(1)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将减少解放数量的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- ③：这张卡被送去墓地的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FLAG_EFFECT+78358523)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	-- 为玩家注册本回合已适用过效果③的标记
	Duel.RegisterFlagEffect(tp,78358522,RESET_PHASE+PHASE_END,0,1)
end
-- 减少解放效果的适用条件判定函数
function c78358521.econ(e)
	-- 检查玩家是否具有墓地中该卡所赋予的标记，以确定是否适用减少解放的效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),78358523)~=0
end
-- 过滤需要减少解放数量的怪兽（「星圣」怪兽）
function c78358521.rfilter(e,c)
	return c:IsSetCard(0x53)
end
