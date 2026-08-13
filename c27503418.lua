--王者の調和
-- 效果：
-- ①：对方怪兽向自己的同调怪兽攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。
-- ●那只自己的同调怪兽和自己墓地1只调整除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
function c27503418.initial_effect(c)
	-- ①：对方怪兽向自己的同调怪兽攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。●那只自己的同调怪兽和自己墓地1只调整除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c27503418.condition)
	e1:SetTarget(c27503418.target)
	e1:SetOperation(c27503418.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：对方怪兽向自己的同调怪兽攻击宣言，且攻击对象表侧表示、由自己控制且为同调怪兽。
function c27503418.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言中被攻击的怪兽，即自己的那只同调怪兽。
	local tc=Duel.GetAttackTarget()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and tc:IsType(TYPE_SYNCHRO)
end
-- 发动时目标处理：效果可以发动时，将攻击对象设为与本次效果关联的对象。
function c27503418.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前攻击对象设置为该连锁的关联对象，用于后续确认其与效果仍有联系。
	Duel.SetTargetCard(Duel.GetAttackTarget())
end
-- 从额外卡组筛选可特殊召唤的同调怪兽：其等级需高于被攻击的同调怪兽，能以同调召唤方式特殊召唤，除外被攻击怪兽后仍有额外怪兽区域可用，且墓地存在等级差对应的调整作为素材。
function c27503418.filter1(c,e,tp,tc)
	local rlv=c:GetLevel()-tc:GetLevel()
	return rlv>0 and c:IsType(TYPE_SYNCHRO)
		-- 确认该同调怪兽能够作为同调召唤进行特殊召唤，且除外被攻击怪兽后自己场上仍有足够的额外怪兽空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,tc,c)>0
		-- 确认自己墓地存在1只等级等于差值的调整怪兽，可供一并除外。
		and Duel.IsExistingMatchingCard(c27503418.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,rlv)
end
-- 从墓地筛选符合条件的调整怪兽：等级等于指定差值，且可以被除外。
function c27503418.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	return rlv==0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 效果处理：先无效攻击；若攻击对象仍与该效果关联、可被除外且不免疫此效果，同时没有必须作为特定同调素材的限制，额外卡组也有符合条件的同调怪兽，则询问玩家是否适用后续特殊召唤；适用后中断当前效果处理，选择额外同调怪兽和墓地调整，连同攻击对象一并除外，并将该额外怪兽作为同调召唤特殊召唤并完成正规手续。
function c27503418.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽，即自己那只可能被除外的同调怪兽。
	local tc=Duel.GetAttackTarget()
	-- 无效攻击，并确认攻击对象仍与该效果保持关联，可以继续作为除外对象。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e)
		and tc:IsAbleToRemove() and not tc:IsImmuneToEffect(e)
		-- 确认自己场上或手牌等不存在“必须作为同调素材”的限制效果，保证可以正常进行后续的素材选择。
		and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 确认额外卡组中存在1只满足条件的同调怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c27503418.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp,tc)
		-- 询问玩家是否适用后续效果，即是否除外怪兽并从额外卡组特殊召唤同调怪兽。
		and Duel.SelectYesNo(tp,aux.Stringid(27503418,0)) then  --"是否把同调怪兽特殊召唤？"
		-- 中断当前效果处理，使后续特殊召唤视为另一次独立处理，避免造成时点遗漏。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要特殊召唤的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合filter1条件的同调怪兽作为特殊召唤对象。
		local g1=Duel.SelectMatchingCard(tp,c27503418.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
		local lv=g1:GetFirst():GetLevel()-tc:GetLevel()
		-- 向玩家显示“请选择要除外的卡”的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从自己墓地选择1只等级等于所需差值的调整怪兽作为除外素材。
		local g2=Duel.SelectMatchingCard(tp,c27503418.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		g2:AddCard(tc)
		-- 将被攻击的同调怪兽和选择的调整怪兽以表侧表示除外。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		g1:GetFirst():SetMaterial(nil)
		-- 将选择的额外同调怪兽以同调召唤方式特殊召唤到自己场上，视为同调召唤。
		Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		g1:GetFirst():CompleteProcedure()
	end
end
