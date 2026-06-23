--星遺物からの目醒め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：用自己场上的怪兽为素材把1只连接怪兽连接召唤。
function c12989604.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12989604+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12989604.target)
	e1:SetOperation(c12989604.activate)
	c:RegisterEffect(e1)
end
-- 检查额外卡组中是否存在可以连接召唤的怪兽
function c12989604.filter(c)
	return c:IsLinkSummonable(nil)
end
-- ①：用自己场上的怪兽为素材把1只连接怪兽连接召唤。
function c12989604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足效果发动条件，即额外卡组中是否存在可连接召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c12989604.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁处理信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理函数
function c12989604.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组中选择一张满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c12989604.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 使用选中的怪兽进行连接召唤
		Duel.LinkSummon(tp,tc,nil)
	end
end
