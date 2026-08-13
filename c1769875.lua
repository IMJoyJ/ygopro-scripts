--幻獣王キマイラ
-- 效果：
-- 兽族怪兽＋恶魔族怪兽
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用。
-- ②：这张卡融合召唤的场合才能发动。这个回合的结束阶段把对方手卡随机1张送去墓地。
-- ③：对方回合把墓地的这张卡除外，以自己墓地1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化函数：设置融合召唤的苏生限制，融合素材为兽族怪兽+恶魔族怪兽，赋予场上·墓地视为「有翼幻兽 奇美拉」的卡名效果（①），并注册②效果（融合召唤成功时在结束阶段随机送对方手卡）与③效果（对方回合除外自身特殊召唤墓地兽·恶魔·幻想魔族怪兽）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 融合召唤手续：兽族怪兽＋恶魔族怪兽（即融合素材各1只兽族、恶魔族怪兽）。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST),aux.FilterBoolFunction(Card.IsRace,RACE_FIEND),true)
	-- ①效果：这张卡的卡名只要在场上·墓地存在当作「有翼幻兽 奇美拉」使用；该行通过aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)注册此变更卡名效果。
	aux.EnableChangeCode(c,4796100,LOCATION_GRAVE+LOCATION_MZONE)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡融合召唤的场合才能发动。这个回合的结束阶段把对方手卡随机1张送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.tgcon)
	e1:SetOperation(s.regop)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。③：对方回合把墓地的这张卡除外，以自己墓地1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	-- 设置③效果的发动代价：把墓地的这张卡除外（aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件：该卡是融合召唤成功的场合（IsSummonType(SUMMON_TYPE_FUSION)）。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②效果发动后注册一个结束阶段的持续效果，使这个回合的结束阶段执行随机送对方手卡的处理。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡融合召唤的场合才能发动。这个回合的结束阶段把对方手卡随机1张送去墓地。③：对方回合把墓地的这张卡除外，以自己墓地1只兽族·恶魔族·幻想魔族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(s.tgop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新创建的结束阶段触发效果e1注册到场上，属于tp方，使其在结束阶段时触发。
	Duel.RegisterEffect(e1,tp)
end
-- ②效果的结束阶段处理：从对方手卡随机选取1张，若存在则将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 以HINT_CARD提示双方，展示本卡的发动动画（用于不入连锁的结束阶段处理提示）。
	Duel.Hint(HINT_CARD,0,id)
	-- 取得对方手卡全体，并由tp方从中随机选择1张（RandomSelect），返回所选卡的Group。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	if #g>0 then
		-- 将随机选中的那张卡以效果原因（REASON_EFFECT）送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 定义③效果的发动条件：当前必须是对方回合（Duel.GetTurnPlayer()==1-tp）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是本卡效果的发动者（即对手回合），则该条件成立。
	return Duel.GetTurnPlayer()==1-tp
end
-- ③效果的目标筛选条件：自己墓地的兽族·恶魔族·幻想魔族怪兽，并且可以被tp玩家效果特殊召唤（结合nocheck/nolimit为false）。
function s.filter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_FIEND+RACE_ILLUSION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动合法性与对象检查：若chkc为真则验证所选对象是己方墓地的合格怪兽；若chk==0则检查场上是否有空位且墓地是否存在可选对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 发动时检查自己怪兽区域是否有足够的空格用于特殊召唤（Duel.GetLocationCount）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己墓地是否存在至少1只除自身外满足s.filter且可选择为对象的兽族·恶魔族·幻想魔族怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向tp玩家显示“请选择要特殊召唤的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让tp玩家从自己墓地选择1只满足条件的怪兽作为效果对象，并将其登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本效果将在处理时把目标g特殊召唤，供其他连锁（如星尘龙等）进行响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③效果处理：取得目标怪兽，若目标仍与效果e关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中通过③效果选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果e保持关联，则将其以表侧表示特殊召唤到tp场上；否则不处理。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
