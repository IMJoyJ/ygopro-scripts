--EMチェーンジラフ
-- 效果：
-- ←5 【灵摆】 5→
-- ①：自己怪兽1只被战斗破坏时才能发动。这张卡破坏，那只战斗破坏的怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
-- 【怪兽效果】
-- ①：这张卡召唤·特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
function c69228245.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：自己怪兽1只被战斗破坏时才能发动。这张卡破坏，那只战斗破坏的怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69228245,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c69228245.spcon)
	e1:SetTarget(c69228245.sptg)
	e1:SetOperation(c69228245.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤成功时，以对方场上1只表侧表示怪兽为对象才能发动。这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽不能攻击，效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69228245,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c69228245.target)
	e2:SetOperation(c69228245.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤在自己场上被战斗破坏的怪兽
function c69228245.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- 检查是否恰好有1只自己场上的怪兽被战斗破坏
function c69228245.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:IsExists(c69228245.cfilter,1,nil,tp)
end
-- 灵摆效果发动的可行性检测，检查自身是否能被破坏、自己场上是否有空位，以及被破坏的怪兽是否能特殊召唤
function c69228245.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=eg:GetFirst()
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and tc and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置连锁处理信息：破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息：特殊召唤被战斗破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,tc,1,0,0)
end
-- 灵摆效果的处理：破坏自身，将被战斗破坏的怪兽攻击表示特殊召唤，并赋予其本回合不会被战斗破坏的耐性
function c69228245.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=eg:GetFirst()
	if c:IsRelateToEffect(e)
		-- 破坏自身，并确认是否破坏成功
		and Duel.Destroy(c,REASON_EFFECT)~=0
		-- 确认自己场上是否有可用于特殊召唤的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 将被战斗破坏的怪兽以表侧攻击表示特殊召唤，并确认是否特殊召唤成功
		and tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)~=0 then
		-- 这个效果特殊召唤的怪兽在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果发动的可行性检测与对象选择，选择对方场上1只表侧表示怪兽作为对象
function c69228245.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 检查对方场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：使对象怪兽的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 怪兽效果的处理：在这张卡表侧表示存在期间，使对象怪兽不能攻击且效果无效化
function c69228245.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 这只怪兽表侧表示存在期间，作为对象的表侧表示怪兽...效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c69228245.rcon)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		tc:RegisterEffect(e2)
	end
end
-- 检查自身（此卡）是否依然以对象怪兽为效果对象，用于维持“这只怪兽表侧表示存在期间”的持续性效果
function c69228245.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
