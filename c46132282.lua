--甲化鎧骨格
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏，自己受到的全部伤害变成0。
function c46132282.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上（此处调整任意，调整以外的怪兽任意），作为同调素材的限制。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 为这张卡注册①效果：这张卡同调召唤成功的场合发动。这个回合，这张卡不会被战斗·效果破坏，自己受到的全部伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46132282,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c46132282.effcon)
	e1:SetOperation(c46132282.effop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：当前特殊召唤成功且召唤类型为同调召唤（即这张卡是否以同调召唤方式特殊召唤成功）。
function c46132282.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果处理：若这张卡仍与效果相关，则赋予其本回合内不会被效果破坏和不会被战斗破坏的耐性；然后让自己本回合受到的全部伤害变为0。
function c46132282.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 对应效果原文‘这张卡不会被战斗·效果破坏’中的‘不会被效果破坏’部分，设置不会被效果破坏的效果。
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
	-- 对应效果原文‘自己受到的全部伤害变成0’，设置改变伤害数值为0，并附带效果伤害无效标记，使自身受到的所有伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CHANGE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将e3这个改变伤害数值的永续效果注册给玩家tp，使tp受到的任何伤害数值变为0。
	Duel.RegisterEffect(e3,tp)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e4:SetReset(RESET_PHASE+PHASE_END)
	-- 将e4这个“效果伤害变成0”的标记效果注册给玩家tp，用于在规则上认定tp已受效果伤害无效化，与e3共同完成伤害变为0。
	Duel.RegisterEffect(e4,tp)
end
