--水竜星－ビシキ
-- 效果：
-- 「水龙星-赑屃」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「水龙星-赑屃」以外的1只「龙星」怪兽攻击表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽不受陷阱卡的效果影响。
function c2095764.initial_effect(c)
	-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「水龙星-赑屃」以外的1只「龙星」怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2095764,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,2095764)
	e1:SetCondition(c2095764.condition)
	e1:SetTarget(c2095764.target)
	e1:SetOperation(c2095764.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c2095764.sccon)
	e2:SetTarget(c2095764.sctg)
	e2:SetOperation(c2095764.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽不受陷阱卡的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c2095764.immcon)
	e3:SetOperation(c2095764.immop)
	c:RegisterEffect(e3)
end
-- 判断是否满足效果①的发动条件：该卡因战斗或效果被破坏且离开场上，且破坏前在自己场上控制者为自己。
function c2095764.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤函数：筛选卡组中满足「龙星」属性、非本卡、可攻击表示特殊召唤的怪兽。
function c2095764.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(2095764) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果①的发动时点判定：确认场上是否有空位及卡组中是否存在符合条件的怪兽。
function c2095764.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c2095764.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果①的发动信息：提示将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：若场上存在空位，则从卡组选择符合条件的怪兽进行攻击表示特殊召唤。
function c2095764.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位，若无则不执行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c2095764.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽以攻击表示特殊召唤到场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果②的发动条件：对方的主要阶段或战斗阶段，且当前回合玩家不是自己。
function c2095764.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，若为则不能发动。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤函数：筛选场上「龙星」属性的怪兽。
function c2095764.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- 效果②的发动时点判定：确认场上是否存在「龙星」怪兽，且是否存在可同调召唤的怪兽。
function c2095764.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上所有「龙星」属性的怪兽。
		local mg=Duel.GetMatchingGroup(c2095764.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断是否存在可同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置效果②的发动信息：提示将从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理：若存在可同调召唤的怪兽，则选择并进行同调召唤。
function c2095764.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有「龙星」属性的怪兽。
	local mg=Duel.GetMatchingGroup(c2095764.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取所有可同调召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 判断该卡是否因同调召唤而成为素材。
function c2095764.immcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果③的处理：若该卡作为同调素材被使用，则为对应的同调怪兽添加不受陷阱卡效果影响的效果。
function c2095764.immop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为同调怪兽添加不受陷阱卡效果影响的效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2095764,1))  --"「水龙星-赑屃」效果适用中"
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(c2095764.efilter)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
end
-- 效果过滤函数：判断效果是否为陷阱卡类型。
function c2095764.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
