--ジェムナイト・ネピリム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「宝石骑士·拿非琉」以外的1张「宝石骑士」卡加入手卡。这个回合的主要阶段内，对方受到的效果伤害变成一半。
-- ②：自己主要阶段才能发动。进行1只「宝石」怪兽的召唤。
-- ③：这张卡从手卡·卡组送去墓地的场合才能发动。选自己1张手卡送去墓地，这张卡特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的3个效果，分别对应①②③效果
function s.initial_effect(c)
	-- 效果①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「宝石骑士·拿非琉」以外的1张「宝石骑士」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果②：自己主要阶段才能发动。进行1只「宝石」怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"追加召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	-- 效果③：这张卡从手卡·卡组送去墓地的场合才能发动。选自己1张手卡送去墓地，这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检索效果的过滤函数，用于筛选非自身且为宝石骑士族的可加入手牌的卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 效果①的发动时点处理函数，检查是否满足发动条件并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果①的发动条件：卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果①的操作信息为检索1张卡到手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方提示该卡发动了效果①
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果①的处理函数，执行检索并设置伤害减半效果
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡组中的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 判断是否已注册过伤害减半效果
	if Duel.GetFlagEffect(tp,51831560)==0 then
		-- 注册伤害减半效果标识
		Duel.RegisterFlagEffect(tp,51831560,RESET_PHASE+PHASE_END,0,1)
		-- 创建并注册伤害减半效果，使对方受到的效果伤害变为一半
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetCondition(s.damcon)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将伤害减半效果注册到玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害减半效果的触发条件函数，仅在主要阶段时生效
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段
	return Duel.IsMainPhase()
end
-- 伤害减半效果的数值处理函数，若为效果伤害则伤害减半
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return math.ceil(val/2)
	else return val end
end
-- 召唤效果的过滤函数，用于筛选可通常召唤的宝石族怪兽
function s.sumfilter(c)
	return c:IsSetCard(0x47) and c:IsSummonable(true,nil)
end
-- 效果②的发动时点处理函数，检查是否满足发动条件并设置操作信息
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的发动条件：玩家可以通常召唤且手牌或场上有符合条件的卡
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置效果②的操作信息为进行1只怪兽的通常召唤
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	-- 向对方提示该卡发动了效果②
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 效果②的处理函数，执行选择并通常召唤一只怪兽
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要通常召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 选择满足条件的手牌或场上的怪兽
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 执行通常召唤操作
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 效果③的发动条件函数，判断该卡是否从手卡或卡组送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- 特殊召唤效果的过滤函数，用于筛选可送去墓地的卡
function s.tgfilter(c)
	return c:IsAbleToGrave()
end
-- 效果③的发动时点处理函数，检查是否满足发动条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足效果③的发动条件：场上存在空位且该卡可特殊召唤且手牌中有可送去墓地的卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否满足效果③的发动条件：手牌中有可送去墓地的卡
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置效果③的操作信息为将1张手卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置效果③的操作信息为特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果③的处理函数，执行选择并送去墓地及特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的手牌中的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断是否成功将卡送去墓地且该卡在墓地
	if tc and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 判断该卡是否与连锁相关且未受王家长眠之谷影响
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
