--炎竜星－シュンゲイ
-- 效果：
-- 「炎龙星-狻猊」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「炎龙星-狻猊」以外的1只「龙星」怪兽守备表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽攻击力·守备力上升500。
function c30106950.initial_effect(c)
	-- 「炎龙星-狻猊」的①的效果1回合只能使用1次。①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「炎龙星-狻猊」以外的1只「龙星」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30106950,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,30106950)
	e1:SetCondition(c30106950.condition)
	e1:SetTarget(c30106950.target)
	e1:SetOperation(c30106950.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c30106950.sccon)
	e2:SetTarget(c30106950.sctg)
	e2:SetOperation(c30106950.scop)
	c:RegisterEffect(e2)
	-- ③：这张卡为同调素材的同调怪兽攻击力·守备力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCondition(c30106950.atkcon)
	e3:SetOperation(c30106950.atkop)
	c:RegisterEffect(e3)
end
-- 判断效果①的触发条件：这张卡被战斗或效果破坏并送去墓地，且破坏前在场上且由自己控制。
function c30106950.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 定义特殊召唤的卡牌过滤器：必须是「龙星」怪兽、不能是「炎龙星-狻猊」自身，且可以表侧守备表示特殊召唤。
function c30106950.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(30106950) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①发动时的合法性检查：自己主要怪兽区有空位，且卡组中存在满足条件的「龙星」怪兽。
function c30106950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用空格，作为可特殊召唤的前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1张满足c30106950.filter的「龙星」怪兽可作为特殊召唤对象。
		and Duel.IsExistingMatchingCard(c30106950.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，声明本次效果处理为从卡组特殊召唤1只怪兽，供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①处理：若自己主要怪兽区仍有空位，则从卡组选择1只符合条件的「龙星」怪兽，以表侧守备表示特殊召唤。
function c30106950.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认主要怪兽区有空位，若无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家弹出选择提示“请选择要特殊召唤的卡”，并写入选择专用消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1张满足过滤条件的「龙星」怪兽（除自身外且可守备特召）。
	local g=Duel.SelectMatchingCard(tp,c30106950.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上，不无视召唤条件和苏生限制。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断效果②的发动时机：当前必须是对方回合，且处于对方的主要阶段1、主要阶段2或战斗阶段。
function c30106950.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果是自己的回合则返回false，②效果只能在对方回合发动。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前阶段，用于判断是否处于对方的主要阶段或战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 定义同调素材的过滤函数：自己场上的「龙星」怪兽。
function c30106950.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- 效果②发动时的合法性检查：自己场上有「龙星」怪兽，且额外卡组中能用这些「龙星」怪兽进行同调召唤的同调怪兽存在。
function c30106950.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上所有「龙星」怪兽作为同调素材候选组。
		local mg=Duel.GetMatchingGroup(c30106950.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查额外卡组中是否存在至少1只同调怪兽，能用当前「龙星」素材组进行同调召唤。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置连锁操作信息，声明本次效果将进行1只同调怪兽的特殊召唤（从额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②处理：选择额外卡组中1只可用自己场上「龙星」怪兽进行同调召唤的同调怪兽，并以场上的「龙星」怪兽为素材进行同调召唤。
function c30106950.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新获取自己场上当前所有「龙星」怪兽作为同调素材候选组。
	local mg=Duel.GetMatchingGroup(c30106950.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取额外卡组中所有能用当前「龙星」素材组进行同调召唤的同调怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要同调召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 使用自己场上的「龙星」怪兽组作为素材，同调召唤选择的同调怪兽。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 判断效果③的触发条件：此卡作为同调素材被使用（即因同调召唤而成为素材）。
function c30106950.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果③处理：给同调召唤出的那只怪兽赋予攻击力和守备力各上升500的永续效果，该效果随着怪兽离场而失效。
function c30106950.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：这张卡为同调素材的同调怪兽攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	rc:RegisterEffect(e2,true)
end
