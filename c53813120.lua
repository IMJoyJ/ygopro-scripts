--絢嵐たる権能
-- 效果：
-- ①：1回合1次，以包含「绚岚」卡的自己墓地3张速攻魔法卡为对象才能发动。以下适用。
-- ●那些卡回到卡组。那之后，自己抽1张。
-- ●这个回合中，自己场上的风属性怪兽的攻击力·守备力上升300。
-- ②：「旋风」发动时，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果无效。
-- ③：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果，注册永续魔陷发动效果和三个效果
function s.initial_effect(c)
	-- 记录该卡为「绚岚」系列卡
	aux.AddCodeList(c,5318639)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以包含「绚岚」卡的自己墓地3张速攻魔法卡为对象才能发动。以下适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ②：「旋风」发动时，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"无效效果"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 定义速攻魔法卡过滤器，用于筛选可返回卡组的卡
function s.tdfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- 定义组合检查函数，用于判断所选卡组是否包含「绚岚」卡
function s.gcheck(g)
	return g:FilterCount(Card.IsSetCard,nil,0x1d1)>0
end
-- 效果处理函数，用于选择3张速攻魔法卡并设置为效果对象
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取玩家墓地中的所有速攻魔法卡
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return dg:CheckSubGroup(s.gcheck,3,3) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=dg:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 设置效果对象为所选卡组
	Duel.SetTargetCard(g)
	-- 设置操作信息为将卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 设置操作信息为抽一张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理函数，执行卡组返回和抽卡，并提升风属性怪兽攻击力和守备力
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local g=Duel.GetTargetsRelateToChain()
	if #g~=0 then
		-- 将卡组返回卡组并检查是否成功返回，若成功则继续处理
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			-- 中断当前效果处理流程
			Duel.BreakEffect()
			-- 让玩家抽一张卡
			Duel.Draw(tp,1,REASON_EFFECT)
			-- 中断当前效果处理流程
			Duel.BreakEffect()
		end
	end
	-- 创建并注册风属性怪兽攻击力和守备力提升效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册攻击力提升效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册守备力提升效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义风属性怪兽过滤器
function s.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
-- 无效效果发动条件，判断是否为「旋风」发动的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(5318639)
end
-- 无效效果处理函数，选择对方场上一张卡并设置为效果对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否为对方场上表侧表示的卡
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 检查是否存在可无效的卡
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一张可无效的卡
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 无效效果处理函数，使目标卡效果无效并注册相关效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 注册使目标卡无效的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 注册使目标卡效果无效的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 注册使陷阱怪兽无效的效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- 盖放效果发动条件，判断是否为「旋风」破坏的效果
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(5318639)
end
-- 盖放效果处理函数，设置操作信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息为盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 盖放效果处理函数，执行盖放操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡是否在连锁中且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将卡盖放在场上
		Duel.SSet(tp,c)
	end
end
