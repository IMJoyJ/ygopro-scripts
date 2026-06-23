--烙印の獣
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己·对方的主要阶段，自己场上有「深渊之兽」怪兽存在的场合，把自己场上1只龙族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：自己·对方的结束阶段，以自己墓地1张「烙印」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
local s,id,o=GetID()
-- 注册卡牌的初始效果，包括允许发动的空效果和两个效果的定义
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己·对方的主要阶段，自己场上有「深渊之兽」怪兽存在的场合，把自己场上1只龙族怪兽解放，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetLabel(0)
	e1:SetCondition(s.descon)
	e1:SetCost(s.descost)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以自己墓地1张「烙印」永续魔法·永续陷阱卡为对象才能发动。那张卡在自己场上表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收墓地永续魔陷"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：当前阶段为主要阶段1或主要阶段2，并且自己场上存在「深渊之兽」怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查自己场上是否存在至少1只「深渊之兽」怪兽
		and Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x188)
end
-- 判断解放的龙族怪兽是否满足条件：为龙族、为己方控制或正面表示，并且对方场上存在可破坏的卡
function s.cfilter(c,tp)
	return c:IsRace(RACE_DRAGON) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查对方场上是否存在至少1张可作为对象的卡
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,c)
end
-- 效果①的费用支付函数，设置标签为1表示已支付费用
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 效果①的发动目标选择函数，处理解放龙族怪兽和选择破坏对象的逻辑
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local l=e:GetLabel()==1
	if chk==0 then
		e:SetLabel(0)
		-- 检查是否满足解放龙族怪兽的条件
		return l and Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
	end
	if l then
		e:SetLabel(0)
		-- 提示玩家选择要解放的龙族怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择满足条件的龙族怪兽进行解放
		local sg=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
		-- 执行解放操作，将选中的怪兽从场上解放作为费用
		Duel.Release(sg,REASON_COST)
	end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①的发动处理函数，执行破坏操作
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍有效，则将其破坏
	if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
-- 效果②的发动条件：当前阶段为结束阶段
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 判断墓地中的卡是否满足条件：为「烙印」永续魔法或陷阱卡、类型为永续、未被禁止、且在场上唯一
function s.filter(c,tp)
	return c:IsSetCard(0x15d) and c:IsType(TYPE_CONTINUOUS)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 效果②的目标选择函数，处理选择墓地中的「烙印」永续魔法或陷阱卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	-- 检查场上是否有足够的魔法陷阱区域放置卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地中是否存在至少1张满足条件的「烙印」永续魔法或陷阱卡
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择满足条件的墓地卡
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息，表示将要将卡从墓地移至场上
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果②的发动处理函数，执行将卡放置到场上的操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 若目标卡仍有效，则将其移至场上并设置为表侧表示
	if tc:IsRelateToEffect(e) then Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
end
