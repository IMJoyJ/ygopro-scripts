--CX－CHレジェンド・アーサー
-- 效果：
-- 5星怪兽×3
-- 这张卡1回合只有1次不会被战斗破坏。此外，这张卡有「漫画英雄 亚瑟王」在作为超量素材的场合，得到以下效果。
-- ●这张卡战斗破坏怪兽送去墓地时，把这张卡1个超量素材取除才能发动。破坏的怪兽从游戏中除外，给与对方基本分那个原本攻击力数值的伤害。
function c13030280.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用等级为5的怪兽3只进行叠放
	aux.AddXyzProcedure(c,nil,5,3)
	c:EnableReviveLimit()
	-- 这张卡1回合只有1次不会被战斗破坏
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
-- 判断是否为战斗破坏导致的破坏
function c13030280.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 判断是否满足发动条件：自身有「漫画英雄 亚瑟王」作为超量素材、自身参与战斗、被战斗破坏的怪兽在墓地且为怪兽卡
function c13030280.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:GetOverlayGroup():IsExists(Card.IsCode,1,nil,77631175)
		and c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 支付发动代价：从自身场上取除1个超量素材
function c13030280.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置发动效果的目标和操作信息：将被战斗破坏的怪兽除外并对其造成伤害
function c13030280.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsAbleToRemove() end
	-- 设置连锁处理的目标卡为被战斗破坏的怪兽
	Duel.SetTargetCard(bc)
	-- 设置操作信息：将被战斗破坏的怪兽从墓地除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,bc,1,bc:GetControler(),LOCATION_GRAVE)
	-- 设置操作信息：对对方造成伤害，伤害值为被战斗破坏怪兽的原本攻击力
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetBaseAttack())
end
-- 执行效果的处理程序：将被战斗破坏的怪兽除外并造成伤害
function c13030280.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡
	local bc=Duel.GetFirstTarget()
	-- 确认目标卡有效且成功除外后执行后续处理
	if bc:IsRelateToEffect(e) and Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)>0 then
		-- 对对方玩家造成伤害，伤害值为被战斗破坏怪兽的原本攻击力
		Duel.Damage(1-tp,bc:GetBaseAttack(),REASON_EFFECT)
	end
end
