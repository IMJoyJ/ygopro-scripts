--花騎士団の白馬
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星以下的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
function c11426487.initial_effect(c)
	-- ①：自己场上有2星以下的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,11426487+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c11426487.spcon)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11426487,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,11426487)
	e2:SetCondition(c11426487.negcon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c11426487.negtg)
	e2:SetOperation(c11426487.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在2星以下的怪兽
function c11426487.spfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(2)
end
-- 特殊召唤的条件函数，判断是否满足特殊召唤的条件
function c11426487.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己场上是否存在至少1只2星以下的怪兽
		and Duel.IsExistingMatchingCard(c11426487.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 攻击宣言时的触发条件函数，判断攻击方是否为对方
function c11426487.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次攻击的怪兽
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- 选择目标的函数，用于选择要破坏的场上卡片
function c11426487.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 检查是否至少存在1张可以成为效果对象的场上卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择一张自己场上的卡片作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果操作信息，指定要破坏的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，用于执行攻击无效和破坏效果
function c11426487.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 无效此次攻击并判断目标卡片是否仍然在场上
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
