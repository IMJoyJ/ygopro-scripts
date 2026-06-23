--レアル・ジェネクス・クロキシアン
-- 效果：
-- 「次世代」调整＋调整以外的暗属性怪兽1只以上
-- ①：这张卡同调召唤的场合发动。得到对方场上1只等级最高的怪兽的控制权。
function c38354937.initial_effect(c)
	-- 添加同调召唤手续，要求1只满足‘次世代’调整，以及1只满足‘暗属性’且非调整的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_DARK),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合发动。得到对方场上1只等级最高的怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38354937,0))  --"获得控制权"
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c38354937.ctcon)
	e1:SetOperation(c38354937.ctop)
	c:RegisterEffect(e1)
end
-- 效果发动的条件：确认此卡是以同调召唤方式特殊召唤成功
function c38354937.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的怪兽：必须是表侧表示且等级大于0
function c38354937.filter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 效果处理：检索对方场上所有满足条件的怪兽，选出等级最高的怪兽并获得其控制权
function c38354937.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索对方场上所有满足条件的怪兽
	local g=Duel.GetMatchingGroup(c38354937.filter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local sg=g:GetMaxGroup(Card.GetLevel)
	if sg:GetCount()>1 then
		-- 向玩家提示选择要改变控制权的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
		sg=sg:Select(tp,1,1,nil)
	end
	local tc=sg:GetFirst()
	-- 将目标怪兽的控制权转移给玩家
	Duel.GetControl(tc,tp)
end
