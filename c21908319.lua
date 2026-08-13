--コザッキーの自爆装置
-- 效果：
-- 给与破坏盖放的这张卡的玩家1000分伤害。
function c21908319.initial_effect(c)
	-- 给与破坏盖放的这张卡的玩家1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21908319,0))  --"1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c21908319.damcon)
	e1:SetTarget(c21908319.damtg)
	e1:SetOperation(c21908319.damop)
	c:RegisterEffect(e1)
end
-- 此效果仅在自身被破坏前位于魔法与陷阱区域且为里侧表示时才能发动，即判断“盖放的这张卡”被破坏这一事实。
function c21908319.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 效果发动时进行目标设定：将伤害的对象玩家锁定为破坏这张卡的玩家，并设定伤害值为1000，同时向系统登记该连锁为伤害效果。
function c21908319.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 把当前连锁处理的对象玩家设置为破坏这张卡的玩家rp，即由对方承受伤害。
	Duel.SetTargetPlayer(rp)
	-- 把当前连锁的对象参数设置为1000，作为后续实际造成的伤害数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：声明本连锁为伤害效果，目标玩家是rp，预计造成1000点伤害，供时点与相关卡牌判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,1000)
end
-- 效果处理阶段：从当前连锁中取出之前设定的对象玩家和伤害数值，对那位玩家造成1000点效果伤害。
function c21908319.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和伤害参数，分别赋给局部变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对玩家p造成d点伤害，完成“给与1000分伤害”的实际处理。
	Duel.Damage(p,d,REASON_EFFECT)
end
