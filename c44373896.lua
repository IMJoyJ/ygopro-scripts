--デストロイ・ドラゴン
-- 效果：
-- 这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「破坏轮」送去墓地的场合才能特殊召唤。
-- ①：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡是怪兽卡的场合，给与对方那个原本攻击力数值的伤害。
function c44373896.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应特殊召唤条件：这张卡在用「克里底亚之牙」的效果把自己的手卡·场上的「破坏轮」送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 对应①效果：①：1回合1次，以对方场上1张卡为对象才能发动。那张卡破坏。那之后，破坏的卡是怪兽卡的场合，给与对方那个原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetDescription(aux.Stringid(44373896,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c44373896.target)
	e2:SetOperation(c44373896.operation)
	c:RegisterEffect(e2)
end
c44373896.material_trap=83555666
-- 效果发动的条件判定与取对象处理：检查对方场上是否存在可被选择的卡，存在则提示选择1张对方场上的卡作为对象，并根据对象是否为怪兽卡设置对应的破坏/伤害操作信息。
function c44373896.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 效果发动时的条件检查：确认对方场上有至少1张任意卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示选择提示：‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 发动者从对方场上选择1张任意卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 记录破坏效果的操作信息：将选中的对象卡作为被破坏的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	if g:GetFirst():IsType(TYPE_MONSTER) then
		local atk=g:GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		-- 记录伤害效果的操作信息：若对象为怪兽卡，则预告将给与对方其原本攻击力数值的伤害（攻击力为?时按0处理）。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
	end
end
-- 效果处理：取得对象卡，若对象仍与该效果关联且仍在对方场上，则破坏该卡；若破坏成功且对象是怪兽卡，则给予对方其原本攻击力数值的伤害。
function c44373896.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 执行破坏，若破坏成功（返回非0）且对象卡是怪兽卡，则继续后续伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_MONSTER) then
			-- 破坏与伤害之间制造时点间隔，使之后的伤害处理不视为与破坏同时处理。
			Duel.BreakEffect()
			-- 给与对方玩家对象怪兽原本攻击力数值的伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
