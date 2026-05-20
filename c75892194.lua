--古代の機械竜
-- 效果：
-- 这张卡不能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上的怪兽不存在的场合或者只有机械族·地属性怪兽的场合，这张卡可以不用解放作召唤。
-- ②：对方把魔法·陷阱卡的效果发动时，把自己的手卡·场上（表侧表示）1只机械族怪兽或者卡组1只「古代的机械巨人」送去墓地才能发动。那个效果无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含不能特殊召唤、妥协召唤、无效魔法·陷阱卡效果三个效果
function s.initial_effect(c)
	-- 将「古代的机械巨人」的卡片密码加入此卡的关联卡片列表中
	aux.AddCodeList(c,83104731)
	-- 这张卡不能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤的条件始终为假，使该怪兽无法被特殊召唤
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	-- ①：自己场上的怪兽不存在的场合或者只有机械族·地属性怪兽的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱卡的效果发动时，把自己的手卡·场上（表侧表示）1只机械族怪兽或者卡组1只「古代的机械巨人」送去墓地才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"魔法·陷阱卡无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的机械族·地属性怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 判定是否满足不用解放作召唤的条件：自己场上没有怪兽，或者只有表侧表示的机械族·地属性怪兽
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否为通常召唤、等级在5星以上且自己场上有可用的怪兽区域
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己场上存在机械族·地属性怪兽
		and (Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 且自己场上不存在非“机械族·地属性”的怪兽（即只有机械族·地属性怪兽）
			and not Duel.IsExistingMatchingCard(aux.NOT(s.cfilter),tp,LOCATION_MZONE,0,1,nil)
			-- 或者自己场上不存在任何怪兽
			or not Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,0,1,nil))
end
-- 判定无效效果的发动条件：此卡未被战斗破坏，且对方发动了可以被无效的魔法·陷阱卡的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	return ep==1-tp
		-- 且发动的效果是魔法或陷阱卡的效果，并且该连锁的发动可以被无效
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤作为发动成本送去墓地的卡：手卡·场上表侧表示的机械族怪兽，或者卡组中的「古代的机械巨人」
function s.cgfilter(c)
	return (c:IsRace(RACE_MACHINE) and c:IsLocation(LOCATION_HAND+LOCATION_MZONE)
		or c:IsCode(83104731) and c:IsLocation(LOCATION_DECK))
		and c:IsAbleToGraveAsCost() and c:IsFaceupEx()
end
-- 执行发动成本：从手卡·场上（表侧表示）选择1只机械族怪兽，或者从卡组选择1只「古代的机械巨人」送去墓地
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡、场上或卡组中是否存在至少1张满足送去墓地条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cgfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡、场上或卡组中选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.cgfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_DECK,0,1,1,nil)
	-- 将选择的卡作为发动成本送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果的目标处理：设置效果无效的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示该效果的处理是将对方发动的卡的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果的实际处理：使对方发动的效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果
	Duel.NegateEffect(ev)
end
