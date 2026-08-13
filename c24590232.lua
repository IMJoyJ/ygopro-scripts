--王魂調和
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。
-- ●等级合计最多到8以下为止，从自己墓地选调整1只和调整以外的怪兽任意数量除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
function c24590232.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。那次攻击无效。那之后，以下效果可以适用。●等级合计最多到8以下为止，从自己墓地选调整1只和调整以外的怪兽任意数量除外，把持有和除外的怪兽的等级合计相同等级的1只同调怪兽从额外卡组当作同调召唤作特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c24590232.condition)
	e1:SetOperation(c24590232.activate)
	c:RegisterEffect(e1)
end
-- 该函数判断效果能否发动的条件：攻击宣言的怪兽是对方怪兽且没有攻击目标（即对方怪兽直接攻击宣言）。
function c24590232.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回条件：攻击怪兽由对方控制且攻击目标不存在，满足直接攻击宣言的判定。
	return eg:GetFirst():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 筛选额外卡组可被选择为同调召唤对象的同调怪兽：必须是同调怪兽、等级8以下、能用同调召唤方式特殊召唤、额外怪兽区域有空位，并且墓地存在至少一组可供除外以达成该等级的调整与非调整素材组合。
function c24590232.filter1(c,e,tp)
	local lv=c:GetLevel()
	return c:IsType(TYPE_SYNCHRO) and lv<9
		-- 追加筛选条件：该同调怪兽可以当作同调召唤特殊召唤，且从额外卡组特殊召唤到场上时有可用空格。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		-- 追加筛选条件：墓地存在至少1张调整怪兽，且能与非调整怪兽组合出与该同调怪兽等级相同的合计等级（详见filter2）。
		and Duel.IsExistingMatchingCard(c24590232.filter2,tp,LOCATION_GRAVE,0,1,nil,tp,lv)
end
-- 筛选可作为同调素材的调整怪兽：必须是调整、可以除外、其等级低于目标同调怪兽等级，并且墓地存在足够其他非调整怪兽，其等级合计能补足剩余等级。
function c24590232.filter2(c,tp,lv)
	local rlv=lv-c:GetLevel()
	-- 取得墓地中除该调整怪兽以外、所有可作为非调整素材的怪兽集合，用于后续的子集求和。
	local rg=Duel.GetMatchingGroup(c24590232.filter3,tp,LOCATION_GRAVE,0,c)
	return rlv>0 and c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
		and rg:CheckWithSumEqual(Card.GetLevel,rlv,1,63)
end
-- 定义非调整同调素材的筛选条件：等级大于0、不是调整怪兽、可以被除外。
function c24590232.filter3(c)
	return c:GetLevel()>0 and not c:IsType(TYPE_TUNER) and c:IsAbleToRemove()
end
-- 效果处理函数：先无效直接攻击，确认满足“必须作为同调素材”的制约且额外存在可同调怪兽，经玩家同意后，选择同调怪兽与其素材，除外素材并按同调召唤特殊召唤该怪兽。
function c24590232.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效对方攻击，并确认没有“必须作为同调素材”的限制导致无法从墓地选用素材；若攻击无效失败或素材受限则不能后续处理。
	if Duel.NegateAttack() and aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_SMATERIAL)
		-- 追加判断额外卡组是否存在符合条件的同调怪兽，供后续选择。
		and Duel.IsExistingMatchingCard(c24590232.filter1,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		-- 向玩家确认是否适用“等级合计最多8以下，除外墓地怪兽并同调召唤”的后续效果。
		and Duel.SelectYesNo(tp,aux.Stringid(24590232,0)) then  --"是否要把同调怪兽特殊召唤？"
		-- 中断当前效果处理，使无效攻击与后续同调召唤分属不同时点，避免引起时点遗漏。
		Duel.BreakEffect()
		-- 显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只符合条件的同调怪兽，作为将要特殊召唤的对象。
		local g1=Duel.SelectMatchingCard(tp,c24590232.filter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
		local lv=g1:GetFirst():GetLevel()
		-- 显示“请选择要除外的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从墓地选择1只符合条件的调整怪兽，作为同调素材之一。
		local g2=Duel.SelectMatchingCard(tp,c24590232.filter2,tp,LOCATION_GRAVE,0,1,1,nil,tp,lv)
		local rlv=lv-g2:GetFirst():GetLevel()
		-- 取得墓地中除已选调整外、可作为补充等级的非调整怪兽集合。
		local rg=Duel.GetMatchingGroup(c24590232.filter3,tp,LOCATION_GRAVE,0,g2:GetFirst())
		-- 再次显示“请选择要除外的卡”的选择提示，用于选择非调整素材。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local g3=rg:SelectWithSumEqual(tp,Card.GetLevel,rlv,1,63)
		g2:Merge(g3)
		-- 将选中的所有素材（调整+非调整）以表侧表示除外，作为同调召唤的代价。
		Duel.Remove(g2,POS_FACEUP,REASON_EFFECT)
		g1:GetFirst():SetMaterial(nil)
		-- 将所选同调怪兽以同调召唤的方式特殊召唤到控制者场上，表示形式为表侧表示（此处视为同调召唤）。
		Duel.SpecialSummon(g1,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)
		g1:GetFirst():CompleteProcedure()
	end
end
