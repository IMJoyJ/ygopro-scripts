--サーチライトメン
-- 效果：
-- 反转：这个回合对方玩家不能在场上把卡盖放。
function c67646312.initial_effect(c)
	-- 反转：这个回合对方玩家不能在场上把卡盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67646312,0))  --"盖卡限制"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c67646312.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：在当前回合内，限制对方玩家进行任何形式的盖卡操作（包括通常召唤盖放怪兽、盖放魔陷、将怪兽转为里侧表示以及里侧表示特殊召唤）。
function c67646312.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方玩家不能在场上把卡盖放。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_MSET)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向对方玩家注册不能通常召唤盖放怪兽的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SSET)
	-- 向对方玩家注册不能盖放魔法·陷阱卡的效果。
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_TURN_SET)
	-- 向对方玩家注册不能将怪兽转为里侧表示的效果。
	Duel.RegisterEffect(e3,tp)
	local e4=e1:Clone()
	e4:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e4:SetTarget(c67646312.sumlimit)
	-- 向对方玩家注册不能以里侧表示特殊召唤怪兽的效果。
	Duel.RegisterEffect(e4,tp)
end
-- 过滤特殊召唤的表示形式，若为里侧表示则禁止特殊召唤。
function c67646312.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return bit.band(sumpos,POS_FACEDOWN)>0
end
