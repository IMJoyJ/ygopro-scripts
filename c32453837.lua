--No.2 蚊学忍者シャドー・モスキート
-- 效果：
-- 2星怪兽×2只以上
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：可以攻击的对方怪兽必须作出攻击。
-- ③：双方怪兽的攻击宣言时，可以从以下选择1个发动。
-- ●这张卡1个超量素材取除，给对方场上1只表侧表示怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
-- ●选有幻觉指示物放置的1只怪兽，给与对方那个攻击力数值的伤害。
function c32453837.initial_effect(c)
	-- 添加XYZ召唤手续，使用2星怪兽2只以上进行XYZ召唤
	aux.AddXyzProcedure(c,nil,2,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
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
	-- ③：双方怪兽的攻击宣言时，可以从以下选择1个发动。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c32453837.target)
	e4:SetOperation(c32453837.ctop)
	c:RegisterEffect(e4)
end
-- 设置该卡为2星怪兽
aux.xyz_number[32453837]=2
-- 过滤函数，用于判断对方场上的表侧表示怪兽是否具有幻觉指示物
function c32453837.filter(c)
	return c:GetCounter(0x1063)>0 and c:IsFaceup()
end
-- 效果处理函数，用于选择发动效果的选项
function c32453837.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足选项1的条件：对方场上有可放置幻觉指示物的怪兽且自身有1个超量素材可取除
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,nil,0x1063,1) and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	-- 判断是否满足选项2的条件：对方场上有具有幻觉指示物的怪兽
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
	-- 让玩家选择发动效果的选项
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	e:SetLabel(sel)
	if sel==0 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 设置效果处理信息为放置幻觉指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,1-tp,LOCATION_MZONE)
	elseif sel==1 then
		e:SetCategory(CATEGORY_DAMAGE)
		-- 设置效果处理信息为造成伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 效果处理函数，根据选择的选项执行对应效果
function c32453837.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==0 then
		if not c:IsRelateToEffect(e) then return end
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		-- 提示玩家选择要放置幻觉指示物的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 选择对方场上可放置幻觉指示物的1只怪兽
		local g1=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,0,LOCATION_MZONE,1,1,nil,0x1063,1)
		if #g1==0 then return end
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g1)
		local tc=g1:GetFirst()
		tc:AddCounter(0x1063,1)
		-- ③：双方怪兽的攻击宣言时，可以从以下选择1个发动。●这张卡1个超量素材取除，给对方场上1只表侧表示怪兽放置1个幻觉指示物。有幻觉指示物放置的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(c32453837.ctcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	elseif sel==1 then
		-- 提示玩家选择要造成伤害的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择对方场上具有幻觉指示物的1只怪兽
		local g2=Duel.SelectMatchingCard(tp,c32453837.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
		if #g2==0 then return end
		-- 显示所选怪兽被选为对象的动画效果
		Duel.HintSelection(g2)
		-- 对所选怪兽造成其攻击力数值的伤害
		Duel.Damage(1-tp,g2:GetFirst():GetAttack(),REASON_EFFECT)
	end
end
-- 判断怪兽是否具有幻觉指示物
function c32453837.ctcon(e)
	return e:GetHandler():GetCounter(0x1063)>0
end
