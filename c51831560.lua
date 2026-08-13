--ジェムナイト・ネピリム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「宝石骑士·拿非琉」以外的1张「宝石骑士」卡加入手卡。这个回合的主要阶段内，对方受到的效果伤害变成一半。
-- ②：自己主要阶段才能发动。进行1只「宝石」怪兽的召唤。
-- ③：这张卡从手卡·卡组送去墓地的场合才能发动。选自己1张手卡送去墓地，这张卡特殊召唤。
local s,id,o=GetID()
-- 为「宝石骑士·拿非琉」注册全部效果：①召唤/特殊召唤成功时检索「宝石骑士」卡并附加本回合对方效果伤害减半；②自己主要阶段追加一次「宝石」怪兽的通常召唤；③从手卡/卡组送去墓地时丢1手卡特召自身。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「宝石骑士·拿非琉」以外的1张「宝石骑士」卡加入手卡。
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
	-- ②：自己主要阶段才能发动。进行1只「宝石」怪兽的召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"追加召唤"
	e3:SetCategory(CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sumtg)
	e3:SetOperation(s.sumop)
	c:RegisterEffect(e3)
	-- ③：这张卡从手卡·卡组送去墓地的场合才能发动。选自己1张手卡送去墓地，这张卡特殊召唤。
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
-- 定义检索过滤条件：不是「宝石骑士·拿非琉」自身、属于「宝石骑士」字段且可以加入手卡的卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1047) and c:IsAbleToHand()
end
-- 效果发动时的目标判定：检查卡组是否存在满足检索条件的「宝石骑士」卡，存在则设置检索操作信息并向对方展示效果描述。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动判定阶段（chk==0），判断己方卡组是否有至少1张满足s.thfilter的检索目标，以此作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息：从卡组将1张卡加入手卡（用于检索类效果的相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 向对方玩家提示已发动该效果，并显示效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行①的检索处理：选择1张符合条件的「宝石骑士」卡加入手卡并让对方确认；若本回合尚未适用过伤害减半效果，则注册一个持续到结束阶段的伤害减半效果，使对方在主要阶段受到的效果伤害减半。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从己方卡组选取1张满足s.thfilter的「宝石骑士」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡因效果加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，以确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 检查己方是否已经注册过该效果的伤害减半标志（51831560），避免重复注册。
	if Duel.GetFlagEffect(tp,51831560)==0 then
		-- 给己方注册一个回合标志（51831560），表示本回合已适用过①的伤害减半效果，并在结束阶段重置。
		Duel.RegisterFlagEffect(tp,51831560,RESET_PHASE+PHASE_END,0,1)
		-- 这个回合的主要阶段内，对方受到的效果伤害变成一半。②：自己主要阶段才能发动。进行1只「宝石」怪兽的召唤。③：这张卡从手卡·卡组送去墓地的场合才能发动。选自己1张手卡送去墓地，这张卡特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(0,1)
		e1:SetCondition(s.damcon)
		e1:SetValue(s.damval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将伤害减半效果注册到当前场上，仅对对方玩家生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义伤害减半效果的适用条件：仅当处于主要阶段时效果才适用。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段，是则允许伤害减半效果适用。
	return Duel.IsMainPhase()
end
-- 定义伤害数值变更逻辑：若伤害为效果伤害，则向上取整减半；否则保持原数值。
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return math.ceil(val/2)
	else return val end
end
-- 定义「宝石」怪兽的召唤选择过滤条件：属于「宝石」字段且可以进行通常召唤（忽略召唤次数限制）。
function s.sumfilter(c)
	return c:IsSetCard(0x47) and c:IsSummonable(true,nil)
end
-- ②效果发动时的目标判定：检查己方是否可进行通常召唤以及手牌/场上是否存在可通常召唤的「宝石」怪兽，并设置召唤操作信息、向对方提示。
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动判定阶段，判断己方可以通常召唤且存在满足s.sumfilter的「宝石」怪兽，作为②效果的发动条件。
	if chk==0 then return Duel.IsPlayerCanSummon(tp) and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置当前连锁的操作信息：进行1次怪兽的通常召唤。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	-- 向对方玩家提示已发动②效果，并显示效果描述文字。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 执行②的召唤处理：选择1只符合条件的「宝石」怪兽，进行无视通常召唤次数限制的通常召唤。
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示文字“请选择要召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手牌/场上选择1只满足s.sumfilter的「宝石」怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		-- 令己方对选择的怪兽进行通常召唤，ignore_count=true表示不消耗本回合的通常召唤次数。
		Duel.Summon(tp,tc,true,nil)
	end
end
-- 定义③效果的发动条件：本卡从手卡或卡组送入墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK+LOCATION_HAND)
end
-- 定义用于③效果的手卡丢弃过滤条件：可以被效果送入墓地的手牌。
function s.tgfilter(c)
	return c:IsAbleToGrave()
end
-- ③效果发动时的目标判定：检查己方主要怪兽区是否有空位、自身能否特殊召唤，以及手卡是否存在可送去墓地的卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 若为发动判定阶段，条件之一：己方的主要怪兽区域存在空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 若为发动判定阶段，条件之二：手卡存在至少1张可送去墓地的卡（配合s.tgfilter）。
		and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置当前连锁的操作信息：将1张手卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置当前连锁的操作信息：将本卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行③的特殊召唤处理：从手卡选1张卡送去墓地，若成功且该卡在墓地、自身仍与连锁相关且不受王家长眠之谷影响，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示文字“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手卡选择1张可以送去墓地的卡。
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	-- 判断被选中的卡是否确实因效果被送入墓地且目前位于墓地。
	if tc and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE)
		-- 判断本卡仍与当前连锁相关（未被无效或离场影响），且不受「王家长眠之谷」等卡的特殊召唤限制。
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将本卡以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
