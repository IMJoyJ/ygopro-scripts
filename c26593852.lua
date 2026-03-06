--A・O・J カタストル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡和暗属性以外的表侧表示怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
function c26593852.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽进行同调
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
-- 设置效果目标函数，判断攻击怪兽是否为表侧表示且非暗属性
function c26593852.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是自己，则获取攻击目标怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:IsNonAttribute(ATTRIBUTE_DARK) end
	-- 设置连锁操作信息，指定将要破坏的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 设置效果处理函数，执行破坏操作
function c26593852.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是自己，则获取攻击目标怪兽
	if tc==c then tc=Duel.GetAttackTarget() end
	-- 检查攻击怪兽是否与本次战斗相关，若相关则将其破坏
	if tc:IsRelateToBattle() then Duel.Destroy(tc,REASON_EFFECT) end
end
