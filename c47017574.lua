--CNo.92 偽骸虚龍 Heart－eartH Chaos Dragon
-- 效果：
-- 10星怪兽×4
-- ①：这张卡不会被战斗破坏。
-- ②：自己怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
-- ③：这张卡有「No.92 伪骸神龙 心地心龙」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效化。这个效果的发动和效果不会被无效化。
function c47017574.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为10且数量为4的怪兽进行叠放
	aux.AddXyzProcedure(c,nil,10,4)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47017574,0))  --"LP回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c47017574.reccon)
	e2:SetTarget(c47017574.rectg)
	e2:SetOperation(c47017574.recop)
	c:RegisterEffect(e2)
	-- ③：这张卡有「No.92 伪骸神龙 心地心龙」在作为超量素材的场合，得到以下效果。●1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效化。这个效果的发动和效果不会被无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47017574,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c47017574.discon)
	e3:SetCost(c47017574.discost)
	e3:SetTarget(c47017574.distg)
	e3:SetOperation(c47017574.disop)
	c:RegisterEffect(e3)
end
-- 设置该卡为No.92系列怪兽
aux.xyz_number[47017574]=92
-- 判断是否为己方怪兽对敌方造成战斗伤害
function c47017574.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp)
end
-- 设置LP回复效果的目标玩家和回复数值
function c47017574.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为造成的战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置连锁操作信息，指定将要进行LP回复效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 执行LP回复效果，使目标玩家回复对应数值的LP
function c47017574.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使指定玩家回复对应数值的LP
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判断该卡是否叠放了No.92伪骸神龙 心地心龙作为超量素材
function c47017574.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,97403510)
end
-- 消耗1个超量素材作为发动代价
function c47017574.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检查对方场上是否存在可被无效化的卡片
function c47017574.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在可被无效化的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 对对方场上的所有表侧表示的卡施加效果无效化
function c47017574.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上的所有表侧表示的卡组成的卡片组
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡片的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡片的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 使目标陷阱怪兽无法发动其效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
