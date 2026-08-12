--炎竜星－シュンゲイ
-- 效果：
-- 「炎龙星-狻猊」的①的效果1回合只能使用1次。
-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「炎龙星-狻猊」以外的1只「龙星」怪兽守备表示特殊召唤。
-- ②：1回合1次，对方的主要阶段以及战斗阶段才能发动。只用自己场上的「龙星」怪兽为同调素材作同调召唤。
-- ③：这张卡为同调素材的同调怪兽攻击力·守备力上升500。
function c30106950.initial_effect(c)
	-- ①：自己场上的这张卡被战斗·效果破坏送去墓地时才能发动。从卡组把「炎龙星-狻猊」以外的1只「龙星」怪兽守备表示特殊召唤。
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
-- 判断是否满足效果①的发动条件：卡因战斗或效果破坏且离开场上，且破坏时控制者为自己。
function c30106950.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp)
end
-- 过滤函数：筛选卡组中非自身且为「龙星」族的怪兽，且可守备表示特殊召唤。
function c30106950.filter(c,e,tp)
	return c:IsSetCard(0x9e) and not c:IsCode(30106950) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断效果①的发动是否满足：场上存在空位且卡组存在符合条件的怪兽。
function c30106950.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c30106950.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果①的处理信息：将要特殊召唤1只怪兽到场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数：若场上存在空位，则从卡组选择符合条件的怪兽进行守备表示特殊召唤。
function c30106950.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c30106950.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 将选中的怪兽以守备表示特殊召唤到场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 判断效果②是否可以发动：当前为对方回合且处于主要阶段或战斗阶段。
function c30106950.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前为己方回合则效果②不可发动。
	if Duel.GetTurnPlayer()==tp then return false end
	-- 获取当前阶段。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE) or ph==PHASE_MAIN2
end
-- 过滤函数：筛选场上「龙星」族怪兽。
function c30106950.mfilter(c)
	return c:IsSetCard(0x9e)
end
-- 判断效果②的发动是否满足：场上存在「龙星」族怪兽且存在可同调召唤的怪兽。
function c30106950.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取场上「龙星」族怪兽。
		local mg=Duel.GetMatchingGroup(c30106950.mfilter,tp,LOCATION_MZONE,0,nil)
		-- 判断是否存在可同调召唤的怪兽。
		return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil,mg)
	end
	-- 设置效果②的处理信息：将要特殊召唤1只同调怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的处理函数：若存在可同调召唤的怪兽，则选择并进行同调召唤。
function c30106950.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上「龙星」族怪兽。
	local mg=Duel.GetMatchingGroup(c30106950.mfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取可同调召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil,mg)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的同调怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 进行同调召唤。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil,mg)
	end
end
-- 判断是否为同调召唤时作为素材：只有当此卡作为同调素材时才触发效果③。
function c30106950.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO
end
-- 效果③的处理函数：使以此卡为素材的同调怪兽攻击力与守备力各上升500。
function c30106950.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 使同调怪兽攻击力上升500。
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
