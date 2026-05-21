--No.15 ギミック・パペット－ジャイアントキラー
-- 效果：
-- 8星怪兽×2
-- ①：1回合最多2次，自己主要阶段1，把这张卡1个超量素材取除，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。破坏的怪兽是超量怪兽的场合，再给与对方那只怪兽的原本攻击力数值的伤害。
function c88120966.initial_effect(c)
	-- 添加超量召唤手续：8星怪兽2只
	aux.AddXyzProcedure(c,nil,8,2)
	c:EnableReviveLimit()
	-- ①：1回合最多2次，自己主要阶段1，把这张卡1个超量素材取除，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。破坏的怪兽是超量怪兽的场合，再给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(88120966,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(2)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c88120966.condition)
	e1:SetCost(c88120966.cost)
	e1:SetTarget(c88120966.target)
	e1:SetOperation(c88120966.operation)
	c:RegisterEffect(e1)
end
-- 设置该卡片的“No.”数值为15
aux.xyz_number[88120966]=15
-- 发动条件判定函数：自己主要阶段1
function c88120966.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 发动代价处理函数：把这张卡1个超量素材取除
function c88120966.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：特殊召唤的怪兽
function c88120966.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动目标选择函数：以对方场上1只特殊召唤的怪兽为对象
function c88120966.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c88120966.filter(chkc) end
	-- 判定对方场上是否存在可以作为对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(c88120966.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c88120966.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：破坏选定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	local tc=g:GetFirst()
	if tc:IsType(TYPE_XYZ) and math.max(0,tc:GetTextAttack())>0 then
		-- 设置操作信息：给与对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 效果处理函数：破坏对象怪兽，若其为超量怪兽则给与对方其原本攻击力数值的伤害
function c88120966.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其破坏，并判定被破坏的怪兽是否为超量怪兽
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_XYZ) then
		local atk=tc:GetBaseAttack()
		if atk>0 then
			-- 中断效果处理，使后续的伤害处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 给与对方该怪兽原本攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
