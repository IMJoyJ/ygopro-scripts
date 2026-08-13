--A・O・J カタストル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡和暗属性以外的表侧表示怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
function c26593852.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽和1只以上调整以外的怪兽（均无额外限制），对应调整＋调整以外的怪兽1只以上的召唤条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡和暗属性以外的表侧表示怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26593852,0))  --"暗属性以外怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c26593852.destg)
	e1:SetOperation(c26593852.desop)
	c:RegisterEffect(e1)
end
-- 效果发动前的条件判定：先确定这张卡进行战斗的对方怪兽，若该怪兽为表侧表示且不是暗属性，则满足发动条件，并设定破坏那只怪兽的操作信息。
function c26593852.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在条件判定中获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽就是这张卡自身，则将战斗对象改为攻击目标，从而确定这张卡的对方战斗怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsNonAttribute(ATTRIBUTE_DARK) end
	-- 设定本次效果处理将破坏目标怪兽tc（数量为1），供系统进行破坏类效果的相关检测与判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果处理时的操作：确定这张卡的对方战斗怪兽，若其仍与本次战斗关联，则将其以效果破坏。
function c26593852.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是这张卡自身，则将对象改为攻击目标，以确定要破坏的对方怪兽。
	if tc==c then tc=Duel.GetAttackTarget() end
	-- 若目标怪兽仍与本次战斗相关（未因离场等原因解除关联），则将其以效果破坏。
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
