--RR－デビル・イーグル
-- 效果：
-- 3星「急袭猛禽」怪兽×2
-- 「急袭猛禽-恶魔雕」的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c52323874.initial_effect(c)
	-- 为这张卡注册超量召唤手续：用2只等级3且属于「急袭猛禽」系列的怪兽作为超量素材从额外卡组特殊召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0xba),3,2)
	c:EnableReviveLimit()
	-- 「急袭猛禽-恶魔雕」的效果1回合只能使用1次。①：把这张卡1个超量素材取除，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52323874,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,52323874)
	e1:SetCost(c52323874.cost)
	e1:SetTarget(c52323874.target)
	e1:SetOperation(c52323874.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查能否从这张卡上取除1个超量素材作为代价，确认后实际取除1个超量素材（REASON_COST）。
function c52323874.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果对象的过滤条件：表侧表示、原本攻击力大于0、且是特殊召唤的怪兽。
function c52323874.filter(c)
	return c:IsFaceup() and c:GetBaseAttack()>0
		and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果发动时的取对象处理：从对方场上选择1只满足条件的特殊召唤表侧表示怪兽作为对象，并将该怪兽的原本攻击力数值设置为将要造成的伤害。
function c52323874.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c52323874.filter(chkc) end
	-- 发动条件检查：确认对方场上存在至少1只满足过滤条件的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c52323874.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家发送选择表侧表示怪兽的提示消息（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让操作玩家从对方场上选择1只满足条件的表侧表示特殊召唤怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52323874.filter,tp,0,LOCATION_MZONE,1,1,nil)
	local atk=g:GetFirst():GetBaseAttack()
	-- 设置效果处理信息：该效果将给对方造成原本攻击力数值的伤害，伤害对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果处理：取回效果对象，若对象仍与效果关联且为表侧表示，则给对方造成其原本攻击力数值的伤害（原本攻击力小于0时按0计算）。
function c52323874.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一个效果对象（即被选择的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local atk=tc:GetBaseAttack()
		if atk<0 then atk=0 end
		-- 以效果（REASON_EFFECT）为原因给对方玩家造成 atk 点伤害。
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
