--ゴブリンドバーグ
-- 效果：
-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
function c25259669.initial_effect(c)
	-- 效果原文：①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25259669,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c25259669.sumtg)
	e1:SetOperation(c25259669.sumop)
	c:RegisterEffect(e1)
end
-- 过滤函数：选择手卡中等级4以下且可以特殊召唤的怪兽
function c25259669.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时的条件判断：检查玩家场上是否有空位且手卡中是否存在满足条件的怪兽
function c25259669.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c25259669.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息：准备特殊召唤1只手卡中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：执行特殊召唤和可能的表示形式变更
function c25259669.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只手卡怪兽
		local g=Duel.SelectMatchingCard(tp,c25259669.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 执行特殊召唤操作并判断是否成功
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
			and c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
			-- 中断当前效果处理，使后续效果错开时点
			Duel.BreakEffect()
			-- 将自身从攻击表示变为守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
