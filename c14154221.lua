--進化の代償
-- 效果：
-- 名字带有「进化虫」的怪兽的效果让怪兽特殊召唤的场合，可以选择场上1张卡破坏。这个效果1回合只能使用1次。
function c14154221.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 名字带有「进化虫」的怪兽的效果让怪兽特殊召唤的场合，可以选择场上1张卡破坏。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14154221,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c14154221.condition)
	e2:SetTarget(c14154221.target)
	e2:SetOperation(c14154221.operation)
	c:RegisterEffect(e2)
end
-- 筛选本次特殊召唤成功的怪兽：判断其召唤类型是否为进化虫（SUMMON_VALUE_EVOLTILE），或特殊召唤信息来源是否属于进化虫系列（0x304e），以确定是否符合“由名字带有「进化虫」的怪兽的效果特殊召唤”的条件。
function c14154221.cfilter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return c:IsSummonType(SUMMON_VALUE_EVOLTILE) or (typ&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x304e))
end
-- 检查本次特殊召唤成功的怪兽集合（eg）中是否存在至少1只满足上述“由进化虫效果特殊召唤”条件的怪兽。
function c14154221.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14154221.cfilter,1,nil)
end
-- 目标合法性检查：被选择的卡必须仍在场上；发动检查时，确认本卡不在连锁处理中，且场上存在至少1张可被选择为对象的卡。
function c14154221.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 在双方场上检查是否存在至少1张能够成为效果对象的卡片（不限定卡的种类）。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次连锁将破坏已选择的对象卡（数量为1），供其他卡片的效果互动与判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理阶段：取得发动时选择的对象卡，若它仍与效果保持关联，则将其破坏。
function c14154221.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
