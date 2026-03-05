--SRメンコート
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤，对方场上的表侧表示怪兽全部变成守备表示。
function c16947147.initial_effect(c)
	-- 效果原文内容：①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡攻击表示特殊召唤，对方场上的表侧表示怪兽全部变成守备表示。
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
-- 效果作用：判断是否满足发动条件，即对方怪兽直接攻击且无攻击目标
function c16947147.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：确认攻击方不是自己且攻击目标为空
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 效果作用：定义过滤函数，用于筛选表侧攻击表示且可以改变表示形式的怪兽
function c16947147.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 效果作用：设置发动时的处理目标，检查是否有满足条件的怪兽可特殊召唤及场上是否有空位
function c16947147.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查对方场上是否存在至少1只表侧攻击表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c16947147.filter,tp,0,LOCATION_MZONE,1,nil)
		-- 效果作用：检查自己场上是否有足够的怪兽区域用于特殊召唤，并确认此卡可攻击表示特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 效果作用：获取对方场上所有满足条件的表侧攻击表示怪兽组成组
	local g=Duel.GetMatchingGroup(c16947147.filter,tp,0,LOCATION_MZONE,nil)
	-- 效果作用：设置操作信息，声明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 效果作用：设置操作信息，声明将要改变对方场上满足条件的怪兽表示形式为守备表示
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果作用：执行效果处理，先判断此卡是否还在场上，然后进行特殊召唤，若成功则改变对方场上怪兽表示形式
function c16947147.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 效果作用：执行特殊召唤操作，以攻击表示召唤此卡到自己场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 效果作用：再次获取对方场上所有满足条件的表侧攻击表示怪兽组成组
		local g=Duel.GetMatchingGroup(c16947147.filter,tp,0,LOCATION_MZONE,nil)
		-- 效果作用：将对方场上所有满足条件的怪兽改变为守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
