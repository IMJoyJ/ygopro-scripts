--デス・ウサギ
-- 效果：
-- 反转：衍生物以外的自己场上表侧表示存在的通常怪兽每有1只，给与对方基本分1000分伤害。
function c49144107.initial_effect(c)
	-- 反转：衍生物以外的自己场上表侧表示存在的通常怪兽每有1只，给与对方基本分1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49144107,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c49144107.target)
	e1:SetOperation(c49144107.operation)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于筛选出己方场上表侧表示且非衍生物的通常怪兽，作为伤害计算的数量依据。
function c49144107.filter(c)
	local tpe=c:GetType()
	return c:IsFaceup() and bit.band(tpe,TYPE_NORMAL)~=0 and bit.band(tpe,TYPE_TOKEN)==0
end
-- 发动反转效果时，判定阶段直接允许发动；设置伤害对象为对方，并统计己方场上符合条件的通常怪兽数量乘以1000作为伤害值，写入连锁信息供处理时使用。
function c49144107.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 统计己方场上表侧表示、非衍生物的通常怪兽数量，并乘以1000，得到本次效果的伤害值。
	local dam=Duel.GetMatchingGroupCount(c49144107.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 将计算出的伤害值dam设置为当前连锁的对象参数，便于后续处理时读取。
	Duel.SetTargetParam(dam)
	-- 登记操作信息：本次连锁包含造成伤害的效果，对象为对方玩家，伤害值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时执行实际伤害：从连锁信息中取出对象玩家，重新统计当时己方场上符合条件的通常怪兽数量乘以1000，然后对该玩家造成效果伤害。
function c49144107.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁记录的对象玩家（即伤害对象）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 重新统计己方场上表侧表示、非衍生物的通常怪兽数量并乘以1000，得到此时应造成的伤害值。
	local dam=Duel.GetMatchingGroupCount(c49144107.filter,tp,LOCATION_MZONE,0,nil)*1000
	-- 对对象玩家p造成dam点效果伤害（伤害原因为效果）。
	Duel.Damage(p,dam,REASON_EFFECT)
end
