--CX 機装魔人エンジェネラル
-- 效果：
-- 4星怪兽×3
-- 这张卡超量召唤成功时，可以选择场上守备表示存在的1只怪兽变成表侧攻击表示。此外，这张卡有「机装天使 引擎天兵」在作为超量素材的场合，得到以下效果。
-- ●这张卡给与对方基本分战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方基本分1000分伤害。
function c41309158.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为4的怪兽3只进行超量召唤
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- 这张卡超量召唤成功时，可以选择场上守备表示存在的1只怪兽变成表侧攻击表示
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41309158,0))  --"改变表示形式"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c41309158.poscon)
	e1:SetTarget(c41309158.postg)
	e1:SetOperation(c41309158.posop)
	c:RegisterEffect(e1)
	-- 这张卡给与对方基本分战斗伤害时，把这张卡1个超量素材取除才能发动。给与对方基本分1000分伤害
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41309158,1))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCondition(c41309158.damcon)
	e2:SetCost(c41309158.damcost)
	e2:SetTarget(c41309158.damtg)
	e2:SetOperation(c41309158.damop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为超量召唤成功
function c41309158.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 选择目标：场上守备表示的怪兽
function c41309158.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsDefensePos() end
	-- 检查是否场上存在守备表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择守备表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEFENSE)  --"请选择守备表示的怪兽"
	-- 选择场上1只守备表示的怪兽作为目标
	Duel.SelectTarget(tp,Card.IsDefensePos,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将目标怪兽改变为表侧攻击表示
function c41309158.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsDefensePos() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧攻击表示
		Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
	end
end
-- 判断对方玩家造成战斗伤害且此卡有「机装天使 引擎天兵」作为超量素材
function c41309158.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,15914410)
end
-- 支付代价：从自身场上取除1个超量素材
function c41309158.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置伤害效果的目标玩家和伤害值
function c41309158.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 执行伤害效果，对目标玩家造成1000点伤害
function c41309158.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
