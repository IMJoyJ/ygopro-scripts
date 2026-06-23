--惨禍の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「咒眼」怪兽存在的场合，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果破坏的卡不去墓地而除外。
function c43011492.initial_effect(c)
	-- 创建效果，设置为魔法卡发动效果，破坏效果，自由时点，取对象效果，一回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,43011492+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c43011492.condition)
	e1:SetTarget(c43011492.target)
	e1:SetOperation(c43011492.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断是否为「咒眼」怪兽且表侧表示
function c43011492.filter(c)
	return c:IsSetCard(0x129) and c:IsFaceup()
end
-- 条件函数，检查自己场上是否存在「咒眼」怪兽
function c43011492.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「咒眼」怪兽
	return Duel.IsExistingMatchingCard(c43011492.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断是否为魔法或陷阱卡且满足破坏条件
function c43011492.desfilter(c,res)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and (not res or c:IsAbleToRemove())
end
-- 过滤函数，用于判断是否为「太阴之咒眼」且表侧表示
function c43011492.filter1(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 目标选择函数，检查对方场上是否存在魔法或陷阱卡作为破坏对象，并设置操作信息
function c43011492.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己魔法与陷阱区域是否存在「太阴之咒眼」
	local res=Duel.IsExistingMatchingCard(c43011492.filter1,tp,LOCATION_SZONE,0,1,nil)
	if chkc then return chkc:IsOnField() and c43011492.desfilter(chkc,res) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在魔法或陷阱卡作为破坏对象
	if chk==0 then return Duel.IsExistingTarget(c43011492.desfilter,tp,0,LOCATION_ONFIELD,1,nil,res) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一张魔法或陷阱卡作为破坏对象
	local g=Duel.SelectTarget(tp,c43011492.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil,res)
	-- 设置操作信息，确定破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 发动函数，根据是否满足条件决定破坏去向（墓地或除外）
function c43011492.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 检查自己魔法与陷阱区域是否存在「太阴之咒眼」
		if Duel.IsExistingMatchingCard(c43011492.filter1,tp,LOCATION_SZONE,0,1,nil) then
			-- 将目标卡以效果原因破坏并除外
			Duel.Destroy(tc,REASON_EFFECT,LOCATION_REMOVED)
		else
			-- 将目标卡以效果原因破坏并送入墓地
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
