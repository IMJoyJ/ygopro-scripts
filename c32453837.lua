--No.2 蚊学忍者シャドー・モスキート
-- 效果：
-- 2星怪兽×2只以上
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：可以攻击的对方怪兽必须作出攻击。
-- ③：双方怪兽的攻击宣言时，可以从以下选择1个发动。
-- ●这张卡1个超量素材取除，给对方场上1只表侧表示怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
-- ●选有幻觉指示物放置的1只怪兽，给与对方那个攻击力数值的伤害。
function c32453837.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2星怪兽2只以上（最多99只）进行叠放来超量召唤
	aux.AddXyzProcedure(c,nil,2,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e2)
	-- ②：可以攻击的对方怪兽必须作出攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e3)
	-- ③：双方怪兽的攻击宣言时，可以从以下选择1个发动。●这张卡1个超量素材取除，给对方场上1只表侧表示怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。●选有幻觉指示物放置的1只怪兽，给与对方那个攻击力数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c32453837.target)
	e4:SetOperation(c32453837.ctop)
	c:RegisterEffect(e4)
end
-- 在超量编号表中登记这张卡的「No.」编号为2
aux.xyz_number[32453837]=2
c32453837.mentioned_counter={
	[0x1063]=true,
}
-- 定义过滤器：筛选放置有幻觉指示物的表侧表示怪兽
function c32453837.filter(c)
	return c:GetCounter(0x1063)>0 and c:IsFaceup()
end
-- 定义攻击宣言时效果的发动目标处理：检查两个可选效果各自是否可执行，让发动者选择其中一个，并根据选择设置对应的效果分类与操作信息
function c32453837.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查选项1是否可执行：对方场上存在可以放置幻觉指示物的怪兽，且这张卡有可以取除的超量素材
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1063,1) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	-- 检查选项2是否可执行：对方场上存在放置有幻觉指示物的表侧表示怪兽
	local b2=Duel.IsExistingMatchingCard(c32453837.filter,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(32453837,0)  --"放置指示物"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(32453837,1)  --"伤害"
		opval[off]=1
		off=off+1
	end
	-- 让发动者从可执行的选项中选择1个要发动的效果
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 设置操作信息：宣言本次连锁为指示物效果，预计给对方场上1只怪兽放置指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,1-tp,LOCATION_MZONE)
	elseif sel==1 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 设置操作信息：宣言本次连锁为伤害效果，预计给与对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 定义攻击宣言时效果的处理：根据发动时选择的选项，取除1个超量素材给对方怪兽放置幻觉指示物并使其效果无效化，或选放置有幻觉指示物的1只怪兽给与对方那个攻击力数值的伤害
function c32453837.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		if not c:IsRelateToEffect(e) then return end
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		-- 提示发动者选择要放置指示物的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让发动者选择对方场上1只可以放置幻觉指示物的表侧表示怪兽
		local g1=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1063,1)
		if #g1==0 then return end
		-- 显示所选怪兽被选择的动画，并记录其被选为对象
		Duel.HintSelection(g1)
		local tc=g1:GetFirst()
		tc:AddCounter(0x1063,1)
		-- 有幻觉指示物放置的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c32453837.ctcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif sel==1 then
		-- 提示发动者选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让发动者选择场上1只放置有幻觉指示物的表侧表示怪兽作为效果对象
		local g2=Duel.SelectMatchingCard(tp,c32453837.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g2==0 then return end
		-- 显示所选怪兽被选择的动画，并记录其被选为对象
		Duel.HintSelection(g2)
		-- 给与对方所选怪兽攻击力数值的伤害
		Duel.Damage(1-tp,g2:GetFirst():GetAttack(),REASON_EFFECT)
	end
end
-- 定义效果无效化的适用条件：该怪兽放置有幻觉指示物
function c32453837.ctcon(e)
	return e:GetHandler():GetCounter(0x1063)>0
end
