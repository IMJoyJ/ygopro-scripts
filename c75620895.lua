--隻眼のスキル・ゲイナー
-- 效果：
-- 4星怪兽×3
-- 把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。这张卡当作和选择的怪兽同名卡使用，得到相同效果。这个效果只在这张卡在场上表侧表示存在能使用1次。
function c75620895.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽3只
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 把这张卡1个超量素材取除，选择对方场上1只超量怪兽才能发动。这张卡当作和选择的怪兽同名卡使用，得到相同效果。这个效果只在这张卡在场上表侧表示存在能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(75620895,0))  --"效果复制"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c75620895.cost)
	e1:SetTarget(c75620895.target)
	e1:SetOperation(c75620895.operation)
	c:RegisterEffect(e1)
end
-- 发动代价：取除这张卡的1个超量素材
function c75620895.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：表侧表示的超量怪兽
function c75620895.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 效果的目标选择与合法性判定
function c75620895.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c75620895.filter(chkc) end
	-- 在发动准备阶段，确认对方场上是否存在可选的表侧表示超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c75620895.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 在客户端显示提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的超量怪兽作为效果对象
	Duel.SelectTarget(tp,c75620895.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：使自身在场上表侧表示存在期间改变卡名并复制对象怪兽的效果
function c75620895.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetOriginalCode()
		-- 这张卡当作和选择的怪兽同名卡使用
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		c:RegisterEffect(e1)
		c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD,1)
	end
end
