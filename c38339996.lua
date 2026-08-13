--R－ACEインパルス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。选对方场上1只攻击力最高的效果怪兽。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
-- ②：对方把怪兽的效果在场上发动时，把手卡·场上的这张卡解放才能发动。从卡组把1只机械族「救援ACE队」怪兽特殊召唤。
local s,id,o=GetID()
-- 创建并注册两个效果：①为起动效果，在自己主要阶段发动，选择对方场上攻击力最高的效果怪兽并使其本回合不能在场上发动效果；②为诱发即时效果，对方在场上发动怪兽效果时解放自身（手卡或场上的此卡），从卡组特殊召唤1只机械族「救援ACE队」怪兽。
function s.initial_effect(c)
	-- ①：自己主要阶段才能发动。选对方场上1只攻击力最高的效果怪兽。这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.ntg)
	e1:SetOperation(s.nop)
	c:RegisterEffect(e1)
	-- ②：对方把怪兽的效果在场上发动时，把手卡·场上的这张卡解放才能发动。从卡组把1只机械族「救援ACE队」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选条件：表侧表示且为效果怪兽。用于选取对方场上符合条件的怪兽。
function s.nfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ①的发动条件检查：对方场上存在至少1只表侧表示的效果怪兽时可发动（起动效果，主要阶段发动）。
function s.ntg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查对方场上是否存在至少1只表侧表示的效果怪兽，作为①是否可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.nfilter,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果处理：获取对方场上所有表侧表示效果怪兽，选出攻击力最高的一组；若多只攻击力并列则由玩家选择其中1只；为选中的怪兽附加EFFECT_CANNOT_TRIGGER效果，使其本回合在场上不能发动效果。
function s.nop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示效果怪兽的集合，作为①的效果候选。
	local g=Duel.GetMatchingGroup(s.nfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		local tc
		if tg:GetCount()>1 then
			-- 显示选择提示“请选择表侧表示的卡”，用于从攻击力最高且并列的怪兽中选择1只。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 以动画形式展示玩家选中的卡，并将其记录为当前效果的对象。
			Duel.HintSelection(sg)
			tc=sg:GetFirst()
		else
			-- 当攻击力最高的怪兽只有1只时，直接以动画形式展示该卡作为效果对象。
			Duel.HintSelection(tg)
			tc=tg:GetFirst()
		end
		-- 这个回合，双方不能把那只表侧表示怪兽的场上发动的效果发动。②：对方把怪兽的效果在场上发动时，把手卡·场上的这张卡解放才能发动。从卡组把1只机械族「救援ACE队」怪兽特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end
-- ②的发动条件：对方玩家发动了怪兽效果，且该效果在场上（怪兽区）发动；即连锁对方在场上发动的怪兽效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②的发动代价：将这张卡（手卡或场上的自身）解放；需要自身可以解放且解放后我方怪兽区仍有空格，然后实际执行解放。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查②的代价是否满足：这张卡可解放，且解放后我方场上还有可用的怪兽区。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 以REASON_COST（代价）方式解放这张卡，从手卡或场上送入墓地。
	Duel.Release(c,REASON_COST)
end
-- ②特殊召唤的筛选条件：卡组中存在机械族且「救援ACE队」字段的怪兽，并且该怪兽可被特殊召唤（不检查苏生限制）。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动条件和操作信息：检查卡组中是否存在符合条件的怪兽，并登记本次效果为从卡组特殊召唤1只怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ②发动时点检查卡组中是否有至少1只满足机械族「救援ACE队」且可特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息为特殊召唤类别（CATEGORY_SPECIAL_SUMMON），用于连锁判定；目标为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若我方怪兽区有空位，则从卡组选择1只符合条件的机械族「救援ACE队」怪兽，表侧表示特殊召唤到我方场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认我方怪兽区存在空位，防止因格子不足无法特殊召唤。
	if Duel.GetMZoneCount(tp)>0 then
		-- 显示选择提示“请选择要特殊召唤的卡”，用于从卡组中选取要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1张满足条件的机械族「救援ACE队」怪兽（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示（攻击表示）特殊召唤到我方场上，不检查召唤条件和苏生限制。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
