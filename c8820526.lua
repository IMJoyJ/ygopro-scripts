--EMクレイブレイカー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：上级召唤的这张卡和对方怪兽进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力直到回合结束时下降自己的额外卡组的表侧表示的灵摆怪兽数量×500。
-- ②：这张卡在墓地存在，自己把2只以上的怪兽同时灵摆召唤时才能发动。墓地的这张卡加入手卡。
function c8820526.initial_effect(c)
	-- ①：上级召唤的这张卡和对方怪兽进行战斗的伤害计算时才能发动。那只对方怪兽的攻击力直到回合结束时下降自己的额外卡组的表侧表示的灵摆怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8820526,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,8820526)
	e1:SetCondition(c8820526.atkcon)
	e1:SetOperation(c8820526.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己把2只以上的怪兽同时灵摆召唤时才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8820526,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,8820527)
	e2:SetCondition(c8820526.thcon)
	e2:SetTarget(c8820526.thtg)
	e2:SetOperation(c8820526.thop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自身是上级召唤且正与对方怪兽进行战斗，在伤害计算时，且自己额外卡组有表侧表示的灵摆怪兽
function c8820526.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and bc:IsFaceup() and bc:IsRelateToBattle() and c:IsSummonType(SUMMON_TYPE_ADVANCE)
		-- 检查自己的额外卡组是否存在至少1张表侧表示的灵摆怪兽
		and Duel.GetMatchingGroupCount(c8820526.filter,tp,LOCATION_EXTRA,0,nil)>0
end
-- 过滤条件：表侧表示且是灵摆怪兽的卡
function c8820526.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 效果处理：计算自己额外卡组表侧表示的灵摆怪兽数量，使进行战斗的对方怪兽的攻击力直到回合结束时下降该数量×500
function c8820526.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 计算攻击力下降的具体数值（额外卡组表侧表示灵摆怪兽数量×500）
	local ct=Duel.GetMatchingGroupCount(c8820526.filter,tp,LOCATION_EXTRA,0,nil)*500
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() and ct>0 then
		-- 那只对方怪兽的攻击力直到回合结束时下降自己的额外卡组的表侧表示的灵摆怪兽数量×500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		bc:RegisterEffect(e1)
	end
end
-- 过滤条件：由自己特殊召唤且召唤方式为灵摆召唤的怪兽
function c8820526.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 判断是否满足发动条件：自己同时灵摆召唤了2只以上的怪兽
function c8820526.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c8820526.cfilter,2,nil,tp)
end
-- 效果发动准备：检查自身是否能加入手卡，并设置回收的操作信息
function c8820526.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：将墓地的这张卡加入手卡并给对方确认
function c8820526.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end
