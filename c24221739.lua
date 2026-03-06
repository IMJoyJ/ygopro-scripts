--神殿を守る者
-- 效果：
-- 当这张卡在场上以表侧表示存在时，对方不能在抽卡阶段以外进行抽卡。
function c24221739.initial_effect(c)
	-- 当这张卡在场上以表侧表示存在时，对方不能在抽卡阶段以外进行抽卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c24221739.con)
	c:RegisterEffect(e1)
end
-- 判断当前阶段是否不是抽卡阶段
function c24221739.con(e)
	-- 若当前阶段不是抽卡阶段则效果适用
	return Duel.GetCurrentPhase()~=PHASE_DRAW
end
