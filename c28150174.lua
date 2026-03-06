--フォトン・バタフライ・アサシン
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示，那个攻击力下降600。
function c28150174.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽进行叠放，需要2只怪兽
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除，选择场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示，那个攻击力下降600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28150174,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c28150174.poscost)
	e1:SetTarget(c28150174.postg)
	e1:SetOperation(c28150174.posop)
	c:RegisterEffect(e1)
end
-- 支付效果的代价，从自己场上取除1个超量素材
function c28150174.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果的目标，选择场上1只守备表示的怪兽
function c28150174.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 检查场上是否存在守备表示的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 选择场上1只守备表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理时的操作信息，确定将要改变表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 处理效果的运算部分，将目标怪兽变为表侧攻击表示并降低其攻击力
function c28150174.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			-- 使目标怪兽的攻击力下降600
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
