--誘発召喚
-- 效果：
-- 对方场上有怪兽特殊召唤时才能发动。双方可以从手卡把1只4星以下的怪兽在场上特殊召唤。
function c96148285.initial_effect(c)
	-- 对方场上有怪兽特殊召唤时才能发动。双方可以从手卡把1只4星以下的怪兽在场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c96148285.condition)
	e1:SetOperation(c96148285.activate)
	c:RegisterEffect(e1)
end
-- 检查特殊召唤的怪兽中是否存在对方场上的怪兽（满足发动条件）
function c96148285.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤手卡中等级4以下且可以特殊召唤的怪兽
function c96148285.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：双方玩家依次选择是否从手卡特殊召唤1只4星以下的怪兽
function c96148285.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取自己手卡中满足特殊召唤条件的怪兽
		local g=Duel.GetMatchingGroup(c96148285.filter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 若自己手卡有符合条件的怪兽，则询问自己是否进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(96148285,0)) then  --"是否要从手卡特殊召唤？"
			-- 提示自己选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(tp,1,1,nil):GetFirst()
			-- 执行自己怪兽的特殊召唤确定步骤（表侧表示）
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 检查对方场上是否有可用的怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,1-tp)>0 then
		-- 获取对方手卡中满足特殊召唤条件的怪兽
		local g=Duel.GetMatchingGroup(c96148285.filter,1-tp,LOCATION_HAND,0,nil,e,1-tp)
		-- 若对方手卡有符合条件的怪兽，则询问对方是否进行特殊召唤
		if g:GetCount()>0 and Duel.SelectYesNo(1-tp,aux.Stringid(96148285,0)) then  --"是否要从手卡特殊召唤？"
			-- 提示对方选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=g:Select(1-tp,1,1,nil):GetFirst()
			-- 执行对方怪兽的特殊召唤确定步骤（表侧表示）
			Duel.SpecialSummonStep(tc,0,1-tp,1-tp,false,false,POS_FACEUP)
		end
	end
	-- 同时完成双方怪兽的特殊召唤
	Duel.SpecialSummonComplete()
end
