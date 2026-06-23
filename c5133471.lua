--ギャラクシー・サイクロン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
function c5133471.initial_effect(c)
	-- ①：以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5133471,0))  --"破坏盖放的魔法·陷阱卡"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5133471.target)
	e1:SetOperation(c5133471.activate)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5133471,1))  --"破坏表侧表示的魔法·陷阱卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,5133471)
	-- 效果条件：这张卡送去墓地的回合不能发动此效果
	e2:SetCondition(aux.exccon)
	-- 效果费用：把这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c5133471.destg)
	e2:SetOperation(c5133471.activate)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断目标是否为里侧表示的魔法·陷阱卡
function c5133471.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：选择场上1张里侧表示的魔法·陷阱卡作为对象并设置破坏操作信息
function c5133471.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5133471.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查阶段：确认场上是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c5133471.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示信息：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1张里侧表示的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c5133471.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将本次效果要处理的破坏对象及数量记录到连锁中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果执行：对选定的目标卡片进行破坏处理
function c5133471.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：取得当前连锁中的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 实际破坏：以效果原因将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：判断目标是否为表侧表示的魔法·陷阱卡
function c5133471.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理：选择场上1张表侧表示的魔法·陷阱卡作为对象并设置破坏操作信息
function c5133471.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5133471.filter2(chkc) and chkc~=e:GetHandler() end
	-- 检查阶段：确认场上是否存在满足条件的目标卡片
	if chk==0 then return Duel.IsExistingTarget(c5133471.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示信息：提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择目标：从场上选择1张表侧表示的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c5133471.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置操作信息：将本次效果要处理的破坏对象及数量记录到连锁中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
