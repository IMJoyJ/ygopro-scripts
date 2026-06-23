--サイコウィールダー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「念力控轮人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：这张卡作为同调怪兽的同调素材送去墓地的场合，以持有比那只同调怪兽低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
function c3233859.initial_effect(c)
	-- ①：自己场上有「念力控轮人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,3233859+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c3233859.sprcon)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调怪兽的同调素材送去墓地的场合，以持有比那只同调怪兽低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3233859,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,3233860)
	e2:SetCondition(c3233859.descon)
	e2:SetTarget(c3233859.destg)
	e2:SetOperation(c3233859.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在除念力控轮人外的3星怪兽
function c3233859.sprfilter(c)
	return c:IsFaceup() and c:IsLevel(3) and not c:IsCode(3233859)
end
-- 判断特殊召唤条件是否满足：场上存在3星怪兽且有空位
function c3233859.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家场上是否存在除念力控轮人外的3星怪兽
		and Duel.IsExistingMatchingCard(c3233859.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断该卡是否作为同调素材被送去墓地
function c3233859.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于判断目标怪兽是否满足攻击力条件
function c3233859.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- 设置破坏效果的目标选择逻辑
function c3233859.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetReasonCard():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3233859.desfilter(chkc,atk) end
	-- 检查是否满足发动条件：场上存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c3233859.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c3233859.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	-- 设置连锁操作信息，记录将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果
function c3233859.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
