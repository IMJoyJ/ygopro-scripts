--見えざる招き手
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「不可见之手」怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，可以把破坏的魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册「不可见之招引手」的魔法卡效果：该效果为满足条件时（对方发动魔陷且自己场上有不可见之手怪兽）才能发动的诱发型魔法卡效果，包含无效并破坏以及后续可选盖放的处理。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「不可见之手」怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，可以把破坏的魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡片为表侧表示且属于「不可见之手」系列（系列编号0x1d3），用于判断自己场上是否存在符合要求的怪兽。
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1d3)
end
-- 效果发动条件判定：对方发动了魔法·陷阱卡（且该发动可被无效），并且自己场上存在至少1只表侧表示的「不可见之手」怪兽时，条件成立。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方（rp）不是自己（tp），且被连锁的发动属于魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且该连锁可以被无效。
	return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己主要怪兽区是否存在至少1只满足cfilter1的怪兽，即表侧表示的「不可见之手」怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标设置：不取对象，仅设置操作信息；先声明无效对方发动的卡（CATEGORY_NEGATE），若该卡可破坏且与效果相关，则同时声明破坏（CATEGORY_DESTROY）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息：即将无效连锁ev中的对象卡，分类为发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置当前连锁的操作信息：如果被无效的卡可以破坏且与效果关联，则将其加入破坏对象，分类为破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先无效对方魔陷的发动；若无效成功，对那张卡进行破坏，在满足可盖放条件时询问玩家是否将其盖放到自己场上，选择是则中断效果处理并执行盖放。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 执行对连锁ev的发动无效；若无效失败（例如该效果已被其他效果保护或不在场上），则终止后续处理。
	if not Duel.NegateActivation(ev) then return end
	-- 确认被无效的卡仍与该连锁关联（发动后未离场导致失去联系），并以效果破坏它；只有破坏成功才继续后续盖放判定。
	if rc:IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and not (rc:IsLocation(LOCATION_HAND+LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown())
		-- 追加判定：目标卡不受「王家长眠之谷」等效果影响，确保它可以从当前区域被移动/盖放（通过NecroValleyFilter过滤）。
		and aux.NecroValleyFilter()(rc) then
		-- 判断盖放位置是否可用：被破坏的卡如果是场地魔法卡则使用场地区；否则检查自己魔陷区是否有空位。
		if (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			-- 确认该卡可以被盖放到魔法陷阱区（忽略魔陷区格子限制），并让玩家选择是否盖放。
			and rc:IsSSetable(true) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否盖放？"
			-- 中断当前效果处理，使后续的盖放操作作为独立处理进行，避免时点被错过。
			Duel.BreakEffect()
			-- 将目标卡以里侧表示盖放到自己场上（魔陷区或场地区，取决于卡种）。
			Duel.SSet(tp,rc)
		end
	end
end
