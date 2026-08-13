--No.50 ブラック・コーン号
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽送去墓地，给与对方1000伤害。这个效果发动的回合，这张卡不能攻击。
function c51735257.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要 2 只等级 4 的怪兽作为超量素材叠放（对应“4星怪兽×2”）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以持有这张卡的攻击力以下的攻击力的对方场上1只怪兽为对象才能发动。那只怪兽送去墓地，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51735257,0))  --"送墓并伤害"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c51735257.cost)
	e1:SetTarget(c51735257.target)
	e1:SetOperation(c51735257.operation)
	c:RegisterEffect(e1)
end
-- 将这张卡的 XYZ 编号登记为 50（No.50），用于 No. 卡相关效果判定。
aux.xyz_number[51735257]=50
-- 代价检查（chk==0）：本卡本回合攻击宣言次数为 0，且可以取除自身 1 个超量素材作为发动代价。
function c51735257.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0
		and e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
	-- 这个效果发动的回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 选择对象的过滤条件：对方场上的表侧表示怪兽，且攻击力不高于本卡的当前攻击力。
function c51735257.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 效果发动时的对象选择与合法性判定：验证指定对象是否符合条件；确认存在至少 1 个合法对象；玩家选择 1 只符合条件的对方表侧表示怪兽作为对象，并设置送去墓地及给予伤害的操作信息。
function c51735257.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c51735257.filter(chkc,e:GetHandler():GetAttack()) end
	-- 发动合法性检查：确认对方主要怪兽区存在至少 1 只满足条件的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c51735257.filter,tp,0,LOCATION_MZONE,1,nil,e:GetHandler():GetAttack()) end
	-- 显示选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择对方场上 1 只符合条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c51735257.filter,tp,0,LOCATION_MZONE,1,1,nil,e:GetHandler():GetAttack())
	-- 设置操作信息：本次效果将把对象怪兽送去墓地，数量为 g 的张数。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息：本次效果将给予对方玩家 1000 点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：取得对象怪兽，若其仍与效果相关联，则将其送去墓地；若成功进入墓地，则给予对方 1000 点伤害。
function c51735257.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的第 1 个对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 以效果原因将对象怪兽送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 以效果原因给予对方玩家 1000 点伤害。
			Duel.Damage(1-tp,1000,REASON_EFFECT)
		end
	end
end
