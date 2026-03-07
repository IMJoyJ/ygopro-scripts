--寡黙なるサイコミニスター
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己场上有「寡默的念力牧师」以外的念动力族怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
-- ②：从自己墓地把这张卡和1只念动力族怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册两个效果：特殊召唤条件和起动效果
function s.initial_effect(c)
	-- ①：自己场上有「寡默的念力牧师」以外的念动力族怪兽存在的场合，这张卡可以从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只念动力族怪兽除外，以场上1只表侧表示怪兽为对象才能发动。那只怪兽直到结束阶段除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在除自身外的念动力族怪兽
function s.sprfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO) and not c:IsCode(id)
end
-- 特殊召唤条件函数，判断是否满足特殊召唤的条件
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否有可用怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家场上是否存在除自身外的念动力族怪兽
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，用于判断墓地中的念动力族怪兽是否可以作为除外的代价
function s.cfilter(c)
	return c:IsRace(RACE_PSYCHO) and c:IsAbleToRemoveAsCost()
end
-- 起动效果的费用支付函数，检查是否满足除外条件
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在满足条件的念动力族怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的念动力族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数，用于判断场上表侧表示的怪兽是否可以被除外
function s.rmfilter(c)
	return c:IsFaceup() and c:IsAbleToRemove()
end
-- 起动效果的目标选择函数，选择场上表侧表示的怪兽作为除外对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.rmfilter(chkc) end
	-- 判断是否存在满足条件的场上表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上表侧表示的怪兽作为除外对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，记录将要除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 起动效果的处理函数，将目标怪兽除外并设置返回效果
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且为怪兽类型，并将其除外
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and Duel.Remove(tc,0,REASON_EFFECT+REASON_TEMPORARY)>0 then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- 注册结束阶段返回效果，使怪兽在结束阶段返回场上
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetLabelObject(tc)
		e1:SetCountLimit(1)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		-- 将返回效果注册到玩家全局环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 返回效果的触发条件函数，判断目标怪兽是否标记了返回效果
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)>0
end
-- 返回效果的处理函数，将标记的怪兽返回场上
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	-- 将标记的怪兽返回场上
	Duel.ReturnToField(e:GetLabelObject())
end
