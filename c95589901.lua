--大狼のいたずら
-- 效果：
-- 依序适用以下效果。
-- ●对方场上的怪兽的等级下降2。
-- ●自己场上的怪兽的等级上升2。
-- 这张卡被送去墓地的自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「饿狼的恶作剧」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 声明大狼的恶作剧效果的初始设置函数
function s.initial_effect(c)
	-- 依序适用以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这张卡被送去墓地的
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	-- 自己回合的主要阶段：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「饿狼的恶作剧」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 判断是否存在符合条件的卡作为发动对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在1只以上表侧表示且等级2以上的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 或者自己场上是否存在1只以上表侧表示且等级1以上的怪兽
		or Duel.IsExistingMatchingCard(s.lvfilter2,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤条件：表侧表示且等级2以上的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 过滤条件：表侧表示且等级1以上的怪兽
function s.lvfilter2(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- 执行处理阶段：改变双方场上怪兽的等级
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上表侧表示且等级2以上的怪兽作为卡片组
	local og=Duel.GetMatchingGroup(s.lvfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上满足条件的怪兽
	for tc in aux.Next(og) do
		-- ●对方场上的怪兽的等级下降2。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	-- 中断当前效果，使之后的效果处理视为不同时处理
	if og:GetCount()>0 then Duel.BreakEffect() end
	-- 获取自己场上表侧表示且等级1以上的怪兽作为卡片组
	local sg=Duel.GetMatchingGroup(s.lvfilter2,tp,LOCATION_MZONE,0,nil)
	-- 遍历自己场上满足条件的怪兽
	for tc in aux.Next(sg) do
		-- ●自己场上的怪兽的等级上升2。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_LEVEL)
		e2:SetValue(2)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
-- 执行处理阶段：记录这张卡被送去墓地
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否满足墓地发动的条件：这张卡在当前回合被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)>0
end
-- 过滤条件：表侧表示的卡
function s.tfilter(c)
	return c:IsFaceup()
end
-- 判断是否存在符合条件的卡作为发动的对象，并检查是否可以将这张卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return s.tfilter(chkc) and chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return c:IsAbleToHand()
		-- 检查场上是否存在可以成为对象的表侧表示的卡
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 给玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示卡为对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息：包含破坏效果，对象为选择的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：包含回到手卡效果，对象为这张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 执行处理阶段：破坏选择的卡，把这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡，即要破坏的卡
	local tc=Duel.GetFirstTarget()
	-- 如果该卡还在场上并且成功被效果破坏
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 并且这张卡还在墓地且不受王家长眠之谷的影响
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 把这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
