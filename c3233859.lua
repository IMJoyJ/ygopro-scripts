--サイコウィールダー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「念力控轮人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：这张卡作为同调怪兽的同调素材送去墓地的场合，以持有比那只同调怪兽低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
function c3233859.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「念力控轮人」以外的3星怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,3233859+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c3233859.sprcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡作为同调怪兽的同调素材送去墓地的场合，以持有比那只同调怪兽低的攻击力的场上1只怪兽为对象才能发动。那只怪兽破坏。
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
-- 过滤条件：卡片须为表侧表示、等级为3、且不是「念力控轮人」（卡号3233859），用于①的特殊召唤条件检索。
function c3233859.sprfilter(c)
	return c:IsFaceup() and c:IsLevel(3) and not c:IsCode(3233859)
end
-- ①特性的特殊召唤规则条件判定：此卡在手牌时，若自己主要怪兽区有空位，且自己场上存在「念力控轮人」以外的表侧表示3星怪兽，则可作为规则特殊召唤。
function c3233859.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己主要怪兽区存在可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只满足过滤条件（表侧表示·等级3·不是「念力控轮人」）的怪兽。
		and Duel.IsExistingMatchingCard(c3233859.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 触发条件判定：此卡作为同调素材被送去墓地，且该次移动是由同调召唤（REASON_SYNCHRO）造成的，并且此卡当前位于墓地。
function c3233859.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 筛选出场上表侧表示且攻击力低于作为同调素材后同调召唤出的怪兽的攻击力（即攻击力≤atk-1）的怪兽，作为②的破坏候选对象。
function c3233859.desfilter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk-1)
end
-- ②的发动时的目标选择：获取这次同调召唤的同调怪兽当前攻击力，选择场上1只表侧表示且攻击力低于该数值的怪兽为对象（取对象），并设定操作信息为破坏。
function c3233859.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local atk=e:GetHandler():GetReasonCard():GetAttack()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c3233859.desfilter(chkc,atk) end
	-- 在效果发动时检查场上是否存在满足条件的可选对象（表侧表示且攻击力低于同调怪兽），若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c3233859.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,atk) end
	-- 向操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从符合条件的怪兽中选择1只，并将其登记为当前连锁的效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c3233859.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,atk)
	-- 设定本次效果的操作信息：将所选对象作为破坏对象（类别：破坏），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②的效果处理：取得对象，若对象仍与效果有关联则将其破坏。
function c3233859.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即发动时选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
