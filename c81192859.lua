--Ga－P.U.N.K.ワイルド・ピッキング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己的「朋克」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。自己场上的全部「朋克」怪兽在这个回合不会被战斗破坏。
function c81192859.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己的「朋克」怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81192859,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,81192859)
	e2:SetCondition(c81192859.descon)
	e2:SetTarget(c81192859.destg)
	e2:SetOperation(c81192859.desop)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。自己场上的全部「朋克」怪兽在这个回合不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81192859,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c81192859.limcon)
	e3:SetOperation(c81192859.limop)
	c:RegisterEffect(e3)
end
-- 检查是否满足效果①的发动条件：自己的「朋克」怪兽与对方怪兽进行战斗的伤害步骤开始时，并记录该对方怪兽
function c81192859.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上正处于战斗中的怪兽
	local ac=Duel.GetBattleMonster(tp)
	if not (ac and ac:IsFaceup() and ac:IsSetCard(0x171)) then return false end
	local bc=ac:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle()
end
-- 效果①的发动准备：确认要破坏的对方怪兽存在，并设置破坏的操作信息
function c81192859.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置操作信息，表示该效果的处理为破坏该对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果①的效果处理：如果该对方怪兽仍在场且处于战斗中，则将其破坏
function c81192859.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() then
		-- 将该对方怪兽因效果破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上表侧表示的「朋克」怪兽
function c81192859.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x171)
end
-- 检查是否满足效果②的发动条件：魔法与陷阱区域的这张卡被对方的效果破坏，且自己场上存在「朋克」怪兽
function c81192859.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		-- 检查自己场上表侧表示的「朋克」怪兽数量是否大于0
		and Duel.GetMatchingGroupCount(c81192859.cfilter,tp,LOCATION_MZONE,0,nil)>0
end
-- 效果②的效果处理：使自己场上所有的「朋克」怪兽在这个回合不会被战斗破坏
function c81192859.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「朋克」怪兽
	local g=Duel.GetMatchingGroup(c81192859.cfilter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部「朋克」怪兽在这个回合不会被战斗破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(81192859,2))  --"「雅乐朋克野蛮弹奏」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
