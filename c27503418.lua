--王者の調和
-- 效果：
-- ①：对方怪兽向自己的同调怪兽攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。
-- ●那只自己的同调怪兽和自己墓地1只调整除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
function c27503418.initial_effect(c)
	-- 效果定义：发动条件为对方怪兽向自己的同调怪兽攻击宣言时，发动后使该次攻击无效，并可适用后续效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c27503418.condition)
	e1:SetTarget(c27503418.target)
	e1:SetOperation(c27503418.activate)
	c:RegisterEffect(e1)
end
-- 条件判断：攻击目标存在且为正面表示、控制者为自己、类型为同调怪兽。
function c27503418.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽。
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsType(TYPE_SYNCHRO)
end
-- 目标设定：设置当前攻击目标为效果处理对象。
function c27503418.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前攻击目标为连锁处理对象。
	Duel.SetTargetCard(Duel.GetAttackTarget())
end
-- 过滤函数1：筛选满足等级差、类型为同调、可特殊召唤、有足够召唤位置、墓地存在对应调整的额外卡组怪兽。
function c27503418.filter1(c,e,tp,tc)
	local rlv=c:GetLevel()-tc:GetLevel()
	return rlv>0 and c:IsType(TYPE_SYNCHRO)
		-- 检查目标怪兽是否可特殊召唤且场上存在召唤空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
		-- 检查自己墓地是否存在满足等级差的调整。
		and Duel.IsExistingMatchingCard(c27503418.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,rlv)
end
-- 过滤函数2：筛选墓地中的调整，其等级与所需等级差相等。
function c27503418.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	return rlv==0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 效果发动处理：无效攻击并进行后续处理，包括选择特殊召唤的同调怪兽和除外的调整。
function c27503418.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击目标怪兽。
	local tc=Duel.GetAttackTarget()
	-- 无效攻击并确认目标怪兽有效。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e)
		and tc:IsAbleToRemove() and not tc:IsImmuneToEffect(e)
		-- 检查是否满足作为同调素材的条件。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在满足条件的同调怪兽。
		and Duel.IsExistingMatchingCard(c27503418.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
		-- 询问玩家是否发动特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(27503418,0)) then  --"是否把同调怪兽特殊召唤？"
		-- 中断当前效果处理，避免错时点。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只额外卡组同调怪兽。
		local g1=Duel.SelectMatchingCard(tp,c27503418.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local lv=g1:GetFirst():GetLevel()-tc:GetLevel()
		-- 提示玩家选择要除外的调整。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的1只墓地调整。
		local g2=Duel.SelectMatchingCard(tp,c27503418.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		g2:AddCard(tc)
		-- 将选中的怪兽和调整除外。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		g1:GetFirst():SetMaterial(nil)
		-- 将选中的同调怪兽特殊召唤。
		Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		g1:GetFirst():CompleteProcedure()
	end
end
