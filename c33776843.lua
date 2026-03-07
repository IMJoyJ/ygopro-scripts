--CNo.15 ギミック・パペット－シリアルキラー
-- 效果：
-- 9星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张卡破坏。这个效果把怪兽破坏的场合，再给与对方那只怪兽的原本攻击力数值的伤害。
function c33776843.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为9的怪兽进行3次叠放
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
-- 设置该卡为混沌No.15系列
aux.xyz_number[33776843]=15
-- 费用处理：检查并移除1个超量素材作为发动代价
function c33776843.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果目标选择：选择对方场上1张卡作为破坏对象
function c33776843.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否满足发动条件：对方场上存在可破坏的卡片
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标卡片并设置为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将破坏效果的处理对象设为已选择的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	local tc=g:GetFirst()
	if tc:IsLocation(LOCATION_MZONE) and math.max(0,tc:GetTextAttack())>0 then
	-- 设置操作信息：若目标为怪兽且攻击力大于0，则将造成伤害的效果也加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) end
end
-- 效果处理：破坏目标卡片并根据其是否为怪兽决定是否造成额外伤害
function c33776843.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡片是否仍然有效且被破坏成功且原位置为怪兽区域
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsPreviousLocation(LOCATION_MZONE) then
		local atk=math.max(0,tc:GetTextAttack())
		if atk>0 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 对对方玩家造成相当于目标怪兽原本攻击力数值的伤害
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
