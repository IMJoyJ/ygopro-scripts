--王魂調和
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。
-- ●等级合计最多到8以下为止，从自己墓地选调整1只和调整以外的怪兽任意数量除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
function c24590232.initial_effect(c)
	-- 创建效果，设置为魔陷发动，攻击宣言时发动，无效攻击，之后可以适用以下效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c24590232.condition)
	e1:SetOperation(c24590232.activate)
	c:RegisterEffect(e1)
end
-- 效果条件：对方怪兽直接攻击宣言时
function c24590232.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击方为对方，且没有攻击目标
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤函数：检查额外卡组中满足条件的同调怪兽
function c24590232.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsType(TYPE_SYNCHRO) and lv<9
		-- 满足同调召唤条件且场上空位足够
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 检查墓地是否存在满足条件的调整和非调整怪兽
		and Duel.IsExistingMatchingCard(c24590232.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,lv)
end
-- 过滤函数：检查墓地中满足条件的调整怪兽
function c24590232.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	-- 获取墓地中所有非调整怪兽
	local rg=Duel.GetMatchingGroup(c24590232.filter3,tp,LOCATION_GRAVE,0,c)
	return rlv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,63)
end
-- 过滤函数：检查墓地中满足条件的非调整怪兽
function c24590232.filter3(c)
	return c:GetLevel()>0 and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 发动效果：无效攻击并进行后续处理
function c24590232.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效攻击并检查是否满足同调素材条件
	if Duel.NegateAttack() and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 检查额外卡组是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(c24590232.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 询问玩家是否发动特殊召唤
		and Duel.SelectYesNo(tp,aux.Stringid(24590232,0)) then  --"是否要把同调怪兽特殊召唤？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的同调怪兽
		local g1=Duel.SelectMatchingCard(tp,c24590232.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local lv=g1:GetFirst():GetLevel()
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的调整怪兽
		local g2=Duel.SelectMatchingCard(tp,c24590232.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		local rlv=lv-g2:GetFirst():GetLevel()
		-- 获取墓地中所有非调整怪兽用于后续计算
		local rg=Duel.GetMatchingGroup(c24590232.filter3,tp,LOCATION_GRAVE,0,g2:GetFirst())
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,63)
		g2:Merge(g3)
		-- 将选中的卡除外
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		g1:GetFirst():SetMaterial(nil)
		-- 将选中的同调怪兽特殊召唤
		Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		g1:GetFirst():CompleteProcedure()
	end
end
