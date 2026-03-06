--GP－ペダル・トゥ・メタル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只「黄金荣耀」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。
-- ②：这个回合有自己场上的表侧表示的「黄金荣耀」怪兽被战斗·效果破坏的场合，结束阶段才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡牌的两个效果：①效果（改变攻击力、不被破坏、不能发动效果）和②效果（结束阶段盖放）
function s.initial_effect(c)
	-- ①：以自己场上1只「黄金荣耀」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害步骤前发动
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这个回合有自己场上的表侧表示的「黄金荣耀」怪兽被战斗·效果破坏的场合，结束阶段才能发动。墓地的这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册一个全局持续效果，用于检测是否有「黄金荣耀」怪兽被战斗或效果破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetOperation(s.check)
		-- 将e3效果注册到全局环境，用于监听破坏事件
		Duel.RegisterEffect(e3,0)
	end
end
-- 定义过滤器函数，用于筛选场上表侧表示的「黄金荣耀」怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x192)
end
-- 设置效果目标选择函数，要求选择一个自己场上的「黄金荣耀」怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 判断是否满足选择目标的条件：场上存在一个自己控制的「黄金荣耀」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择一个表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个自己场上的「黄金荣耀」怪兽作为效果对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 执行效果①的处理函数，为对象怪兽添加不被战斗破坏、不被效果破坏、不能发动效果和攻击力+500的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 为对象怪兽添加不被战斗破坏的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	tc:RegisterEffect(e2)
	-- 为对象怪兽添加不被效果破坏的效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
	if tc:IsFaceup() then
		local e4=e1:Clone()
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetValue(500)
		tc:RegisterEffect(e4)
	end
end
-- 设置效果②的发动条件，判断是否在本回合有「黄金荣耀」怪兽被破坏
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断玩家是否已注册过标识效果，表示本回合已有「黄金荣耀」怪兽被破坏
	return Duel.GetFlagEffect(tp,id)>0
end
-- 设置效果②的目标选择函数，判断墓地的卡是否可以盖放
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息，表示将要盖放这张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 执行效果②的处理函数，将墓地的卡盖放到场上
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否还在场上，若在则执行盖放操作
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
-- 定义过滤器函数，用于筛选被破坏的「黄金荣耀」怪兽
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x192) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 注册全局持续效果的处理函数，检测是否有「黄金荣耀」怪兽被破坏并设置标识
function s.check(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		-- 若破坏事件组中存在符合条件的「黄金荣耀」怪兽，则为对应玩家注册标识效果
		if eg:IsExists(s.cfilter,1,nil,p) then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
	end
end
