--神樹の守護獣－牙王
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡在自己的主要阶段2以外不会成为对方的卡的效果的对象。
function c8561192.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡在自己的主要阶段2以外不会成为对方的卡的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(c8561192.tgcon)
	-- 设置不会成为对方卡的效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
end
-- 定义不能成为效果对象效果的生效条件函数
function c8561192.tgcon(e)
	-- 判断当前回合玩家不是自身，或者当前阶段不是主要阶段2（即自己的主要阶段2以外）
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer() or Duel.GetCurrentPhase()~=PHASE_MAIN2
end
