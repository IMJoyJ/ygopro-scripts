--No.33 先史遺産－超兵器マシュ＝マック
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，这张卡的攻击力上升这个效果给与的伤害的数值。
function c39139935.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用2只5星怪兽叠放（不限制素材种族/属性）。对应效果原文的‘5星怪兽×2’。
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有和原本攻击力不同攻击力的对方场上1只怪兽为对象才能发动。给与对方那只怪兽的攻击力和那个原本攻击力的相差数值的伤害，这张卡的攻击力上升这个效果给与的伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetDescription(aux.Stringid(39139935,0))  --"攻击上升"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c39139935.cost)
	e1:SetTarget(c39139935.target)
	e1:SetOperation(c39139935.operation)
	c:RegisterEffect(e1)
end
-- 将这张卡登记为No.33，使其适用于No.卡的相关规则（如No.卡只能被No.卡战斗破坏等）。
aux.xyz_number[39139935]=33
-- 该效果发动代价：chk为0时检查这张卡是否有至少1个超量素材可作为COST取除；正式处理时取除这张卡的1个超量素材作为发动代价。
function c39139935.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 对象筛选条件：表侧表示且当前攻击力与原本攻击力不同的怪兽，即‘持有和原本攻击力不同攻击力的对方怪兽’。
function c39139935.filter(c)
	return c:IsFaceup() and not c:IsAttack(c:GetBaseAttack())
end
-- 取对象处理：从对方场上选择1只符合条件的表侧表示怪兽，并预先计算其攻击力与原本攻击力的差值，为后续伤害设置操作信息。
function c39139935.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c39139935.filter(chkc) end
	-- 发动合法性检查：确认对方场上存在至少1只满足条件的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c39139935.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择1张表侧表示的怪兽卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只对方场上的表侧表示且符合条件的怪兽，并将其设为这张卡发动效果的对象（取对象）。
	local g=Duel.SelectTarget(tp,c39139935.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local tc=g:GetFirst()
	local atk=tc:GetAttack()
	local batk=tc:GetBaseAttack()
	-- 设置操作信息，声明将造成的伤害数值（攻击力差值），供其他卡对应；target_player为对方。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,(batk>atk) and (batk-atk) or (atk-batk))
end
-- 效果处理：若对象怪兽仍然相关且表侧表示，则计算其攻击力与原本攻击力的差值并给予对方伤害；若伤害实际造成且本卡仍在场上表侧表示，则本卡的攻击力上升该伤害数值。
function c39139935.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetAttack()
		local batk=tc:GetBaseAttack()
		if batk~=atk then
			local dif=(batk>atk) and (batk-atk) or (atk-batk)
			-- 对对方玩家造成相当于差值数值的伤害，reason为效果，返回实际造成的伤害。
			local dam=Duel.Damage(1-tp,dif,REASON_EFFECT)
			if dam>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
				-- 这张卡的攻击力上升这个效果给与的伤害的数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(dif)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
				c:RegisterEffect(e1)
			end
		end
	end
end
