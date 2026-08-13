--ジュラック・メテオ
-- 效果：
-- 「朱罗纪」调整＋调整以外的恐龙族怪兽2只以上
-- ①：这张卡同调召唤的场合发动。场上的卡全部破坏。那之后，可以从自己墓地把1只调整特殊召唤。
function c17548456.initial_effect(c)
	-- 为这张卡添加同调召唤手续：1只「朱罗纪」调整（字段0x22）＋2只以上调整以外的恐龙族怪兽。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x22),aux.NonTuner(Card.IsRace,RACE_DINOSAUR),2)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合发动。场上的卡全部破坏。那之后，可以从自己墓地把1只调整特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17548456,0))  --"破坏并特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c17548456.descon)
	e1:SetTarget(c17548456.destg)
	e1:SetOperation(c17548456.desop)
	c:RegisterEffect(e1)
end
-- 发动条件：这张卡是否为同调召唤成功，对应“这张卡同调召唤的场合发动”。
function c17548456.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 发动时先判断能否发动（无卡数限制必发），并将场上所有卡预写入破坏的操作信息，用于连锁确认。
function c17548456.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得双方场上所有卡（怪兽区＋魔法陷阱区）作为处理时可能被破坏的对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将当前连锁的操作信息设为：破坏对象为场上全部卡，数量为全部卡数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 墓地特殊召唤的过滤条件：选择的卡必须是调整怪兽，且能够被此效果特殊召唤（不检查苏生限制）。
function c17548456.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：破坏场上全部卡；如果破坏成功且墓地有符合条件的调整，则询问是否特殊召唤1只调整；是则从墓地特殊召唤。
function c17548456.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时重新取得双方场上所有卡，确保破坏对象是效果处理时场上的全部卡（不取对象）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 若实际破坏卡数不为0，且自己墓地存在1只符合条件的调整怪兽（不受王家长眠之谷影响），且玩家确认特殊召唤，则继续后续处理。
		if Duel.Destroy(g,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c17548456.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(17548456,1)) then  --"是否要特殊召唤一只调整？"
			-- 中断当前效果处理，使后续特殊召唤成为不同时点处理，避免造成时点遗漏。
			Duel.BreakEffect()
			-- 从自己墓地中选出所有满足特殊召唤条件且不受王家长眠之谷影响的调整怪兽作为候选。
			local sg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c17548456.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
			-- 向玩家显示选择消息提示，请选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sp=sg:Select(tp,1,1,nil)
			-- 将选择的调整怪兽以表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
			Duel.SpecialSummon(sp,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
