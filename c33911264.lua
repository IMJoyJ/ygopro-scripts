--太陽風帆船
-- 效果：
-- 自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。此外，每次自己的准备阶段这张卡的等级上升1星。「太阳风帆船」在场上只能有1只表侧表示存在。
function c33911264.initial_effect(c)
	c:SetUniqueOnField(1,1,33911264)
	-- 效果原文内容：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c33911264.spcon)
	e1:SetOperation(c33911264.spop)
	c:RegisterEffect(e1)
	-- 效果原文内容：此外，每次自己的准备阶段这张卡的等级上升1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33911264,0))  --"等级上升"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c33911264.lvcon)
	e2:SetOperation(c33911264.lvop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断特殊召唤条件，即自己场上没有怪兽且有可用怪兽区。
function c33911264.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：判断自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 规则层面作用：判断自己场上是否有可用怪兽区。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 规则层面作用：设置特殊召唤时的原本攻击力和守备力为一半（攻击力400，守备力1200）。
function c33911264.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 效果原文内容：这个方法特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(400)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
end
-- 规则层面作用：判断准备阶段是否为自己的回合。
function c33911264.lvcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断当前回合玩家是否为效果持有者。
	return Duel.GetTurnPlayer()==tp
end
-- 规则层面作用：在准备阶段提升等级1星。
function c33911264.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 效果原文内容：「太阳风帆船」在场上只能有1只表侧表示存在。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
