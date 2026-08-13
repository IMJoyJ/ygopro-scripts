--超巨大空中宮殿ガンガリディア
-- 效果：
-- 10星怪兽×2
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
-- ①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏，给与对方1000伤害。
function c3814632.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用等级10的任意2只怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetDescription(aux.Stringid(3814632,0))  --"破坏并伤害"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,3814632)
	e1:SetCost(c3814632.cost)
	e1:SetTarget(c3814632.target)
	e1:SetOperation(c3814632.operation)
	c:RegisterEffect(e1)
end
-- 发动效果时的代价检查：确认这张卡至少有1个超量素材可以取除，且本回合没有进行过攻击宣言。
function c3814632.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and e:GetHandler():GetAttackAnnouncedCount()==0 end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果发动的目标选择阶段：选择对方场上1张卡作为对象，并登记破坏与伤害的操作信息。
function c3814632.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 发动条件检查：确认对方场上有至少1张卡能够成为效果对象。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作者显示“请选择要破坏的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张卡作为效果对象，并将其设置为当前连锁的对象卡。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将对象卡破坏的效果分类登记为破坏，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：预计给予对方玩家1000点伤害，效果分类登记为伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：取回对象卡，若仍与该效果相关联，则将其破坏；破坏成功时给予对方1000点伤害。
function c3814632.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡，并判断是否实际破坏成功。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对方玩家受到1000点效果伤害。
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
