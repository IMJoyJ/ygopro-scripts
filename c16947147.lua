--SRメンコート
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤，对方场上的表侧表示怪兽全部变成守备表示。
function c16947147.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤，对方场上的表侧表示怪兽全部变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16947147,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16947147.spcon)
	e1:SetTarget(c16947147.sptg)
	e1:SetOperation(c16947147.spop)
	c:RegisterEffect(e1)
end
-- 定义效果发动条件函数：在攻击宣言时，检查是否满足对方怪兽直接攻击的发动条件。
function c16947147.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽的控制者不是自己（即对方），且攻击目标为空（直接攻击）。
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 定义对方场上表侧攻击表示且可以被变更表示形式的怪兽的过滤器，用于后续选择/检索目标。
function c16947147.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 定义效果发动时的目标选择函数：确认满足发动条件（对方有符合条件的怪兽、自己场上有空位、此卡可特殊召唤），并设置操作信息。
function c16947147.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查对方场上是否存在至少1只符合条件的表侧攻击表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c16947147.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 同时检查自己主要怪兽区有空位，且这张手卡能够以表侧攻击表示特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 在发动时获取对方场上所有符合条件的表侧攻击表示怪兽，作为后续变更表示形式的集合。
	local g=Duel.GetMatchingGroup(c16947147.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：本次效果包含特殊召唤，对象为此卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果包含变更表示形式，对象为g中的怪兽，数量为g的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 定义效果处理函数：执行特殊召唤和变更表示形式的实际处理。
function c16947147.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 尝试将此卡以表侧攻击表示特殊召唤到自己场上；若特殊召唤成功，则继续执行后续变更表示形式的处理。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 特殊召唤成功后，重新获取对方场上所有符合条件的表侧攻击表示怪兽（处理时可能发生变化）。
		local g=Duel.GetMatchingGroup(c16947147.filter,tp,0,LOCATION_MZONE,nil)
		-- 将获取到的对方怪兽全部变更为表侧守备表示。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
