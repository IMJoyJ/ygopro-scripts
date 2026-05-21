--剣闘獣ウェスパシアス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「剑斗兽」怪兽和怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤。
-- ②：只要「剑斗兽」怪兽的效果特殊召唤的这张卡在怪兽区域存在，自己场上的怪兽的攻击力上升500。
-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 维斯帕西亚努斯」以外的1只「剑斗兽」怪兽特殊召唤。
function c88996322.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的「剑斗兽」怪兽和怪兽进行战斗的伤害步骤开始时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,88996322)
	e1:SetCondition(c88996322.hspcon)
	e1:SetTarget(c88996322.hsptg)
	e1:SetOperation(c88996322.hspop)
	c:RegisterEffect(e1)
	-- ②：只要「剑斗兽」怪兽的效果特殊召唤的这张卡在怪兽区域存在，自己场上的怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 限制该效果仅在自身是通过「剑斗兽」怪兽的效果特殊召唤的场合才适用。
	e2:SetCondition(aux.gbspcon)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的战斗阶段结束时让这张卡回到持有者卡组才能发动。从卡组把「剑斗兽 维斯帕西亚努斯」以外的1只「剑斗兽」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(88996322,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c88996322.spcon)
	e3:SetCost(c88996322.spcost)
	e3:SetTarget(c88996322.sptg)
	e3:SetOperation(c88996322.spop)
	c:RegisterEffect(e3)
end
-- 检查是否是自己的「剑斗兽」怪兽和怪兽进行战斗的伤害步骤开始时。
function c88996322.hspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if d:IsControler(tp) then a,d=d,a end
	return a:IsSetCard(0x1019) and a:IsFaceup()
end
-- 检查自身是否能从手卡特殊召唤，并设置特殊召唤的操作信息。
function c88996322.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行将这张卡从手卡特殊召唤，并注册「用剑斗兽效果特召」的标记。
function c88996322.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	c:RegisterFlagEffect(c:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
end
-- 检查这张卡在此次战斗阶段中是否进行过战斗。
function c88996322.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattledGroupCount()>0
end
-- 检查并执行将这张卡回到持有者卡组的代价。
function c88996322.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeckAsCost() end
	-- 作为发动代价，将这张卡回到持有者的卡组并洗牌。
	Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_COST)
end
-- 过滤卡组中除「剑斗兽 维斯帕西亚努斯」以外的「剑斗兽」怪兽。
function c88996322.filter(c,e,tp)
	return not c:IsCode(88996322) and c:IsSetCard(0x1019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否能从卡组特殊召唤符合条件的「剑斗兽」怪兽，并设置特殊召唤的操作信息。
function c88996322.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查在这张卡离开场后，自己场上是否有空余的怪兽区域。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查卡组中是否存在至少1只可以特殊召唤的「剑斗兽」怪兽。
		and Duel.IsExistingMatchingCard(c88996322.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 从卡组选择1只「剑斗兽」怪兽特殊召唤，并为其注册「用剑斗兽效果特召」的标记。
function c88996322.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组中选择1只符合条件的「剑斗兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c88996322.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		tc:RegisterFlagEffect(tc:GetOriginalCode(),RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0)
	end
end
