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
-- 定义除外代价的筛选：该「入魔」怪兽可从墓地除外，且墓地另有「入魔」怪兽能成为①效果的对象（排除自身）。
function c4756629.rmfilter(c,tp)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 确认除外该卡后，墓地仍有1只其他「入魔」怪兽可作为①效果加入手卡的对象。
		and Duel.IsExistingTarget(c4756629.filter,tp,LOCATION_GRAVE,0,1,c)
end
-- 定义①效果对象的筛选：自己墓地的「入魔」怪兽且能够加入手卡。
function c4756629.filter(c)
	return c:IsSetCard(0xa) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的代价：从自己墓地选择1只「入魔」怪兽除外（需墓地另有可取对象），使效果可以发动。
function c4756629.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：确认自己墓地存在可除外的「入魔」怪兽，且墓地另有可加入手卡的「入魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c4756629.rmfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只满足 rmfilter 的「入魔」怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c4756629.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 将选择的怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标选择：从自己墓地选择1只「入魔」怪兽作为对象；若为发动时则选择目标，若为连锁判定则验证对象合法性。
function c4756629.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c4756629.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己墓地选择1只「入魔」怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4756629.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：此效果将把1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果处理：将对象怪兽加入持有者手牌并给对方确认；若本卡仍在场上且与效果关联，则给自己本卡标记（记录①已适用，供②使用）。
function c4756629.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象怪兽加入其持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方确认加入手牌的那张怪兽卡。
		Duel.ConfirmCards(1-tp,tc)
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		c:RegisterFlagEffect(4756629,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end
-- ②效果的发动条件：这张卡已经适用过①效果（存在标记4756629）。
function c4756629.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(4756629)~=0
end
-- ②效果中可召唤的怪兽筛选：手牌或场上的「入魔」怪兽，且当前能进行通常召唤（无视次数限制）。
function c4756629.sumfilter(c)
	return c:IsSetCard(0xa) and c:IsSummonable(true,nil)
end
-- ②效果发动时确认存在可通常召唤的「入魔」怪兽，并设置操作信息。
function c4756629.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 存在性检查：自己手牌/场上是否有可通常召唤的「入魔」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c4756629.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息：此效果将进行1只怪兽的召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- ②效果处理：选择1只「入魔」怪兽进行通常召唤，不消耗通常召唤次数。
function c4756629.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌/场上选择1只满足条件的「入魔」怪兽来进行通常召唤。
	local g=Duel.SelectMatchingCard(tp,c4756629.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽进行通常召唤，ignore_count=true 表示不占用通常召唤次数。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- ③效果处理：这张卡被送去墓地时，若本回合未适用过该效果，则给己方设置“入魔怪兽召唤所需解放减少1只”的持续效果，并记录标记防止重复处理。
function c4756629.decop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查己方是否已有③效果适用过的标记（4756630），若有则不再重复处理。
	if Duel.GetFlagEffect(tp,4756630)~=0 then return end
	-- ③：这张卡被送去墓地的回合，「入魔」怪兽召唤的场合需要的解放可以减少1只。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e1:SetTarget(c4756629.rfilter)
	e1:SetCondition(c4756629.econ)
	e1:SetCountLimit(1)
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将减少祭品的效果注册到玩家场上，使其在该回合生效。
	Duel.RegisterEffect(e1,tp)
	-- ③：这张卡被送去墓地的回合，「入魔」怪兽召唤的场合需要的解放可以减少1只。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FLAG_EFFECT+4756631)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
	-- 给玩家注册本回合③效果已适用过的标记（4756630），防止同回合重复触发。
	Duel.RegisterFlagEffect(tp,4756630,RESET_PHASE+PHASE_END,0,1)
end
-- ③效果中减少祭品效果的条件：己方存在标记4756631（即满足“这张卡被送去墓地的回合”的条件）。
function c4756629.econ(e)
	-- 检查玩家是否存在标记4756631，确认本回合满足条件。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),4756631)~=0
end
-- 减少祭品效果适用的对象：卡名含有「入魔」的怪兽。
function c4756629.rfilter(e,c)
	return c:IsSetCard(0xa)
end
