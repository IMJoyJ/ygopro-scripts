--ゲリラカイト
-- 效果：
-- 「游击风筝」的效果1回合只能使用1次。
-- ①：这张卡从场上送去墓地的场合发动。给与对方500伤害。
function c54629413.initial_effect(c)
	-- 「游击风筝」的效果1回合只能使用1次。①：这张卡从场上送去墓地的场合发动。给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54629413,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,54629413)
	e1:SetCondition(c54629413.damcon)
	e1:SetTarget(c54629413.damtg)
	e1:SetOperation(c54629413.damop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：这张卡之前的位置是否在场上（即从场上送去墓地）
function c54629413.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 设置效果发动的目标：将对方玩家设为对象，伤害数值设为500，并注册伤害操作信息
function c54629413.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数（伤害值）设置为500
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为：给与对方玩家500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行效果处理：获取连锁信息中的目标玩家和伤害数值，并给与对方伤害
function c54629413.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数（伤害值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
