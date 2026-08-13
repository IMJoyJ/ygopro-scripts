--No.45 滅亡の予言者 クランブル・ロゴス
-- 效果：
-- 2星怪兽×2只以上
-- ①：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，作为对象的表侧表示的卡的效果无效化。
-- ②：只要这张卡的①的效果作为对象的卡在场上表侧表示存在，双方不能把作为对象的卡以及那些同名卡的效果发动。
function c29208536.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可用任意2只2星怪兽作为素材叠放，最多可用99只（体现“2星怪兽×2只以上”的召唤条件）。
	aux.AddXyzProcedure(c,nil,2,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，作为对象的表侧表示的卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(29208536,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c29208536.cost)
	e1:SetTarget(c29208536.target)
	e1:SetOperation(c29208536.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡的①的效果作为对象的卡在场上表侧表示存在，双方不能把作为对象的卡以及那些同名卡的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetCondition(c29208536.actcon)
	e3:SetValue(c29208536.aclimit)
	c:RegisterEffect(e3)
end
-- 将这张卡的No.编号登记为45，用于No.系列相关规则判定。
aux.xyz_number[29208536]=45
-- 代价函数：效果发动前检查可否从这张卡上移除1个超量素材作为代价；可以则实际移除1个超量素材。
function c29208536.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 目标函数：效果发动时选择这张卡以外的场上1张表侧表示且可被无效化的卡作为对象，并写入操作信息。
function c29208536.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 连锁处理中对已指定对象进行合法性复核：对象必须在场上表侧表示、可被无效化，且不能是这张卡本身。
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件检查：场上是否存在满足条件的对象（表侧表示且可被无效化的这张卡以外的卡），存在才可发动。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要无效化的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家从符合条件的卡中选取1张，将其设为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 将本次操作信息登记为“使1张卡效果无效化”，以便其他卡（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果处理：若发动卡与对象仍合法且对象可被无效化，则令对象效果无效；若对象是陷阱怪兽，再追加使其陷阱怪兽效果无效化的效果。
function c29208536.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:IsCanBeDisabledByEffect(e) then
		c:SetCardTarget(tc)
		-- 使对象卡的效果无效化，持续条件为本卡仍持有该对象作为永续对象（即“这只怪兽表侧表示存在期间”）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCondition(c29208536.rcon)
		tc:RegisterEffect(e1)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
	end
end
-- 无效化效果的条件：仅当这张卡仍以对象卡为永续对象时，无效化效果才适用。
function c29208536.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- ②效果的适用条件：这张卡存在①效果选择的永续对象时，才禁止双方发动相应卡的效果。
function c29208536.actcon(e)
	return e:GetHandler():GetCardTargetCount()>0
end
-- 禁止发动的限定：被发动的卡的卡名必须与这张卡的①效果对象卡及其同名卡一致，即禁止这些卡的效果发动。
function c29208536.aclimit(e,re,tp)
	local g=e:GetHandler():GetCardTarget()
	local cg={}
	local tc=g:GetFirst()
	while tc do
		table.insert(cg,tc:GetCode())
		tc=g:GetNext()
	end
	return re:GetHandler():IsCode(table.unpack(cg))
end
