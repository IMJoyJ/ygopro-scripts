--六武衆の破戒僧
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：自己场上有「六武众的破戒僧」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「六武众」速攻魔法卡加入手卡。
-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
-- ●对方场上的怪兽的等级下降1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手卡特殊召唤规则、送墓检索速攻魔法效果以及作为同调素材赋予效果的诱发效果。
function s.initial_effect(c)
	-- ①：自己场上有「六武众的破戒僧」以外的「六武众」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「六武众」速攻魔法卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡为素材作同调召唤的「六武众」怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.effcon)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
-- 过滤自己场上「六武众的破戒僧」以外表侧表示的「六武众」怪兽。
function s.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d) and not c:IsCode(id)
end
-- 手卡特殊召唤规则的条件判定，需要怪兽区域有空位且自己场上存在其他「六武众」怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查当前玩家的怪兽区域是否有可用的空位。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在「六武众的破戒僧」以外表侧表示的「六武众」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 检索效果的发动条件，判定这张卡是否从场上送去墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以加入手卡的「六武众」速攻魔法卡。
function s.thfilter(c)
	return c:IsSetCard(0x103d) and bit.band(c:GetType(),TYPE_SPELL+TYPE_QUICKPLAY)==TYPE_SPELL+TYPE_QUICKPLAY and c:IsAbleToHand()
end
-- 检索效果的靶向处理，检查卡组中是否存在可检索的卡，并向系统宣告检索操作。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段检查卡组中是否存在满足条件的「六武众」速攻魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统宣告该效果的处理包含从卡组将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行操作，让玩家从卡组选择1张「六武众」速攻魔法卡加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端向玩家显示“请选择要加入手牌的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「六武众」速攻魔法卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片通过效果加入玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片给对方玩家进行确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 素材赋予效果的发动条件，判定是否作为同调素材，且同调召唤出的怪兽是「六武众」怪兽。
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_SYNCHRO)~=0 and e:GetHandler():GetReasonCard():IsSetCard(0x103d)
end
-- 素材赋予效果的执行操作，为同调召唤出的「六武众」怪兽注册降低对方场上怪兽等级的效果，并在其不是效果怪兽时赋予其效果怪兽类型。
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●对方场上的怪兽的等级下降1星。
	local e1=Effect.CreateEffect(rc)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●对方场上的怪兽的等级下降1星。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))  --"「六武众的破戒僧」效果适用中"
end
