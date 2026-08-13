--幻惑の魔術師
-- 效果：
-- ①：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。得到那只对方怪兽的控制权。
-- ③：1回合1次，这张卡以外的怪兽攻击的伤害步骤开始时才能发动。场上1张卡破坏。
local s,id,o=GetID()
-- 注册本卡三个效果：①作为场上永续效果使本卡及与其战斗的怪兽不会被那次战斗破坏；②伤害步骤结束时以战斗对象为对象取得其控制权；③其他怪兽攻击的伤害步骤开始时1回合1次破坏场上1张卡。
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
	-- 设置效果②的发动条件：仅在伤害步骤结束且本卡与本次战斗相关（未离场或具有战斗破坏状态）时才满足条件。
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
-- 效果①的适用对象判定：返回真当c是本卡或本卡的战斗对象，即对“那2只”适用战斗破坏免疫。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果②的发动条件与对象设定：以战斗对象bc为对象，检查其仍与战斗相关且可变更控制权；满足后登记下一步要取得其控制权的操作信息。
function s.contg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc and bc:IsRelateToBattle() and bc:IsControlerCanBeChanged() end
	-- 登记效果②的操作信息：声明将取得战斗对象bc的控制权（类别CATEGORY_CONTROL，数量1），供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,bc,1,0,0)
end
-- 效果②处理：取得战斗对象bc，若其仍与本次战斗相关，则将其控制权转移给本卡控制者tp。
function s.conop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	-- 若战斗对象仍与本次战斗相关，则通过Duel.GetControl将该对象控制权转移给效果发动者tp。
	if bc:IsRelateToBattle() then Duel.GetControl(bc,tp) end
end
-- 效果③的发动条件：在伤害步骤开始时，若攻击怪兽不是本卡（即这张卡以外的怪兽攻击）则满足发动条件。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前攻击怪兽不是效果持有者（本卡），即满足“这张卡以外的怪兽攻击”的条件。
	return Duel.GetAttacker()~=e:GetHandler()
end
-- 效果③的发动条件与破坏对象登记：取得双方场上全部卡片，确认存在可破坏的卡；登记破坏1张卡的操作信息（实际对象在效果处理时选择，不取对象）。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上全部卡（怪兽区和魔法陷阱区）作为候选破坏对象集合g。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	-- 登记效果③的操作信息：声明将破坏场上1张卡，候选集合为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③处理：提示操作者从双方场上全部卡中选择1张要破坏的卡，并将其破坏（破坏原因为效果）。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示“请选择要破坏的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 令操作者tp从双方场上全部卡中选取1张要破坏的卡，得到选择结果g。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	if #g>0 then
		-- 将选择出的卡以“效果”为原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
