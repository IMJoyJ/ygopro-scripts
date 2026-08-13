--CNo.15 ギミック・パペット－シリアルキラー
-- 效果：
-- 9星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，再给与对方那只怪兽的原本攻击力数值的伤害。
function c33776843.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以任意9星怪兽3只为素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，再给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33776843,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c33776843.cost)
	e1:SetTarget(c33776843.target)
	e1:SetOperation(c33776843.operation)
	c:RegisterEffect(e1)
end
-- 在XYZ编号表中登记此卡为CNo.15，用于相关编号判定。
aux.xyz_number[33776843]=15
-- 发动代价处理：检查可否取除1个超量素材，并实际取除1个超量素材作为代价。
function c33776843.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时选择对方场上1张卡为对象，设置破坏操作信息；若对象为怪兽区且原攻击力>0，则追加设置伤害操作信息。
function c33776843.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 合法性检查：确认对方场上有至少1张可作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象并登记为连锁对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作信息，指定将对象卡破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_MZONE) and math.max(0,tc:GetTextAttack())>0 then
	-- 若对象为攻击力>0的怪兽，额外设置对对方造成伤害的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) end
end
-- 效果处理：取得对象卡，若其仍与效果关联且被成功破坏且破坏前在怪兽区，则给予对方该怪兽原本攻击力的伤害。
function c33776843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍关联、破坏成功且破坏前位于怪兽区，满足则继续伤害处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsPreviousLocation(LOCATION_MZONE) then
		local atk=math.max(0,tc:GetTextAttack())
		if atk>0 then
			-- 中断效果连锁，使破坏与伤害处理分离，避免错过时点。
			Duel.BreakEffect()
			-- 给予对方玩家该怪兽原本攻击力数值的效果伤害。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
