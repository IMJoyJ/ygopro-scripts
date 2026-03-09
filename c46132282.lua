--甲化鎧骨格
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏，自己受到的全部伤害变成0。
function c46132282.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽进行同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46132282,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c46132282.effcon)
	e1:SetOperation(c46132282.effop)
	c:RegisterEffect(e1)
end
-- 判断此卡是否为同调召唤成功
function c46132282.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理函数，设置此卡在本回合内不会被战斗和效果破坏，并使玩家受到的所有伤害变为0
function c46132282.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡不会被效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		c:RegisterEffect(e2)
	end
	-- 自己受到的全部伤害变成0
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将e3效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 将e4效果注册给玩家
	Duel.RegisterEffect(e4,tp)
end
