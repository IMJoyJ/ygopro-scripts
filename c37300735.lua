--TG ジェット・ファルコン
-- 效果：
-- 这张卡作为同调召唤的素材送去墓地的场合，给与对方基本分500分伤害。
function c37300735.initial_effect(c)
	-- 诱发必发效果，当这张卡作为同调召唤的素材送去墓地时发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37300735,0))  --"给予对方500伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c37300735.damcon)
	e1:SetTarget(c37300735.damtg)
	e1:SetOperation(c37300735.damop)
	c:RegisterEffect(e1)
end
-- 满足条件：此卡在墓地且因同调召唤被送入墓地
function c37300735.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 设置连锁处理目标为对方玩家，伤害值为500
function c37300735.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁处理的目标玩家设置为对方（1-tp）
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁处理的目标参数设置为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为伤害效果，对象为对方玩家，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时，对对方玩家造成500点伤害
function c37300735.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
