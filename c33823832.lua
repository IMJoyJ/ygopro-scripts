--EMファイア・マフライオ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己场上的灵摆怪兽被战斗破坏时才能发动。灵摆区域的这张卡特殊召唤。
-- 【怪兽效果】
-- ①：1回合1次，自己的灵摆怪兽战斗破坏对方怪兽的伤害计算后才能发动。那只自己怪兽直到战斗阶段结束时攻击力上升200，只再1次可以继续攻击。
function c33823832.initial_effect(c)
	-- 为灵摆怪兽附加灵摆召唤、灵摆区发动的规则支持，使这张卡可以作为灵摆卡放置到灵摆区并可进行灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- ①：自己场上的灵摆怪兽被战斗破坏时才能发动。灵摆区域的这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33823832,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c33823832.spcon)
	e2:SetTarget(c33823832.sptg)
	e2:SetOperation(c33823832.spop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，自己的灵摆怪兽战斗破坏对方怪兽的伤害计算后才能发动。那只自己怪兽直到战斗阶段结束时攻击力上升200，只再1次可以继续攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(33823832,1))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c33823832.cacon)
	e3:SetOperation(c33823832.caop)
	c:RegisterEffect(e3)
end
-- 判定被战斗破坏的怪兽是否满足以下条件：是灵摆怪兽、之前位于主要怪兽区、并且之前由效果发动方控制，用于确认是否属于“自己场上的灵摆怪兽被战斗破坏”。
function c33823832.cfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 从本次被战斗破坏的怪兽集合中，检查是否存在至少1只满足自己场上灵摆怪兽条件的卡，以决定该诱发效果是否满足发动条件。
function c33823832.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c33823832.cfilter,1,nil,tp)
end
-- 效果发动时的合法性判定：自己的主要怪兽区有空位，且灵摆区的这张卡可以被特殊召唤，满足才可发动。
function c33823832.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用的空格，确保之后能将这张卡特殊召唤到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的处理信息登记为特殊召唤这张卡，数量为1，以供其他卡（如星尘龙等）进行对应或检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段：若灵摆区的这张卡仍与该效果保持关联（没有中途离场等），则将其特殊召唤到自己场上。
function c33823832.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧攻击表示特殊召唤到其控制者场上；此处检查通常召唤/特殊召唤条件以及苏生限制。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 战斗后触发条件判定：获取战斗双方怪兽并调整方向，使a为自己场上的攻击怪兽、d为对方怪兽；若a是灵摆怪兽、a未被战斗破坏、d被战斗破坏，则记录a并允许发动。
function c33823832.cacon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 取得当前战斗的攻击目标怪兽；若为直接攻击则为nil。
	local d=Duel.GetAttackTarget()
	if not d then return false end
	if a:IsStatus(STATUS_OPPO_BATTLE) and d:IsControler(tp) then a,d=d,a end
	if a:IsType(TYPE_PENDULUM)
		and not a:IsStatus(STATUS_BATTLE_DESTROYED) and d:IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetLabelObject(a)
		return true
	else return false end
end
-- 效果处理：对之前记录的那只自己灵摆怪兽，若它仍表侧表示、控制权仍属于自己且与本次战斗关联，则使其攻击力上升200直到战斗阶段结束，并且若它还能继续攻击则追加减1次攻击。
function c33823832.caop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsFaceup() and tc:IsControler(tp) and tc:IsRelateToBattle() then
		-- 那只自己怪兽直到战斗阶段结束时攻击力上升200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
		if tc:IsChainAttackable() then
			-- 让那只自己怪兽可以再进行1次攻击，实现“只再1次可以继续攻击”的效果。
			Duel.ChainAttack()
		end
	end
end
