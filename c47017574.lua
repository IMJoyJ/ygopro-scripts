--CNo.92 偽骸虚龍 Heart－eartH Chaos Dragon
-- 效果：
-- 10星怪兽×4
-- ①：这张卡不会被战斗破坏。
-- ②：自己怪兽给与对方战斗伤害的场合发动。自己基本分回复那个数值。
-- ③：这张卡有「No.92 伪骸神龙 心地心龙」在作为超量素材的场合，得到以下效果。
-- ●1回合1次，把这张卡1个超量素材取除才能发动。对方场上的全部表侧表示的卡的效果直到回合结束时无效化。这个效果的发动和效果不会被无效化。
function c47017574.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：需要等级10的怪兽4只作为超量素材。
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
-- 注册这张卡的No.编号为92，用于识别No.怪兽及相关规则。
aux.xyz_number[47017574]=92
-- 回复效果的发动条件：我方怪兽给与对方战斗伤害（受到伤害的是对方，造成伤害的怪兽属于自己）。
function c47017574.reccon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp)
end
-- 回复效果的发动目标设定：必定发动，设置回复受益玩家为自己、回复数值为当时的战斗伤害值，并注册回复操作信息。
function c47017574.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设为回复基本分的玩家（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为受到的战斗伤害数值，作为回复基本分的数值。
	Duel.SetTargetParam(ev)
	-- 登记回复效果的操作信息：效果分类为回复，目标玩家为自己，回复量为本次战斗伤害值。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 回复效果的实际处理：取出记录的目标玩家和回复数值，执行基本分回复。
function c47017574.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前保存的目标玩家和回复参数，分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点基本分。
	Duel.Recover(p,d,REASON_EFFECT)
end
-- ③效果的发动条件：这张卡的超量素材中存在「No.92 伪骸神龙 心地心龙」（卡号97403510）。
function c47017574.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,97403510)
end
-- 发动代价：取除这张卡的1个超量素材；检查时可取除则返回true，实际发动时取除1个超量素材。
function c47017574.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③效果的目标条件：检查对方场上是否存在至少1张表侧表示且可被无效化的卡。
function c47017574.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动判定阶段（chk==0）且对方场上没有满足aux.NegateAnyFilter的表侧表示卡，则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 效果处理：取对方场上所有可无效化的表侧表示卡，依次赋予其效果无效化状态，直到回合结束时失效；若对象是陷阱怪兽，还额外将其陷阱怪兽效果无效化。
function c47017574.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得对方场上所有满足可无效化条件的表侧表示卡，构成集合g。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部表侧表示的卡的效果直到回合结束时无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的全部表侧表示的卡的效果直到回合结束时无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 对方场上的全部表侧表示的卡的效果直到回合结束时无效化。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
