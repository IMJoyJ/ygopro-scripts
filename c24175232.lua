--ネフティスの蒼凰神
-- 效果：
-- 「奈芙提斯的轮回」降临。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡以及自己场上的表侧表示的卡之中选「奈芙提斯」卡任意数量破坏。那之后，选破坏数量的对方场上的怪兽破坏。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
function c24175232.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从手卡以及自己场上的表侧表示的卡之中选「奈芙提斯」卡任意数量破坏。那之后，选破坏数量的对方场上的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,24175232)
	e1:SetTarget(c24175232.destg)
	e1:SetOperation(c24175232.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地的场合，下次的自己准备阶段才能发动。这张卡从墓地特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c24175232.spr)
	c:RegisterEffect(e2)
	-- 「奈芙提斯的轮回」降临。这个卡名的①②的效果1回合各能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24175232,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,24175233)
	e3:SetCondition(c24175232.spcon)
	e3:SetTarget(c24175232.sptg)
	e3:SetOperation(c24175232.spop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选「奈芙提斯」卡（包括手牌和场上的表侧表示的卡）
function c24175232.desfilter(c)
	return c:IsSetCard(0x11f) and (c:IsFaceup() or not c:IsOnField())
end
-- 效果处理的条件判断，检查是否满足发动条件
function c24175232.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否有怪兽
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		-- 检查自己手牌和场上的「奈芙提斯」卡是否存在
		and Duel.IsExistingMatchingCard(c24175232.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 设置连锁操作信息，表示将要破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,2,0,0)
end
-- 效果处理函数，执行破坏操作
function c24175232.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己手牌和场上的「奈芙提斯」卡
	local g=Duel.GetMatchingGroup(c24175232.desfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,nil)
	-- 获取对方场上的怪兽
	local og=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g*#og==0 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:Select(tp,1,#og,nil)
	-- 破坏选定的卡并返回实际破坏数量
	local oc=Duel.Destroy(sg,REASON_EFFECT)
	if oc==0 then return end
	-- 中断当前效果，使后续效果处理视为不同时处理
	Duel.BreakEffect()
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg2=og:Select(tp,oc,oc,nil)
	-- 破坏选定的对方怪兽
	Duel.Destroy(sg2,REASON_EFFECT)
end
-- 当此卡被战斗或效果破坏送去墓地时触发的效果处理
function c24175232.spr(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsReason(REASON_DESTROY)) then return end
	-- 判断是否为自己的准备阶段
	if Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 记录当前回合数作为标签
		e:SetLabel(Duel.GetTurnCount())
		c:RegisterFlagEffect(24175232,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,2)
	else
		e:SetLabel(0)
		c:RegisterFlagEffect(24175232,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 判断特殊召唤条件是否满足
function c24175232.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否可以特殊召唤、是否为当前回合、是否为当前玩家、是否有标记
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and tp==Duel.GetTurnPlayer() and c:GetFlagEffect(24175232)>0
end
-- 设置特殊召唤的处理条件
function c24175232.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查场上是否有足够的召唤位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	c:ResetFlagEffect(24175232)
end
-- 特殊召唤处理函数
function c24175232.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
