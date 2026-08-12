--A・O・J サウザンド・アームズ
-- 效果：
-- 这张卡可以向对方场上表侧表示存在的光属性怪兽各作1次攻击。和光属性以外的怪兽进行战斗的场合，那次伤害计算前这张卡破坏。
function c85876417.initial_effect(c)
	-- 这张卡可以向对方场上表侧表示存在的光属性怪兽各作1次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ATTACK_ALL)
	e1:SetValue(c85876417.atkfilter)
	c:RegisterEffect(e1)
	-- 和光属性以外的怪兽进行战斗的场合，那次伤害计算前这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85876417,0))  --"这张卡破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetTarget(c85876417.destg)
	e2:SetOperation(c85876417.desop)
	c:RegisterEffect(e2)
end
-- 过滤出表侧表示的光属性怪兽作为允许攻击的对象
function c85876417.atkfilter(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 伤害计算前效果的发动条件判定与操作信息设置，确认战斗对手是否为光属性以外的怪兽
function c85876417.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		-- 获取本次战斗的攻击怪兽
		local a=Duel.GetAttacker()
		-- 如果自身是攻击方，则将战斗对手设定为被攻击的怪兽
		if a==c then a=Duel.GetAttackTarget() end
		return a and a:IsNonAttribute(ATTRIBUTE_LIGHT)
	end
	-- 设置在效果处理时将破坏自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 伤害计算前效果的具体执行，若自身仍处于战斗中则将其破坏
function c85876417.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToBattle() then
		-- 将自身因效果破坏并送去墓地
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
