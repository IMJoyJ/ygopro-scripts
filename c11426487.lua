--花騎士団の白馬
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有2星以下的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：对方怪兽的攻击宣言时，把墓地的这张卡除外，以自己场上1张卡为对象才能发动。那次攻击无效，作为对象的卡破坏。
function c11426487.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有2星以下的怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
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
	-- 设置②效果的发动COST：把墓地的这张卡除外（aux.bfgcost封装了除外自身作为COST的处理）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c11426487.negtg)
	e2:SetOperation(c11426487.negop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡片是否为表侧表示且等级2以下，用于检索自己场上的2星以下怪兽。
function c11426487.spfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(2)
end
-- ①效果的特殊召唤条件：当这张卡在手牌时，若自己场上有2星以下的怪兽存在且主要怪兽区有空位，则可进行守备表示特殊召唤。
function c11426487.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区是否存在可用的空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1张2星以下的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c11426487.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动条件：当前攻击宣言的怪兽的控制者是对方。
function c11426487.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	return at:IsControler(1-tp)
end
-- ②效果的发动目标处理：选择自己场上1张卡作为对象，并设置破坏的操作信息。
function c11426487.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsOnField() end
	-- 效果发动时检查自己场上是否存在1张可作为对象的卡，以此判定能否发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示发动者选择要破坏的卡（显示“请选择要破坏的卡”的提示消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让发动者从自己场上选择1张卡作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 登记操作信息：要破坏1张卡（即选择的对象），供后续处理或相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：先无效攻击，若成功后且对象卡仍与效果关联，则将其破坏。
function c11426487.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断攻击是否被成功无效，且对象卡仍与该效果保持关联，若是则继续破坏处理。
	if Duel.NegateAttack() and tc:IsRelateToEffect(e) then
		-- 以效果原因破坏作为对象的卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
