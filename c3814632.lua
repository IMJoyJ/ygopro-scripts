--超巨大空中宮殿ガンガリディア
-- 效果：
-- 10星怪兽×2
-- 这个卡名的效果1回合只能使用1次，这个效果发动的回合，这张卡不能攻击。
-- ①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏，给与对方1000伤害。
function c3814632.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为10、数量为2的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,10,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以对方场上1张卡为对象才能发动。那张对方的卡破坏，给与对方1000伤害。
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
-- 检查是否满足费用条件：移除1个超量素材且本回合未宣布过攻击
function c3814632.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST)
		and e:GetHandler():GetAttackAnnouncedCount()==0 end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 使这张卡在效果发动的回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 设置效果的目标选择逻辑：选择对方场上的1张卡作为对象
function c3814632.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 判断是否有满足条件的对方场上卡片可作为目标
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置给予对方1000伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行效果的处理流程：若目标卡存在则破坏并造成伤害
function c3814632.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标卡片，若成功则继续执行后续处理
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 对对方造成1000点伤害
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
