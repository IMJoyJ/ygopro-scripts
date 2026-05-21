--サイ・ガール
-- 效果：
-- 从游戏中除外的这张卡特殊召唤成功时，把自己卡组最上面的卡里侧表示从游戏中除外。这张卡从场上送去墓地时，这张卡的效果除外的自己的卡加入手卡。
function c99070951.initial_effect(c)
	-- 从游戏中除外的这张卡特殊召唤成功时，把自己卡组最上面的卡里侧表示从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99070951,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c99070951.rmcon)
	e1:SetTarget(c99070951.rmtg)
	e1:SetOperation(c99070951.rmop)
	c:RegisterEffect(e1)
	-- 这张卡从场上送去墓地时，这张卡的效果除外的自己的卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99070951,1))  --"加入手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c99070951.thcon)
	e2:SetTarget(c99070951.thtg)
	e2:SetOperation(c99070951.thop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断此卡是否是从除外区特殊召唤成功
function c99070951.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_REMOVED)
end
-- 除外效果的发动准备，设置除外卡组卡片的操作信息
function c99070951.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 除外效果的处理，将卡组最上方的卡里侧表示除外，并为相关卡片添加标记以建立关联
function c99070951.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if not tc or not tc:IsAbleToRemove() then return end
	-- 禁用接下来的洗牌检测，防止因从卡组除外卡片而导致系统自动洗牌
	Duel.DisableShuffleCheck()
	-- 将目标卡片以里侧表示因效果除外
	Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	tc:RegisterFlagEffect(99070951,RESET_EVENT+RESETS_STANDARD,0,1)
	if c:IsLocation(LOCATION_MZONE) then
		c:RegisterFlagEffect(99070951,RESET_EVENT+0x680000,0,1)
	end
	e:SetLabelObject(tc)
end
-- 判断此卡是否是从场上送去墓地，且自身与被除外的卡片均带有有效的关联标记
function c99070951.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():GetFlagEffect(99070951)~=0
		and tc and tc:GetFlagEffect(99070951)~=0
end
-- 加入手卡效果的发动准备，设置将目标卡片加入手卡的操作信息
function c99070951.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=e:GetLabelObject():GetLabelObject()
	-- 设置操作信息，表示此效果会将特定的卡片加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 加入手卡效果的处理，将该效果除外的卡片加入手卡
function c99070951.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject():GetLabelObject()
	if tc and tc:GetFlagEffect(99070951)~=0 then
		-- 将目标卡片因效果加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
