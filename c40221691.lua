--幻惑の魔術師
-- 效果：
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。得到那只对方怪兽的控制权。
-- ③：1回合1次，这张卡以外的怪兽攻击的伤害步骤开始时才能发动。场上1张卡破坏。
local s,id,o=GetID()
-- 注册三个效果：①战斗时双方不会被战斗破坏；②伤害步骤结束时获得对方怪兽控制权；③1回合1次，对方怪兽攻击时破坏场上1张卡
function s.initial_effect(c)
	-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。得到那只对方怪兽的控制权。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_CONTROL)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	-- 判断是否满足效果②的发动条件，即该卡是否参与了战斗且战斗中的对方怪兽仍然存在
	e2:SetCondition(aux.dsercon)
	e2:SetTarget(s.contg)
	e2:SetOperation(s.conop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡以外的怪兽攻击的伤害步骤开始时才能发动。场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果①的目标判定函数，判断目标是否为自身或自身战斗中的对方怪兽
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果②的发动时处理函数，检查目标怪兽是否仍处于战斗状态并可改变控制权
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 设置效果②的发动信息，表示将要改变目标怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
-- 效果②的处理函数，执行获得对方怪兽控制权的操作
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 判断目标怪兽是否仍处于战斗状态，若满足则执行控制权转移
	if bc:IsRelateToBattle() then Duel.GetControl(bc,tp) end
end
-- 效果③的发动条件函数，判断攻击怪兽是否不是自身
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否不是自身，确保是对方怪兽攻击时才能发动
	return Duel.GetAttacker()~=e:GetHandler()
end
-- 效果③的发动时处理函数，准备选择并破坏场上一张卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有卡的集合
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	-- 设置效果③的发动信息，表示将要破坏场上卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③的处理函数，提示选择并破坏场上一张卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择一张卡作为破坏目标
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	if #g>0 then
		-- 执行破坏操作，将选中的卡以效果原因破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
