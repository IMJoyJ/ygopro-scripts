--天威の龍拳聖
-- 效果：
-- 包含连接怪兽的怪兽2只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡不会被和效果怪兽的战斗破坏。
-- ②：自己场上没有其他的效果怪兽存在的场合才能发动。选最多有自己墓地以及自己场上表侧表示存在的除效果怪兽以外的怪兽数量的对方场上的效果怪兽破坏。
function c23935886.initial_effect(c)
	-- 为这张卡注册连接召唤手续，素材要求为2只以上怪兽，并且素材组中必须包含至少1只连接怪兽（由lcheck校验）。
	aux.AddLinkProcedure(c,nil,2,nil,c23935886.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡不会被和效果怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c23935886.indval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上没有其他的效果怪兽存在的场合才能发动。选最多有自己墓地以及自己场上表侧表示存在的除效果怪兽以外的怪兽数量的对方场上的效果怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23935886,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,23935886)
	e2:SetCondition(c23935886.descon)
	e2:SetTarget(c23935886.destg)
	e2:SetOperation(c23935886.desop)
	c:RegisterEffect(e2)
end
-- 连接素材判定函数：检查素材组g中是否存在至少1只连接怪兽，满足这张卡“包含连接怪兽的怪兽2只以上”的召唤条件。
function c23935886.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_LINK)
end
-- ①效果的战斗破坏免疫判定值：当战斗对象为效果怪兽时返回true，使这张卡不会被效果怪兽战斗破坏。
function c23935886.indval(e,c)
	return c:IsType(TYPE_EFFECT)
end
-- 通用筛选条件：表侧表示且为效果怪兽。
function c23935886.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- ②效果的发动条件：自己场上不存在除这张卡以外的表侧表示效果怪兽时才允许发动。
function c23935886.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检测自己场上（除自身外）没有表侧表示效果怪兽存在。
	return not Duel.IsExistingMatchingCard(c23935886.filter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 计数筛选：墓地的怪兽且不是效果怪兽，或自己场上表侧表示且不是效果怪兽，用于计算②可破坏的怪兽数量上限。
function c23935886.ctfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) and c:IsType(TYPE_MONSTER) and not c:IsType(TYPE_EFFECT))
		or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and not c:IsType(TYPE_EFFECT))
end
-- ②发动时的目标设定：确认满足发动条件后，获取对方场上全部表侧表示效果怪兽，并写入破坏的操作信息（实际选择在效果处理时进行）。
function c23935886.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：自己墓地或场上是否存在至少1张非效果怪兽卡（用于确定最多可破坏数量）。
	if chk==0 then return Duel.IsExistingMatchingCard(c23935886.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil)
		-- 并且对方场上有表侧表示的效果怪兽存在，两个条件同时满足才能发动。
		and Duel.IsExistingMatchingCard(c23935886.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得对方场上所有表侧表示效果怪兽的集合，作为本效果可能破坏的对象范围。
	local g=Duel.GetMatchingGroup(c23935886.filter,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：声明本效果属于破坏效果，可能破坏的目标为对方场上这些效果怪兽，count设为1（用于外部“破坏”相关判定）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：先计算可破坏数量上限ct，然后由玩家从对方场上选择1至ct张表侧表示效果怪兽，展示选择并破坏。
function c23935886.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 计算可破坏上限：数出自己墓地以及场上表侧表示的非效果怪兽数量，作为最多可选的破坏数。
	local ct=Duel.GetMatchingGroupCount(c23935886.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	-- 给操作者显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让操作者从对方场上选择1到ct张表侧表示效果怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c23935886.filter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的卡显示为被选择对象，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 以效果原因将选择的怪兽破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
