--ヒステリック天使
-- 效果：
-- 用自己场上2只怪兽做祭品，自己的基本分回复1000分。
function c21297224.initial_effect(c)
	-- 用自己场上2只怪兽做祭品，自己的基本分回复1000分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21297224,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c21297224.cost)
	e1:SetTarget(c21297224.target)
	e1:SetOperation(c21297224.operation)
	c:RegisterEffect(e1)
end
-- 代价函数：选择自己场上2只怪兽作为祭品并解放，以作为发动效果的代价。
function c21297224.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段：确认自己场上是否存在至少2只可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	-- 让玩家从自己场上选择2只怪兽作为解放对象。
	local g=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	-- 将选择的2只怪兽作为代价解放。
	Duel.Release(g,REASON_COST)
end
-- 对象设定函数：不取对象，设定回复目标玩家与回复数值，并登记操作信息。
function c21297224.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设定回复对象为发动玩家自身。
	Duel.SetTargetPlayer(tp)
	-- 设定回复数值为1000。
	Duel.SetTargetParam(1000)
	-- 登记操作信息，声明本连锁包含回复效果，回复对象为发动玩家，预定回复数值为1000。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理函数：实际执行基本分回复。
function c21297224.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的目标玩家与回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应数值的基本分，回复原因视为效果。
	Duel.Recover(p,d,REASON_EFFECT)
end
