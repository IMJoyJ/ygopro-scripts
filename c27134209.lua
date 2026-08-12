--樹冠の甲帝ベアグラム
-- 效果：
-- 这张卡不能通常召唤。把自己的手卡·墓地3只昆虫族·植物族怪兽除外的场合才能从手卡·墓地特殊召唤。自己对「树冠之甲帝 比亚格拉姆」1回合只能有1次特殊召唤。
-- ①：只要这张卡在怪兽区域存在，对方不能对应自己的魔法·陷阱卡的效果的发动把怪兽的效果发动。
-- ②：1回合1次，自己主要阶段才能发动。昆虫族·植物族怪兽以外的场上的表侧表示怪兽全部破坏。这个回合，这张卡不能直接攻击。
function c27134209.initial_effect(c)
	c:SetSPSummonOnce(27134209)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，对方不能对应自己的魔法·陷阱卡的效果的发动把怪兽的效果发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 这张卡不能通常召唤。把自己的手卡·墓地3只昆虫族·植物族怪兽除外的场合才能从手卡·墓地特殊召唤。自己对「树冠之甲帝 比亚格拉姆」1回合只能有1次特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(c27134209.sprcon)
	e1:SetTarget(c27134209.sprtg)
	e1:SetOperation(c27134209.sprop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应自己的魔法·陷阱卡的效果的发动把怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c27134209.chainop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己主要阶段才能发动。昆虫族·植物族怪兽以外的场上的表侧表示怪兽全部破坏。这个回合，这张卡不能直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c27134209.destg)
	e3:SetOperation(c27134209.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断手卡或墓地中的怪兽是否为昆虫族或植物族且可作为除外费用。
function c27134209.sprfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_INSECT+RACE_PLANT) and c:IsAbleToRemoveAsCost()
end
-- 判断特殊召唤条件是否满足：场上是否有空位且自己手卡或墓地是否有3只符合条件的怪兽。
function c27134209.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断当前玩家的怪兽区域是否有空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断当前玩家的手卡或墓地是否存在至少3只符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c27134209.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,3,c)
end
-- 设置特殊召唤时的选择处理：从符合条件的卡中选择3张除外。
function c27134209.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手卡或墓地中所有符合条件的怪兽。
	local g=Duel.GetMatchingGroup(c27134209.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,c)
	-- 向玩家发送提示信息，提示其选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 设置特殊召唤的操作处理：将选中的3张卡除外。
function c27134209.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以正面表示形式除外。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 设置连锁限制处理：当对方发动魔法或陷阱卡时，禁止其发动怪兽效果。
function c27134209.chainop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and ep==tp then
		-- 设置连锁限制条件，禁止对方在自己发动魔法或陷阱卡时发动怪兽效果。
		Duel.SetChainLimit(c27134209.chainlm)
	end
end
-- 连锁限制函数，判断是否允许对方发动怪兽效果。
function c27134209.chainlm(re,rp,tp)
	return tp==rp or not re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数，用于判断场上的表侧表示怪兽是否为昆虫族或植物族以外的怪兽。
function c27134209.desfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_INSECT+RACE_PLANT)
end
-- 设置破坏效果的目标处理：检查场上是否存在非昆虫族或植物族的表侧表示怪兽。
function c27134209.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在非昆虫族或植物族的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有非昆虫族或植物族的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息，表明此效果将破坏指定数量的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 设置破坏效果的操作处理：将符合条件的怪兽全部破坏，并使该卡本回合不能直接攻击。
function c27134209.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有非昆虫族或植物族的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(c27134209.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将符合条件的怪兽以效果原因破坏。
	Duel.Destroy(g,REASON_EFFECT)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 使该卡在本回合不能直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
