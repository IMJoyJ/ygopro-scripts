--ヴァンパイア・フロイライン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：自己的不死族怪兽和对方怪兽进行战斗的伤害计算时1次，支付100的倍数的基本分才能发动（最多3000）。那只自己怪兽的攻击力·守备力只在那次伤害计算时上升支付的数值。
-- ③：这张卡战斗破坏怪兽的战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
function c6039967.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：怪兽的攻击宣言时才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6039967,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,6039967)
	e1:SetTarget(c6039967.sptg1)
	e1:SetOperation(c6039967.spop1)
	c:RegisterEffect(e1)
	-- ②：自己的不死族怪兽和对方怪兽进行战斗的伤害计算时1次，支付100的倍数的基本分才能发动（最多3000）。那只自己怪兽的攻击力·守备力只在那次伤害计算时上升支付的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(6039967,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c6039967.atkcon)
	e2:SetCost(c6039967.atkcost)
	e2:SetOperation(c6039967.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏怪兽的
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetOperation(c6039967.regop)
	c:RegisterEffect(e3)
	-- 战斗阶段结束时才能发动。那些怪兽从墓地尽可能往自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6039967,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c6039967.spcon2)
	e4:SetTarget(c6039967.sptg2)
	e4:SetOperation(c6039967.spop2)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件判定：自己场上存在可用的主要怪兽区域，且这张卡能够以表侧守备表示从手卡特殊召唤。
function c6039967.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将这次效果处理登记为「特殊召唤」操作，对象为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其从手卡以表侧守备表示特殊召唤。
function c6039967.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧守备表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- ②效果的发动条件：存在攻击对象（不是直接攻击），且攻击怪兽或攻击对象中至少一方为己方控制的不死族怪兽。
function c6039967.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认存在攻击对象，即该战斗不是直接攻击，满足“和对方怪兽进行战斗”的前提。
	return Duel.GetAttackTarget()
		-- 攻击怪兽由己方控制且种族为不死族。
		and (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRace(RACE_ZOMBIE)
		-- 攻击对象怪兽由己方控制且种族为不死族。
		or Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsRace(RACE_ZOMBIE))
end
-- ②效果的发动代价检查：这张卡尚未在本回合的伤害计算阶段发动过②效果，且能够支付至少100基本分。
function c6039967.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(6039967)==0
		-- 检查玩家当前LP是否足够支付100基本分。
		and Duel.CheckLPCost(tp,100,true) end
	-- 获取玩家当前LP，用于计算可支付的100倍数值的上限（最多3000）。
	local lp=Duel.GetLP(tp)
	local m=math.floor(math.min(lp,3000)/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	-- 让玩家宣言一个100的倍数作为支付的LP数值，ac保存宣言值。
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 支付宣言数值的基本分作为发动代价。
	Duel.PayLPCost(tp,ac,true)
	e:SetLabel(ac)
	e:GetHandler():RegisterFlagEffect(6039967,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- ②效果处理：确定己方那只参与战斗的不死族怪兽，使其攻击力、守备力仅在本次伤害计算时上升支付的基本分数值。
function c6039967.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 先默认以攻击怪兽作为提升能力的对象。
	local c=Duel.GetAttacker()
	-- 若攻击怪兽不是己方控制，则将对象改为攻击对象怪兽（即己方那只不死族怪兽）。
	if c:IsControler(1-tp) then c=Duel.GetAttackTarget() end
	-- 那只自己怪兽的攻击力·守备力只在那次伤害计算时上升支付的数值。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	e1:SetValue(e:GetLabel())
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
-- 不入连锁的辅助效果：当这张卡战斗破坏怪兽时，给自己设置标记6039968，持续到战斗阶段结束，作为③效果的发动条件。
function c6039967.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(6039968,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- ③效果的发动条件：检查这张卡是否带有标记6039968（即本战斗阶段破坏过怪兽）。
function c6039967.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(6039968)~=0
end
-- 墓地怪兽的过滤条件：该怪兽是被这张卡在同一回合内战斗破坏送去墓地的，且可以特殊召唤。
function c6039967.spfilter2(c,e,tp,rc,tid)
	return c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc and c:GetTurnID()==tid
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件判定：自己场上存在可用主要怪兽区域，且墓地存在至少1只满足条件的怪兽（被此卡战斗破坏且可特招）。
function c6039967.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少1只满足过滤条件（本回合被此卡战斗破坏且可特招）的怪兽。
		and Duel.IsExistingMatchingCard(c6039967.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp,e:GetHandler(),Duel.GetTurnCount()) end
	-- 获取墓地中所有满足特招条件的怪兽，组成集合g。
	local g=Duel.GetMatchingGroup(c6039967.spfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	-- 将这次效果处理登记为特殊召唤操作，对象为满足条件的墓地怪兽集合g，用于外部效果联动。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：计算可用区域；若区域不足则在墓地对象中选择对应数量的卡，否则全部选择；若【青眼精灵龙】效果适用中则最多只能选择1只；最后将选择的怪兽以表侧表示特殊召唤到自己场上。
function c6039967.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的主要怪兽区域数量，作为本次最多能特殊召唤的怪兽数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取墓地中满足条件且不受王家长眠之谷影响的怪兽集合。
	local tg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c6039967.spfilter2),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp,e:GetHandler(),Duel.GetTurnCount())
	local g=nil
	if tg:GetCount()>ft then
		-- 当可用区域不足以容纳全部对象时，显示选择特殊召唤对象的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		g=tg:Select(tp,ft,ft,nil)
	else
		g=tg
	end
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
