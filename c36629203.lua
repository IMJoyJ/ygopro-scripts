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
-- 检查攻击怪兽是否为光属性怪兽，是则设置破坏目标
function c36629203.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自己，则获取防守怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsAttribute(ATTRIBUTE_LIGHT) end
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行破坏效果，将符合条件的光属性怪兽破坏
function c36629203.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自己，则获取防守怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	-- 确认怪兽仍在战斗中后将其破坏
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
