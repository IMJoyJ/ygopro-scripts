--浅すぎた墓穴
-- 效果：
-- 双方玩家选择各自墓地1只怪兽在各自场上里侧守备表示盖放。
function c43434803.initial_effect(c)
	-- 效果定义：将此卡注册为发动时点效果，可特殊召唤与盖放怪兽，且为取对象效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c43434803.target)
	e1:SetOperation(c43434803.operation)
	c:RegisterEffect(e1)
end
-- 效果过滤器函数：检查怪兽是否可以被特殊召唤（里侧守备表示）
function c43434803.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果目标选择函数：判断是否满足选择墓地怪兽并特殊召唤的条件
function c43434803.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		-- 判断玩家墓地是否存在满足条件的怪兽
		return Duel.IsExistingTarget(c43434803.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
			-- 判断玩家场上是否有足够的怪兽区域
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 判断对手墓地是否存在满足条件的怪兽
			and Duel.IsExistingTarget(c43434803.filter,1-tp,LOCATION_GRAVE,0,1,nil,e,1-tp)
			-- 判断对手场上是否有足够的怪兽区域
			and Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0
	end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择玩家墓地中的1只怪兽作为目标
	local sg=Duel.SelectTarget(tp,c43434803.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向对手提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对手墓地中的1只怪兽作为目标
	local og=Duel.SelectTarget(1-tp,c43434803.filter,1-tp,LOCATION_GRAVE,0,1,1,nil,e,1-tp)
	local sc=sg:GetFirst()
	local oc=og:GetFirst()
	local g=Group.FromCards(sc,oc)
	-- 设置效果操作信息，确定将要特殊召唤的2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
	e:SetLabelObject(sc)
end
-- 效果处理函数：执行特殊召唤与盖放操作
function c43434803.operation(e,tp,eg,ep,ev,re,r,rp)
	local sc=e:GetLabelObject()
	-- 获取当前连锁中指定的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local oc=g:GetFirst()
	if oc==sc then oc=g:GetNext() end
	if sc:IsRelateToEffect(e) then
		-- 将选择的玩家怪兽特殊召唤至玩家场上（里侧守备表示）
		Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	if oc:IsRelateToEffect(e) then
		-- 将选择的对手怪兽特殊召唤至对手场上（里侧守备表示）
		Duel.SpecialSummonStep(oc,0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
