--No.45 滅亡の予言者 クランブル・ロゴス
-- 效果：
-- 2星怪兽×2只以上
-- ①：1回合1次，把这张卡1个超量素材取除，以这张卡以外的场上1张表侧表示的卡为对象才能发动。这只怪兽表侧表示存在期间，作为对象的表侧表示的卡的效果无效化。
-- ②：只要这张卡的①的效果作为对象的卡在场上表侧表示存在，双方不能把作为对象的卡以及那些同名卡的效果发动。
function c29208536.initial_effect(c)
	-- 添加XYZ召唤手续，要求2星怪兽2只以上作为素材
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
-- 设置该卡的XYZ编号为45
aux.xyz_number[29208536]=45
-- 支付1个超量素材作为cost
function c29208536.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 选择场上1张表侧表示的卡作为效果对象
function c29208536.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 筛选目标卡是否满足无效化条件且不是自身
	if chkc then return chkc:IsOnField() and aux.NegateAnyFilter(chkc) and chkc~=e:GetHandler() end
	-- 确认场上是否存在满足无效化条件的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择满足条件的卡作为对象
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息，标记将要无效的卡
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 执行效果，使目标卡的效果无效
function c29208536.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:IsCanBeDisabledByEffect(e) then
		c:SetCardTarget(tc)
		-- 创建一个永续效果，使目标卡的效果无效
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
-- 判断目标卡是否仍存在于场上并被该效果对象
function c29208536.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 判断是否已有卡被该效果对象
function c29208536.actcon(e)
	return e:GetHandler():GetCardTargetCount()>0
end
-- 限制对方不能发动与目标卡同名的卡的效果
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
