--進化の代償
-- 效果：
-- 名字带有「进化虫」的怪兽的效果让怪兽特殊召唤的场合，可以选择场上1张卡破坏。这个效果1回合只能使用1次。
function c14154221.initial_effect(c)
	-- 卡片效果初始化，设置为自由连锁时点发动
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
-- 判断特殊召唤的怪兽是否为进化虫或通过特殊召唤Set的怪兽
function c14154221.cfilter(c)
	local typ=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE)
	return c:IsSummonType(SUMMON_VALUE_EVOLTILE) or (typ&TYPE_MONSTER~=0 and c:IsSpecialSummonSetCard(0x304e))
end
-- 判断是否有满足条件的怪兽被特殊召唤
function c14154221.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c14154221.cfilter,1,nil)
end
-- 设置选择目标的处理函数
function c14154221.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 检查是否满足发动条件，场上存在可破坏的卡片
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发送选择破坏卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择场上一张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置效果发动后的处理函数
function c14154221.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
