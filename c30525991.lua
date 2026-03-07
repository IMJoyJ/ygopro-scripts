--スパルタクァの呪術師
-- 效果：
-- 这张卡在场上表侧表示存在的场合，每次怪兽从卡组特殊召唤，给与对方基本分500分伤害。
function c30525991.initial_effect(c)
	-- 诱发必发效果，每次怪兽从卡组特殊召唤时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30525991,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c30525991.con)
	e1:SetTarget(c30525991.tg)
	e1:SetOperation(c30525991.op)
	c:RegisterEffect(e1)
end
-- 过滤条件：怪兽从卡组特殊召唤
function c30525991.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 效果发动条件：被特殊召唤的怪兽中包含从卡组特殊召唤的怪兽，且不是自己
function c30525991.con(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c30525991.cfilter,1,nil)
end
-- 效果处理时点：设置伤害对象和伤害值
function c30525991.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置连锁处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁处理的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：对对方造成500点伤害
function c30525991.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
