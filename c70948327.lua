--ナノブレイカー
-- 效果：
-- 这张卡攻击3星以下的表侧表示怪兽的场合，不进行伤害计算把那只怪兽直接破坏。
function c70948327.initial_effect(c)
	-- 这张卡攻击3星以下的表侧表示怪兽的场合，不进行伤害计算把那只怪兽直接破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70948327,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c70948327.destg)
	e1:SetOperation(c70948327.desop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动靶向（Target）函数，并检查发动条件：自身为攻击怪兽，且攻击目标存在、呈表侧表示、等级在3星以下并与本次战斗关联
function c70948327.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	-- 在检测阶段，判断攻击怪兽是否为这张卡自身
	if chk==0 then return Duel.GetAttacker()==e:GetHandler()
		and d~=nil and d:IsFaceup() and d:IsLevelBelow(3) and d:IsRelateToBattle() end
	-- 设置操作信息，表明此效果的处理为破坏1只攻击目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 定义效果的处理（Operation）函数，若攻击目标在处理时仍满足条件，则将其破坏
function c70948327.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击目标怪兽
	local d=Duel.GetAttackTarget()
	if d:IsRelateToBattle() and d:IsFaceup() and d:IsLevelBelow(3) then
		-- 将该攻击目标怪兽因效果破坏
		Duel.Destroy(d,REASON_EFFECT)
	end
end
