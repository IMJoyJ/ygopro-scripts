--A・O・J コアデストロイ
-- 效果：
-- 这张卡和光属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
function c36629203.initial_effect(c)
	-- 这张卡和光属性怪兽进行战斗的场合，不进行伤害计算把那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36629203,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c36629203.destg)
	e1:SetOperation(c36629203.desop)
	c:RegisterEffect(e1)
end
-- 目标函数：检查与这张卡战斗的怪兽是否为表侧表示光属性；若满足，登记破坏该怪兽的操作信息，并允许效果发动。
function c36629203.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是本卡，则将战斗对象改为攻击目标怪兽，从而取得与这张卡战斗的对方怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT) end
	-- 登记本次效果将破坏的对象（tc）及数量为1，用于系统判定连锁和效果处理。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 处理函数：效果处理时，重新确定与这张卡战斗的对方怪兽；若该怪兽仍与本次战斗关联，则将其破坏，从而不进行伤害计算。
function c36629203.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是本卡，则将战斗对象改为攻击目标怪兽，确定与这张卡战斗的对方怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	-- 若该怪兽仍与本次战斗关联，则将其以效果破坏；由于战斗对象已被破坏，本次战斗不再进行伤害计算。
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
