--CX－CHレジェンド・アーサー
-- 效果：
-- 5星怪兽×3
-- 这张卡1回合只有1次不会被战斗破坏。此外，这张卡有「漫画英雄 亚瑟王」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏怪兽送去墓地时，把这张卡1个超量素材取除才能发动。破坏的怪兽从游戏中除外，给与对方基本分那个原本攻击力数值的伤害。
function c13030280.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可以用任意3只5星怪兽叠放作为超量素材进行XYZ召唤（nil表示不限制素材的种族/属性）。
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c13030280.valcon)
	c:RegisterEffect(e1)
	-- ●这张卡战斗破坏怪兽送去墓地时，把这张卡1个超量素材取除才能发动。破坏的怪兽从游戏中除外，给与对方基本分那个原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(13030280,0))  --"除外并伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c13030280.damcon)
	e2:SetCost(c13030280.damcost)
	e2:SetTarget(c13030280.damtg)
	e2:SetOperation(c13030280.damop)
	c:RegisterEffect(e2)
end
-- 作为“1回合1次不会被战斗破坏”效果的Value函数：判断破坏原因是否包含战斗，若为战斗破坏则返回true，即适用不会被战斗破坏的效果。
function c13030280.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 诱发效果的发动条件：此卡有「漫画英雄 亚瑟王」（卡号77631175）作为超量素材，且此卡仍与战斗对象关联，战斗对象是被战斗破坏并送入墓地的怪兽（即满足“战斗破坏怪兽送去墓地时”）。
function c13030280.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,77631175)
		and c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 发动代价：从这张卡上取除1个超量素材；chk==0时只检查能否取除，否则实际取除1个超量素材。
function c13030280.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时指定对象：将战斗破坏的那只怪兽设为效果对象；并设置除外该怪兽以及给对方造成其原本攻击力数值伤害的操作信息。
function c13030280.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 将战斗破坏的怪兽bc登记为当前连锁的对象，使后续效果处理可以通过Duel.GetFirstTarget取得它。
	Duel.SetTargetCard(bc)
	-- 登记本次连锁的除外操作信息：从墓地中除外对象bc（1张），其持有者为bc的控制者，表示处理时要将这张卡除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,bc:GetControler(),LOCATION_GRAVE)
	-- 登记本次连锁的伤害操作信息：对对方玩家（1-tp）造成数值为bc原本攻击力的伤害，伤害类型为效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 效果处理：取得发动时登记的战斗破坏怪兽，若它仍与效果关联且成功从墓地除外，则给予对方玩家其原本攻击力数值的伤害。
function c13030280.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时通过Duel.SetTargetCard登记的对象，即被战斗破坏的那只怪兽。
	local bc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与本次效果关联（例如未被其他效果转移/重置联系）且能够成功从墓地除外；只有除外成功才继续伤害处理。
	if bc:IsRelateToEffect(e) and Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 给与对方玩家（1-tp）等同于对象怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,bc:GetBaseAttack(),REASON_EFFECT)
	end
end
