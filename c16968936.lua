--六武衆の指南番
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己场上有「六武众的指南番」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地把1张「六武式」卡加入手卡。
-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
-- ●对方场上的怪兽的攻击力下降500。
local s,id,o=GetID()
-- 注册该卡的全部效果：①以手卡特殊召唤规则效果，②从场上送入墓地时检索「六武式」卡，③作为同调素材时为同调召唤的「六武众」怪兽赋予对方怪兽攻击力下降500的效果。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「六武众的指南番」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地把1张「六武式」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②③的效果1回合各能使用1次。③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
-- 过滤出表侧表示、属于「六武众」字段、且不是这张卡自身的怪兽，用于判断①特殊召唤条件的满足。
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(id)
end
-- ①特殊召唤规则的条件：仅在可特殊召唤的怪兽区域存在空位，且自己场上有符合条件的「六武众」怪兽（表侧表示且不是本卡）时才能从手卡特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查持有者（或控制者）的主要怪兽区是否有空位，保证有格子可供特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张表侧表示、属于「六武众」字段且不是本卡的怪兽，以满足①的召唤条件。
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- ②的发动条件：这张卡从场上区域被送去墓地的场合才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤出属于「六武式」字段且能够加入手卡的卡，用于②的检索对象。
function s.thfilter(c)
	return c:IsSetCard(0x203d) and c:IsAbleToHand()
end
-- ②的发动时判定：在卡组·墓地存在至少1张可加入手卡的「六武式」卡时才能发动，并设置将1张「六武式」卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认自己的卡组·墓地中至少存在1张能够加入手卡的「六武式」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本次效果的操作信息：效果类别为回手牌/检索/涉及墓地，目标为1张「六武式」卡，来源区域为卡组·墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②的效果处理：从卡组·墓地中选择1张「六武式」卡加入手卡（受王家长眠之谷影响的卡除外），并向对方玩家确认加入手卡的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手卡的「六武式」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组·墓地区域选择1张满足「六武式」且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「六武式」卡加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③的触发条件：这张卡被作为同调素材使用，并且通过同调召唤出的怪兽属于「六武众」字段。
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO)~=0 and e:GetHandler():GetReasonCard():IsSetCard(0x103d)
end
-- ③的效果处理：为通过同调召唤出的「六武众」怪兽赋予'对方场上的怪兽攻击力下降500'的效果；若该怪兽不是效果怪兽，则将其变为效果怪兽，并附加效果适用中的提示标记。
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●对方场上的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「六武众的指南番」效果适用中"
end
