--星遺物からの目醒め
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：用自己场上的怪兽为素材把1只连接怪兽连接召唤。
function c12989604.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：用自己场上的怪兽为素材把1只连接怪兽连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,12989604+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c12989604.target)
	e1:SetOperation(c12989604.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：判断额外卡组中的怪兽是否可以不额外指定素材组，仅用自己场上的怪兽作为素材来进行连接召唤。
function c12989604.filter(c)
	return c:IsLinkSummonable(nil)
end
-- 发动时的目标设定与合法性检查：确认额外卡组存在可进行连接召唤的连接怪兽，并登记本次效果处理涉及特殊召唤的操作信息。
function c12989604.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动判定：若额外卡组中存在满足c12989604.filter条件的连接怪兽，则效果满足发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c12989604.filter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 登记操作信息：向系统声明本连锁将进行1次特殊召唤，由于具体选择的卡要到处理时才确定，因此目标暂设为nil，玩家和位置参数用0表示未知/通用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：让玩家从额外卡组选择1只符合条件的连接怪兽，然后使用自己场上的怪兽作为素材将其连接召唤。
function c12989604.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家显示“请选择要特殊召唤的卡”的提示文字，并进入选择卡片状态。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中筛选出满足c12989604.filter条件的连接怪兽，让玩家从中选择1张。
	local g=Duel.SelectMatchingCard(tp,c12989604.filter,tp,LOCATION_EXTRA,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的连接怪兽以自己场上的怪兽为素材进行连接召唤（素材组为nil时由系统自动选取符合连接召唤条件的素材）。
		Duel.LinkSummon(tp,tc,nil)
	end
end
