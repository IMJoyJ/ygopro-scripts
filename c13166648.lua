--双龍降臨
-- 效果：
-- 对方的超量怪兽的直接攻击宣言时才能发动。从额外卡组把1只龙族·光属性的超量怪兽表侧攻击表示特殊召唤，攻击对象转移为那只怪兽进行伤害计算。这个效果特殊召唤的怪兽的攻击力变成和攻击怪兽的攻击力相同数值，效果无效化。「双龙降临」在1回合只能发动1张。
function c13166648.initial_effect(c)
	-- 创建效果，设置为魔陷发动，攻击宣言时发动，限制1回合1次，条件为对方超量怪兽直接攻击且无攻击对象，目标为从额外卡组特殊召唤龙族光属性超量怪兽，效果为特殊召唤并转移攻击对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,13166648+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c13166648.condition)
	e1:SetTarget(c13166648.target)
	e1:SetOperation(c13166648.activate)
	c:RegisterEffect(e1)
end
-- 效果条件函数，判断是否满足发动条件
function c13166648.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 满足条件：攻击怪兽为超量怪兽、控制权属于对方、攻击对象为空
	return tc:IsType(TYPE_XYZ) and tc:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数，用于筛选可特殊召唤的龙族光属性超量怪兽
function c13166648.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
		-- 满足条件：可特殊召唤、场上存在足够召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果目标函数，设置发动时的处理信息
function c13166648.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：额外卡组存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c13166648.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：特殊召唤1只怪兽到自己场上
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动函数，处理效果的发动
function c13166648.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的1只额外卡组怪兽
	local g=Duel.SelectMatchingCard(tp,c13166648.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local ss=false
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 尝试特殊召唤所选怪兽到攻击表示
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		ss=true
		if a:IsRelateToBattle() and a:IsFaceup() then
			-- 设置特殊召唤怪兽的攻击力等于攻击怪兽的攻击力
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(a:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 使特殊召唤怪兽的效果无效化
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 使特殊召唤怪兽的怪兽效果无效化
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	if ss then
		-- 进行伤害计算，攻击怪兽对特殊召唤怪兽造成伤害
		Duel.CalculateDamage(a,tc)
	end
end
