--リンク・リスタート
-- 效果：
-- ①：给与自己伤害的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，从自己墓地选1只连接怪兽特殊召唤。
function c27664101.initial_effect(c)
	-- ①：给与自己伤害的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，从自己墓地选1只连接怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c27664101.negcon)
	e1:SetTarget(c27664101.negtg)
	e1:SetOperation(c27664101.negop)
	c:RegisterEffect(e1)
end
-- 该函数是效果的发动条件判定：检查当前连锁是否可被无效，且该连锁会给与己方伤害，并且发动来源为怪兽效果或魔法·陷阱卡的发动。
function c27664101.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前连锁的发动可被无效，并且本次连锁的伤害/恢复信息符合aux.damcon1所定义的“给自己造成伤害”条件。
	return Duel.IsChainNegatable(ev) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 定义特殊召唤候选卡的过滤条件：从自己墓地选择连接怪兽，并且该怪兽满足可被效果特殊召唤的限制。
function c27664101.filter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标判定：若己方主要怪兽区有空位且墓地存在满足条件的连接怪兽，则允许发动，并设置后续无效与特殊召唤的处理信息。
function c27664101.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点的检查中，确认己方主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在至少1只满足c27664101.filter条件（连接怪兽且可特殊召唤）的卡片。
		and Duel.IsExistingMatchingCard(c27664101.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次处理包含无效发动的效果，将当前连锁中的卡（eg）标记为无效对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息：本次处理包含特殊召唤，预计从自己墓地特殊召唤1只怪兽，因目标在处理时才确定，所以targets为nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理流程：先尝试无效对方的发动，若无效成功且己方主要怪兽区有空位，则从自己墓地选择1只连接怪兽进行特殊召唤。
function c27664101.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该连锁的发动是否被成功无效，并且己方主要怪兽区仍有可用空格。
	if Duel.NegateActivation(ev) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示，提示内容为“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足c27664101.filter且不受王家长眠之谷影响的连接怪兽作为特殊召唤对象。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27664101.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的连接怪兽以表侧表示特殊召唤到己方场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
