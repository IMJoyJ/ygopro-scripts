--ジャイアントマミー
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。里侧守备表示的这张卡受到攻击，攻击的怪兽的攻击力比这张卡的守备力低的场合，攻击的怪兽破坏。
function c78266168.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(78266168,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c78266168.target)
	e1:SetOperation(c78266168.operation)
	c:RegisterEffect(e1)
	-- 里侧守备表示的这张卡受到攻击，攻击的怪兽的攻击力比这张卡的守备力低的场合，攻击的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(78266168,1))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c78266168.descon)
	e2:SetTarget(c78266168.destg)
	e2:SetOperation(c78266168.desop)
	c:RegisterEffect(e2)
end
-- 变回里侧守备表示效果的发动准备，检查自身是否可以转为里侧守备表示且本回合未发动过该效果，并注册一回合一次的Flag标记
function c78266168.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(78266168)==0 end
	c:RegisterFlagEffect(78266168,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息，表示此效果包含改变表示形式的操作，对象为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变回里侧守备表示效果的实际处理，若自身仍在场上且表侧表示则转为里侧守备表示
function c78266168.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身改变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 破坏攻击怪兽效果的发动条件判断，需在伤害步骤结束时，自身作为里侧守备表示被攻击，且攻击怪兽的攻击力低于自身的守备力
function c78266168.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断伤害步骤结束时，自身是否作为被攻击对象参与了战斗
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttackTarget()==e:GetHandler()
		and e:GetHandler():GetBattlePosition()==POS_FACEDOWN_DEFENSE
		-- 判断进行攻击的怪兽的攻击力是否低于自身（巨大木乃伊）的守备力
		and Duel.GetAttacker():GetAttack()<e:GetHandler():GetDefense()
end
-- 破坏攻击怪兽效果的发动检测，此效果为必发效果，直接返回true并设置破坏操作信息
function c78266168.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示此效果会破坏1只进行攻击的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 破坏攻击怪兽效果的实际处理，若攻击怪兽仍与战斗相关联则将其破坏
function c78266168.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中进行攻击的怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToBattle() then return end
	-- 因效果破坏该攻击怪兽
	Duel.Destroy(a,REASON_EFFECT)
end
