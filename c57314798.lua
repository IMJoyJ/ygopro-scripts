--No.100 ヌメロン・ドラゴン
-- 效果：
-- 相同阶级的同名「No.」超量怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时上升场上的超量怪兽的阶级合计×1000。
-- ②：这张卡被效果破坏时才能发动。场上的怪兽全部破坏。那之后，双方选自身墓地1张魔法·陷阱卡在场上盖放。
-- ③：自己的手卡·场上没有卡的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从墓地特殊召唤。
function c57314798.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：需要2只相同阶级的同名「No.」超量怪兽。
	aux.AddXyzProcedureLevelFree(c,c57314798.mfilter,c57314798.xyzcheck,2,2)
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。这张卡的攻击力直到对方回合结束时上升场上的超量怪兽的阶级合计×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57314798,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c57314798.atkcost)
	e2:SetTarget(c57314798.atktg)
	e2:SetOperation(c57314798.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果破坏时才能发动。场上的怪兽全部破坏。那之后，双方选自身墓地1张魔法·陷阱卡在场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(57314798,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c57314798.descon)
	e3:SetTarget(c57314798.destg)
	e3:SetOperation(c57314798.desop)
	c:RegisterEffect(e3)
	-- ③：自己的手卡·场上没有卡的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从墓地特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(57314798,2))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c57314798.spcon)
	e4:SetTarget(c57314798.sptg)
	e4:SetOperation(c57314798.spop)
	c:RegisterEffect(e4)
end
-- 设定该卡为「No.100」怪兽。
aux.xyz_number[57314798]=100
-- 超量素材过滤条件：属于「No.」系列的超量怪兽。
function c57314798.mfilter(c,xyzc)
	return c:IsSetCard(0x48) and c:IsXyzType(TYPE_XYZ)
end
-- 超量素材检查：必须是同名且同阶级的怪兽。
function c57314798.xyzcheck(g)
	return g:GetClassCount(Card.GetCode)==1 and g:GetClassCount(Card.GetRank)==1
end
-- 攻击力上升效果的发动代价：取除这张卡的1个超量素材。
function c57314798.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：场上表侧表示且阶级大于0的超量怪兽。
function c57314798.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetRank()>0
end
-- 攻击力上升效果的发动目标：检查场上是否存在表侧表示的超量怪兽。
function c57314798.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只表侧表示的超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c57314798.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 攻击力上升效果的处理：计算场上超量怪兽的阶级合计，并使这张卡的攻击力上升该数值×1000。
function c57314798.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 获取双方场上所有表侧表示的超量怪兽。
		local g=Duel.GetMatchingGroup(c57314798.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		local atk=g:GetSum(Card.GetRank)
		if atk>0 then
			-- 这张卡的攻击力直到对方回合结束时上升场上的超量怪兽的阶级合计×1000。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(atk*1000)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			c:RegisterEffect(e1)
		end
	end
end
-- 破坏效果的发动条件：这张卡被效果破坏。
function c57314798.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤条件：可以盖放在场上的魔法·陷阱卡。
function c57314798.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 破坏效果的发动目标：检查场上是否有怪兽，并设置破坏怪兽和从墓地盖放卡的操作信息。
function c57314798.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取双方场上的所有怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：双方从墓地将卡移出墓地（盖放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 破坏效果的处理：破坏场上所有怪兽，之后双方玩家各自选择自身墓地的一张魔法·陷阱卡在场上盖放。
function c57314798.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏场上的所有怪兽，并检查是否有怪兽被成功破坏。
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 中断效果处理，使后续的盖放卡片处理不与破坏同时进行。
		Duel.BreakEffect()
		-- 提示自身玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 自身玩家从自身墓地选择1张魔法·陷阱卡（受王家长眠之谷影响）。
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c57314798.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		-- 提示对方玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 对方玩家从自身墓地选择1张魔法·陷阱卡（受王家长眠之谷影响）。
		local g2=Duel.SelectMatchingCard(1-tp,aux.NecroValleyFilter(c57314798.setfilter),1-tp,LOCATION_GRAVE,0,1,1,nil)
		local tc1=g1:GetFirst()
		local tc2=g2:GetFirst()
		if tc1 then
			-- 自身玩家将选择的卡在自身场上盖放。
			Duel.SSet(tp,tc1)
		end
		if tc2 then
			-- 对方玩家将选择的卡在对方场上盖放。
			Duel.SSet(1-tp,tc2)
		end
	end
end
-- 过滤条件：排除处于确认离开场上状态的卡片。
function c57314798.spfilter(c)
	return not c:IsStatus(STATUS_LEAVE_CONFIRMED)
end
-- 特殊召唤效果的发动条件：自身手卡·场上没有卡，且对方怪兽直接攻击宣言时。
function c57314798.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击宣言的怪兽是否由对方控制，且攻击对象为空（即直接攻击）。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
		-- 检查自身的手卡和场上是否没有任何卡。
		and not Duel.IsExistingMatchingCard(c57314798.spfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,1,nil)
end
-- 特殊召唤效果的发动目标：检查自身怪兽区域是否有空位，且这张卡是否可以特殊召唤。
function c57314798.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理：如果这张卡仍存在于墓地，则将其特殊召唤。
function c57314798.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自身场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
