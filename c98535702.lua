--ダメージ・ワクチンΩMAX
-- 效果：
-- 自己因战斗或者卡的效果受到伤害时才能发动。自己基本分回复自己受到的那次伤害的数值。
function c98535702.initial_effect(c)
	-- 自己因战斗或者卡的效果受到伤害时才能发动。自己基本分回复自己受到的那次伤害的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetTarget(c98535702.rectg)
	e1:SetOperation(c98535702.recop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标过滤与检测，确认是自己受到伤害，并设置回复的对象玩家与回复数值
function c98535702.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return ep==tp end
	-- 将当前连锁的对象玩家设置为自己
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为受到的伤害数值
	Duel.SetTargetParam(ev)
	-- 设置当前连锁的操作信息为：玩家tp回复ev数值的生命值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理的执行函数，获取设定的回复对象和数值并执行回复
function c98535702.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的目标玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应数值的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
