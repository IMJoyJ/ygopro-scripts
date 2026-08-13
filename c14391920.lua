--ヘル・テンペスト
-- 效果：
-- ①：自己受到3000以上的战斗伤害时才能发动。双方的卡组·墓地的怪兽全部除外。
function c14391920.initial_effect(c)
	-- ①：自己受到3000以上的战斗伤害时才能发动。双方的卡组·墓地的怪兽全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(c14391920.condition)
	e1:SetTarget(c14391920.target)
	e1:SetOperation(c14391920.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：仅当自己受到3000以上的战斗伤害（伤害承受方为tp且伤害值不少于3000）时，效果才满足发动条件。
function c14391920.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and ev>=3000
end
-- 过滤函数：用于判断怪兽是否“不能除外”，即该怪兽为怪兽卡且IsAbleToRemove()为false；在发动检查时若存在这样的卡，则无法执行全部除外。
function c14391920.chkfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsAbleToRemove()
end
-- 过滤函数：用于选择可被除外的怪兽，即该怪兽为怪兽卡且IsAbleToRemove()为true。
function c14391920.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 效果发动前的目标合法性判定：确认范围内存在至少1只可除外的怪兽，且不存在不能除外的怪兽，然后设置除外处理的操作信息。
function c14391920.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 在以tp为视角的己方卡组/墓地及对方墓地中，检查是否存在至少1张满足filter的怪兽卡（即可被除外的怪兽）。
		return Duel.IsExistingMatchingCard(c14391920.filter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
			-- 同时确认在上述范围内不存在满足chkfilter的怪兽卡（即不存在不能被除外的怪兽），保证可以除外所有对象。
			and not Duel.IsExistingMatchingCard(c14391920.chkfilter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
	end
	-- 设置操作信息：将当前连锁处理标记为除外类别，预计除外1张卡，范围为tp的卡组和墓地（实际效果处理时会除外符合条件的全部怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理函数：收集双方卡组·墓地中所有可被除外的怪兽，并全部除外。
function c14391920.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得以tp视角看双方区域内（己方卡组/墓地与对方卡组/墓地）所有满足filter条件的怪兽，作为集合sg。
	local sg=Duel.GetMatchingGroup(c14391920.filter,tp,LOCATION_DECK+LOCATION_GRAVE,LOCATION_DECK+LOCATION_GRAVE,nil)
	-- 将集合sg中的全部怪兽以表侧表示除外，除外原因为效果（REASON_EFFECT）。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
