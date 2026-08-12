--DDD反骨王レオニダス
-- 效果：
-- ←3 【灵摆】 3→
-- ①：自己受到效果伤害时才能把这个效果发动。这张卡破坏，并且这个回合，给与基本分伤害的效果再变成让基本分回复的效果。
-- 【怪兽效果】
-- ①：自己受到效果伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害变成0。
function c92536468.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（包括灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：自己受到效果伤害时才能把这个效果发动。这张卡破坏，并且这个回合，给与基本分伤害的效果再变成让基本分回复的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92536468,0))  --"这张卡破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(c92536468.effcon)
	e2:SetTarget(c92536468.revtg)
	e2:SetOperation(c92536468.revop)
	c:RegisterEffect(e2)
	-- ①：自己受到效果伤害时才能发动。这张卡从手卡特殊召唤，自己基本分回复受到的伤害的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92536468,1))  --"这张卡从手卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_HAND)
	e3:SetCode(EVENT_DAMAGE)
	e3:SetCondition(c92536468.effcon)
	e3:SetTarget(c92536468.sptg)
	e3:SetOperation(c92536468.spop)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，自己受到的效果伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CHANGE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetValue(c92536468.damval)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e5)
end
-- 检查触发条件是否为自己受到效果伤害
function c92536468.effcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and bit.band(r,REASON_EFFECT)~=0
end
-- 灵摆效果①的发动准备（检查可行性并设置破坏自身的操作信息）
function c92536468.revtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 灵摆效果①的效果处理（破坏自身，并注册“给与伤害的效果变成回复效果”的全局效果）
function c92536468.revop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于灵摆区，则将其破坏，并在破坏成功时执行后续效果
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0 then
		-- 并且这个回合，给与基本分伤害的效果再变成让基本分回复的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_REVERSE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,1)
		e1:SetValue(c92536468.revval)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将“伤害变回复”的效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤伤害类型，仅将效果伤害转化为回复
function c92536468.revval(e,re,r,rp,rc)
	return bit.band(r,REASON_EFFECT)~=0
end
-- 怪兽效果①的发动准备（检查怪兽区域空格及自身是否能特殊召唤，并设置特殊召唤和回复LP的操作信息）
function c92536468.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置当前连锁的操作信息为自己回复等同于受到的伤害数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 怪兽效果①的效果处理（将自身特殊召唤，并回复受到的伤害数值的生命值）
function c92536468.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍在手卡，则将其以表侧表示特殊召唤，并在特殊召唤成功时执行后续效果
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 使自己回复等同于受到的伤害数值的生命值
		Duel.Recover(tp,ev,REASON_EFFECT)
	end
end
-- 将自己受到的效果伤害数值改变为0
function c92536468.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0 end
	return val
end
