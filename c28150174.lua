--フォトン・バタフライ・アサシン
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除，选择场上守备表示存在的1只怪兽才能发动。选择的怪兽变成表侧攻击表示，那个攻击力下降600。
function c28150174.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以任意2只等级4怪兽作为超量素材叠放来XYZ召唤。
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
-- 效果发动代价：只有在能够从这张卡上取除1个超量素材时才可发动，实际取除1个超量素材作为代价。
function c28150174.poscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动条件和目标选择：该效果取对象，需要选择场上1只守备表示怪兽；先检查是否存在合法目标，再让玩家选择对象并设置操作信息。
function c28150174.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 检查当前场上是否存在至少1只守备表示怪兽（作为效果对象的候选），若不存在则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家展示选择守备表示怪兽的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 让玩家从双方场上选择1只守备表示怪兽作为效果对象，并自动将该卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本连锁的操作信息：效果处理时将改变对象怪兽的表示形式（位置改变），用于星尘等卡的对应检测。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：取对象怪兽，若其仍在场上且为守备表示且与效果关联，则将其变为表侧攻击表示；若变为表侧攻击表示成功，则给它附加攻击力下降600的效果。
function c28150174.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
		if tc:IsPosition(POS_FACEUP_ATTACK) then
			-- 那个攻击力下降600。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-600)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
