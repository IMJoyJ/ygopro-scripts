--見えざる招き手
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「不可见之手」怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并破坏。那之后，可以把破坏的魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册效果：使此卡成为可发动的连锁效果，设置其分类、类型、触发事件、发动次数限制、条件、目标和效果处理函数
function s.initial_effect(c)
	-- local e1=Effect.CreateEffect(c)
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
-- 定义过滤函数：检查场上是否存在表侧表示的「不可见之手」怪兽
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x1d3)
end
-- 效果发动条件：对方发动魔法或陷阱卡且自己场上有「不可见之手」怪兽存在时才能发动
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动魔法或陷阱卡且该连锁可被无效
	return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 自己场上有「不可见之手」怪兽存在
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理的目标信息：将无效和破坏效果的处理对象设为对方发动的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置无效效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置破坏效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理函数：使对方发动无效并破坏该卡，之后判断是否可以将其在自己场上盖放
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 使对方发动无效，若无效失败则返回
	if not Duel.NegateActivation(ev) then return end
	-- 确认对方发动的卡在连锁中存在且被破坏的数量大于0
	if rc:IsRelateToChain(ev) and Duel.Destroy(eg,REASON_EFFECT)~=0
		and not (rc:IsLocation(LOCATION_HAND+LOCATION_DECK) or rc:IsLocation(LOCATION_REMOVED) and rc:IsFacedown())
		-- 确认对方发动的卡未被王家长眠之谷影响
		and aux.NecroValleyFilter()(rc) then
		-- 判断对方发动的卡是否为场地魔法或自己场上存在空魔陷区
		if (rc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
			-- 确认对方发动的卡可以盖放且玩家选择盖放
			and rc:IsSSetable(true) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否盖放？"
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将对方发动的卡在自己场上盖放
			Duel.SSet(tp,rc)
		end
	end
end
