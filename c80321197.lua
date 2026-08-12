--クリムゾン・ブレーダー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。下次的对方回合，对方不能把5星以上的怪兽召唤·特殊召唤。
function c80321197.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。下次的对方回合，对方不能把5星以上的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(80321197,0))  --"召唤限制"
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	-- 设置发动条件：这张卡战斗破坏对方怪兽并送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetOperation(c80321197.spop)
	c:RegisterEffect(e1)
end
-- 效果处理：注册限制对方召唤和特殊召唤的全局效果
function c80321197.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 下次的对方回合，对方不能把5星以上的怪兽召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c80321197.sumcon)
	e1:SetTarget(c80321197.sumlimit)
	-- 将当前回合数保存到Label中，用于后续判断是否为下个回合
	e1:SetLabel(Duel.GetTurnCount())
	-- 判断当前回合玩家是否为自己
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	-- 向玩家注册限制特殊召唤的全局效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 向玩家注册限制通常召唤的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 定义限制效果的生效条件函数
function c80321197.sumcon(e)
	-- 限制在非发动回合的对方回合生效
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()~=e:GetOwnerPlayer()
end
-- 定义限制召唤的怪兽过滤函数：5星以上的怪兽
function c80321197.sumlimit(e,c)
	return c:IsLevelAbove(5)
end
