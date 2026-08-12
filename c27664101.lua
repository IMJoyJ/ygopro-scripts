--リンク・リスタート
-- 效果：
-- ①：给与自己伤害的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效，从自己墓地选1只连接怪兽特殊召唤。
function c27664101.initial_effect(c)
	-- 创建效果，设置效果分类为使发动无效和特殊召唤，设置效果类型为发动，设置效果代码为连锁发动，设置效果属性为伤害步骤和伤害计算时可发动，设置发动条件为negcon函数，设置发动时点为negtg函数，设置发动效果为negop函数
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
-- 效果发动时的条件判断，检查连锁是否可无效，是否满足受到伤害的条件，且发动的卡为怪兽效果或魔法陷阱卡
function c27664101.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查连锁是否可无效，且满足受到伤害的条件
	return Duel.IsChainNegatable(ev) and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 过滤函数，筛选出可以特殊召唤的连接怪兽
function c27664101.filter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点处理函数，检查是否满足特殊召唤条件
function c27664101.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家墓地是否存在满足条件的连接怪兽
		and Duel.IsExistingMatchingCard(c27664101.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 设置操作信息为特殊召唤1只连接怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 发动效果处理函数，使连锁无效并特殊召唤连接怪兽
function c27664101.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁无效且玩家场上存在空位
	if Duel.NegateActivation(ev) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的连接怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27664101.filter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的连接怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
