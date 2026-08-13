--反射の聖刻印
-- 效果：
-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
function c47360060.initial_effect(c)
	-- 把自己场上1只名字带有「圣刻」的怪兽解放才能发动。效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c47360060.condition)
	e1:SetCost(c47360060.cost)
	e1:SetTarget(c47360060.target)
	e1:SetOperation(c47360060.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：本效果仅在当前连锁中存在可被无效的效果发动，且该发动是效果怪兽的效果或魔法·陷阱卡的发动时才能发动。
function c47360060.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体条件：当前连锁的该次发动可被无效，并且发动源属于怪兽效果（效果怪兽的效果）或魔法/陷阱卡的发动范畴。
	return Duel.IsChainNegatable(ev) and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
-- 代价筛选函数：用于选择要解放的怪兽，要求是卡名带有「圣刻」字段，并且未处于战斗破坏确定状态（尚未因战斗破坏而离场）。
function c47360060.cfilter(c)
	return c:IsSetCard(0x69) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动代价处理：从自己场上选择1只满足条件的「圣刻」怪兽并解放，以作为发动本卡的代价。
function c47360060.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查模式：若chk==0，则确认自己场上是否存在至少1只可解放且满足筛选条件的「圣刻」怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c47360060.cfilter,1,nil) end
	-- 选择解放对象：从自己场上选取1只满足筛选条件的可解放「圣刻」怪兽。
	local g=Duel.SelectReleaseGroup(tp,c47360060.cfilter,1,1,nil)
	-- 执行解放：将选择的怪兽解放，解放原因记为COST（作为发动代价）。
	Duel.Release(g,REASON_COST)
end
-- 目标与操作信息设置：本卡发动时不取对象；设置将无效当前连锁发动的操作信息，若被无效的卡可被破坏且仍与效果关联，则同时设置破坏该卡的操作信息。
function c47360060.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：声明本效果包含“无效发动”，针对的对象为当前连锁中发动的那组卡片（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：声明本效果同时包含“破坏”，针对对象仍为当前连锁中发动的卡（eg），用于判定破坏效果的处理。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：若成功无效当前连锁的发动，且发动卡仍与该效果关联（没有失去联系），则将发动卡破坏。
function c47360060.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判定：先尝试无效该连锁的发动；只有无效成功且对象卡仍未离场/仍与效果关联时，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将当前连锁的发动卡（组）以效果原因破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
