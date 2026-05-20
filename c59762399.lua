--EMオッドアイズ・ライトフェニックス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：另一边的自己的灵摆区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
-- 【怪兽效果】
-- ①：把这张卡解放，以自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
function c59762399.initial_effect(c)
	-- 启用灵摆怪兽的灵摆召唤和灵摆卡发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域有卡存在的场合，对方怪兽的直接攻击宣言时才能发动。另一边的自己的灵摆区域的卡破坏，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59762399,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c59762399.spcon)
	e1:SetTarget(c59762399.sptg)
	e1:SetOperation(c59762399.spop)
	c:RegisterEffect(e1)
	-- ①：把这张卡解放，以自己场上1只「娱乐伙伴」怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1000。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59762399,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤可以发动，但限制在伤害计算后不能发动。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c59762399.atkcost)
	e2:SetTarget(c59762399.atktg)
	e2:SetOperation(c59762399.atkop)
	c:RegisterEffect(e2)
end
-- 灵摆效果的发动条件判定函数。
function c59762399.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 判定是否为对方怪兽发动的直接攻击。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 判定自己的另一边灵摆区域是否存在卡片。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_PZONE,0,1,e:GetHandler())
end
-- 灵摆效果的发动目标与合法性检测函数。
function c59762399.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取自己另一边灵摆区域的卡片。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 判定自己场上是否有空余怪兽区域，且自身是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：包含破坏另一边灵摆区域卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置连锁处理信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 灵摆效果的执行函数。
function c59762399.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取自己另一边灵摆区域的卡片。
	local tc=Duel.GetFirstMatchingCard(nil,tp,LOCATION_PZONE,0,c)
	-- 若另一边的卡片存在，则将其破坏，并判定是否破坏成功。
	if tc and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 将自身特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 怪兽效果的发动代价判定与执行函数。
function c59762399.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果发动的代价。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：自己场上表侧表示的「娱乐伙伴」怪兽。
function c59762399.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9f)
end
-- 怪兽效果的发动目标选择与合法性检测函数。
function c59762399.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c59762399.atkfilter(chkc) end
	-- 判定自己场上是否存在除自身以外的、满足条件的「娱乐伙伴」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c59762399.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「娱乐伙伴」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c59762399.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁处理信息：包含改变攻击力的操作。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 怪兽效果的执行函数。
function c59762399.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 那只怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
end
