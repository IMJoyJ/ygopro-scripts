--双龍降臨
-- 效果：
-- 对方的超量怪兽的直接攻击宣言时才能发动。从额外卡组把1只龙族·光属性的超量怪兽表侧攻击表示特殊召唤，攻击对象转移为那只怪兽进行伤害计算。这个效果特殊召唤的怪兽的攻击力变成和攻击怪兽的攻击力相同数值，效果无效化。「双龙降临」在1回合只能发动1张。
function c13166648.initial_effect(c)
	-- 对方的超量怪兽的直接攻击宣言时才能发动。从额外卡组把1只龙族·光属性的超量怪兽表侧攻击表示特殊召唤，攻击对象转移为那只怪兽进行伤害计算。这个效果特殊召唤的怪兽的攻击力变成和攻击怪兽的攻击力相同数值，效果无效化。「双龙降临」在1回合只能发动1张。
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
-- 发动条件函数：确认当前攻击宣言的怪兽是对方的超量怪兽，且该攻击为直接攻击，只有满足这些条件时本卡才能发动。
function c13166648.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断攻击宣言的怪兽必须同时满足：是超量怪兽、控制者为对方、攻击目标为空（直接攻击）。
	return tc:IsType(TYPE_XYZ) and tc:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 筛选可特殊召唤的怪兽：必须为龙族、光属性、超量怪兽，且能够以表侧攻击表示特殊召唤，并确认额外卡组的怪兽有可用特殊召唤区域。
function c13166648.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_XYZ)
		-- 进一步确认该怪兽可以被当前效果特殊召唤，并且从额外卡组特殊召唤时有空余的怪兽区域可用。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 目标选择函数：在发动时检查额外卡组是否存在符合条件的怪兽，若存在则登记本效果将进行特殊召唤的操作信息。
function c13166648.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：若额外卡组中至少有1张满足条件的怪兽，则本卡可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c13166648.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向系统登记操作信息，声明本效果将把1只额外卡组怪兽特殊召唤，供连锁与时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数：从额外卡组选择1只符合条件的怪兽以表侧攻击表示特殊召唤；特殊召唤成功且攻击怪兽仍然存在时，将召唤出的怪兽攻击力变为攻击怪兽的攻击力并使其效果无效化，然后进行伤害计算。
function c13166648.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动者显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动者从自己的额外卡组选择1张满足条件的龙族·光属性超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c13166648.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local ss=false
	-- 获取正在攻击宣言的对方怪兽，即那只直接攻击的超量怪兽。
	local a=Duel.GetAttacker()
	-- 将选择的怪兽以表侧攻击表示进行特殊召唤的中间步骤；若特殊召唤成功则继续后续处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		ss=true
		if a:IsRelateToBattle() and a:IsFaceup() then
			-- 这个效果特殊召唤的怪兽的攻击力变成和攻击怪兽的攻击力相同数值。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK)
			e1:SetValue(a:GetAttack())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 效果无效化。
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
	-- 完成特殊召唤处理，正式结算之前通过SpecialSummonStep进行的特殊召唤，并触发召唤成功相关时点。
	Duel.SpecialSummonComplete()
	if ss then
		-- 令攻击怪兽与特殊召唤的怪兽进行战斗伤害计算（即攻击对象转移为那只怪兽后的伤害计算）。
		Duel.CalculateDamage(a,tc)
	end
end
