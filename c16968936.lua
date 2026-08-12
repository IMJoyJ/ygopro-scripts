--六武衆の指南番
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己场上有「六武众的指南番」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从自己的卡组·墓地把1张「六武式」卡加入手卡。
-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
-- ●对方场上的怪兽的攻击力下降500。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：特殊召唤条件、墓地发动的检索效果、同调素材时的攻击力下降效果
function s.initial_effect(c)
	-- ①：自己场上有「六武众的指南番」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
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
	-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。●对方场上的怪兽的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查场上是否存在「六武众」且非本卡的怪兽
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(id)
end
-- 特殊召唤条件函数：判断是否满足特殊召唤条件（场上存在其他六武众怪兽且有空位）
function s.spcon(e,c)
	if c==nil then return true end
	-- 判断当前玩家场上是否有空怪兽区
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 判断当前玩家场上是否存在其他六武众怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索效果的发动条件：卡片从场上送去墓地时发动
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤函数：筛选「六武式」卡
function s.thfilter(c)
	return c:IsSetCard(0x203d) and c:IsAbleToHand()
end
-- 检索效果的目标设定：确认是否有满足条件的卡可加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否有满足条件的「六武式」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理函数：选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「六武式」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 同调素材效果的发动条件：作为同调素材时触发
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO)~=0 and e:GetHandler():GetReasonCard():IsSetCard(0x103d)
end
-- 同调素材效果的处理函数：使同调怪兽获得攻击力下降效果并添加效果类型
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 使对方场上怪兽攻击力下降500
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若同调怪兽无效果类型则添加效果类型，并提示效果适用中
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「六武众的指南番」效果适用中"
end
