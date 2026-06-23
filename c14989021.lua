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
-- 上级召唤时，解放的怪兽必须是风属性怪兽
function c14989021.tlimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤魔法·陷阱卡
function c14989021.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置连锁操作信息为伤害效果
function c14989021.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,0)
end
-- 处理结束阶段伤害效果，根据场上魔法·陷阱卡数量减少受到的伤害
function c14989021.damop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 统计我方场上魔法·陷阱卡数量
	local c1=Duel.GetMatchingGroupCount(c14989021.filter,tp,LOCATION_ONFIELD,0,nil)
	if c1<2 then
		-- 对我方造成伤害，伤害值为1000减去我方魔法·陷阱卡数量乘以500
		Duel.Damage(tp,1000-c1*500,REASON_EFFECT)
	end
	-- 统计对方场上魔法·陷阱卡数量
	local c2=Duel.GetMatchingGroupCount(c14989021.filter,1-tp,LOCATION_ONFIELD,0,nil)
	if c2<2 then
		-- 对对方造成伤害，伤害值为1000减去对方魔法·陷阱卡数量乘以500
		Duel.Damage(1-tp,1000-c2*500,REASON_EFFECT)
	end
end
