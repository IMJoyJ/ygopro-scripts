--ボム・ガード
-- 效果：
-- 持有「把自己场上存在的1只怪兽破坏的效果」的卡发动时才能发动。那个发动无效并破坏。并且再给与对方基本分500分伤害。
function c88928798.initial_effect(c)
	-- 持有「把自己场上存在的1只怪兽破坏的效果」的卡发动时才能发动。那个发动无效并破坏。并且再给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c88928798.condition)
	e1:SetTarget(c88928798.target)
	e1:SetOperation(c88928798.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：验证触发效果是否为针对自己场上1只怪兽的破坏效果，且该发动可以被无效
function c88928798.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 过滤非怪兽效果或魔陷卡发动的连锁，并确认该连锁的发动能否被无效
	if not (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) or not Duel.IsChainNegatable(ev) then return false end
	-- 获取触发效果所选择的对象卡片组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local gc=g:GetFirst()
	if not gc:IsControler(tp) or not gc:IsLocation(LOCATION_MZONE) then return false end
	-- 获取触发效果中关于破坏操作的信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tg:GetCount()==1 and tg:GetFirst()==gc
end
-- 效果目标：注册无效、伤害以及破坏的操作信息，用于连锁检测
function c88928798.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向系统宣告此效果包含「使发动无效」的操作
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 向系统宣告此效果包含「给与对方500点伤害」的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若目标卡片可被破坏，向系统宣告此效果包含「破坏该卡」的操作
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：执行无效并破坏，随后给与对方伤害
function c88928798.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效，并确认该卡仍与效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动被无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
	-- 中断效果处理，用于划分「破坏」与「伤害」的步骤，使其不同时处理
	Duel.BreakEffect()
	-- 给与对方500点伤害
	Duel.Damage(1-tp,500,REASON_EFFECT)
end
