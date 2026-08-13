--魔頭砲グレンザウルス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的恐龙族怪兽战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。给与对方1000伤害。那之后，这张卡的攻击力上升1000。
-- ②：超量召唤的这张卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏，给与对方1000伤害。
local s,id,o=GetID()
-- 定义此卡的主初始化函数：启用苏生限制、添加4星×2的XYZ召唤手续，并注册①和②两个诱发效果的完整逻辑。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续：将2只等级4的怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	-- 效果①：自己的恐龙族怪兽战斗破坏对方怪兽送去墓地时，把这张卡1个超量素材取除才能发动。给与对方1000伤害。那之后，这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.damcon)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：超量召唤的这张卡被破坏的场合，以场上1张卡为对象才能发动。那张卡破坏，给与对方1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 用于过滤被战斗破坏送去墓地的对方怪兽：确认其是否被己方的表侧表示恐龙族怪兽战斗破坏；若战斗破坏者已不在场，则通过其过去的位置、表示形式、种族等战斗破坏时的状态判断。
function s.egfilter(c,tp)
	if not c:IsPreviousControler(1-tp) or not c:IsLocation(LOCATION_GRAVE) then return false end
	local bc=c:GetReasonCard()
	if not bc then return false end
	if bc:IsRelateToBattle() then
		return bc:IsFaceup() and bc:IsLocation(LOCATION_MZONE) and bc:IsControler(tp) and bc:IsType(TYPE_MONSTER) and bc:IsRace(RACE_DINOSAUR)
	else
		return bc:GetPreviousPosition()&POS_FACEUP>0 and bc:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and bc:IsPreviousControler(tp)
			and bc:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER and c:GetPreviousRaceOnField()&RACE_DINOSAUR==RACE_DINOSAUR
	end
end
-- ①效果的发动条件：战斗破坏怪兽送去墓地的事件中，存在至少1只因己方恐龙族怪兽战斗破坏而送入墓地的对方怪兽。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.egfilter,1,nil,tp)
end
-- ①效果的发动代价：检查并取除此卡的1个超量素材。
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动目标处理：将伤害对象玩家设为对方(1-tp)、伤害值参数设为1000，并登记伤害操作信息。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方(1-tp)，即造成伤害的目标。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为1000，即造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本次效果将向对方玩家造成1000点效果伤害（伤害对象明确，不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ①效果的处理：根据目标玩家和伤害参数给予伤害；若实际造成伤害且此卡仍相关并表侧表示，则中断效果处理，让此卡攻击力上升1000。
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和目标参数（即对方玩家和1000）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成设定数值的效果伤害，若实际伤害大于0（未被无效或减免）则进入后续处理。
	if Duel.Damage(p,d,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 中断当前效果处理，使后续的攻击力上升效果在时点上分开处理，避免错过时点。
			Duel.BreakEffect()
			-- 那之后，这张卡的攻击力上升1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- ②效果的发动条件：此卡超量召唤后被破坏，且破坏前位于怪兽区域。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&LOCATION_MZONE==LOCATION_MZONE and c:IsSummonType(SUMMON_TYPE_XYZ)
end
-- ②效果的目标处理：从场上选择1张卡作为对象，并登记破坏与伤害的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可被选择为对象的卡（场上任意卡）以决定效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡，并将其设为当前连锁的对象卡（取对象）。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：破坏效果的对象为已选择的那张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	-- 登记操作信息：同时将向对方玩家造成1000点效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- ②效果的处理：先取得对象卡，若对象卡仍与此效果关联且被效果破坏成功，则给予对方1000点伤害。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与此效果有联系，则将其以效果破坏，并确认破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 破坏成功后，向对方玩家造成1000点效果伤害。
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end
