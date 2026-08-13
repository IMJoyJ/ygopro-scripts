--神鳥シムルグ
-- 效果：
-- 这张卡不能特殊召唤。这张卡上级召唤的场合，解放的怪兽必须是风属性怪兽。只要这张卡在场上表侧表示存在，双方玩家在每次双方的结束阶段受到1000分伤害。这个时候，各自玩家受到的伤害变少魔法·陷阱卡控制数量×500的数值。
function c14989021.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡上级召唤的场合，解放的怪兽必须是风属性怪兽。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRIBUTE_LIMIT)
	e2:SetValue(c14989021.tlimit)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，双方玩家在每次双方的结束阶段受到1000分伤害。这个时候，各自玩家受到的伤害变少魔法·陷阱卡控制数量×500的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(14989021,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c14989021.damtg)
	e3:SetOperation(c14989021.damop)
	c:RegisterEffect(e3)
end
-- EFFECT_TRIBUTE_LIMIT的判定函数：若怪兽不是风属性则返回真，表示该怪兽不能被解放作为这张卡的上级召唤素材。
function c14989021.tlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤器：判断卡是否为魔法卡或陷阱卡，用于统计场上魔法·陷阱卡的数量。
function c14989021.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 伤害效果的发动条件判定：在效果发动时（chk==0）直接返回true，表示该必发伤害效果可以发动，并设置操作信息为对双方玩家造成伤害。
function c14989021.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本连锁的操作信息为伤害（CATEGORY_DAMAGE），目标为双方玩家（PLAYER_ALL）；具体伤害数值在效果处理时确定，故targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 效果处理：先确认此卡仍与效果相关；分别统计发动者tp和对方1-tp场上魔法·陷阱卡的数量c1、c2，若对应数量小于2则对该玩家造成1000减去其魔陷数量×500的效果伤害，否则不造成伤害。
function c14989021.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 统计发动者tp自己场上的魔法·陷阱卡数量，存入c1。
	local c1=Duel.GetMatchingGroupCount(c14989021.filter,tp,LOCATION_ONFIELD,0,nil)
	if c1<2 then
		-- 以效果原因对发动者tp造成1000-c1*500点伤害（该值在c1<2时为正数）。
		Duel.Damage(tp,1000-c1*500,REASON_EFFECT)
	end
	-- 统计对方玩家（1-tp）场上的魔法·陷阱卡数量，存入c2。
	local c2=Duel.GetMatchingGroupCount(c14989021.filter,1-tp,LOCATION_ONFIELD,0,nil)
	if c2<2 then
		-- 以效果原因对对方玩家（1-tp）造成1000-c2*500点伤害（该值在c2<2时为正数）。
		Duel.Damage(1-tp,1000-c2*500,REASON_EFFECT)
	end
end
