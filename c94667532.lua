--機械犬マロン
-- 效果：
-- 场上的这张卡被战斗破坏送去墓地时，给与双方基本分1000分的伤害。场上的这张卡因为战斗以外的方式的破坏送去墓地时，给与对方基本分1000分的伤害。
function c94667532.initial_effect(c)
	-- 场上的这张卡被战斗破坏送去墓地时，给与双方基本分1000分的伤害。场上的这张卡因为战斗以外的方式的破坏送去墓地时，给与对方基本分1000分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94667532,0))  --"双方伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c94667532.damcon)
	e1:SetTarget(c94667532.damtg)
	e1:SetOperation(c94667532.damop)
	c:RegisterEffect(e1)
end
-- 确认发动条件：此卡原本在场上，且因破坏送去墓地
function c94667532.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 确认效果目标：若非战斗破坏则目标为对方，否则为双方，并设定伤害数值为1000
function c94667532.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local p=PLAYER_ALL
	if not e:GetHandler():IsReason(REASON_BATTLE) then
		p=1-tp
	end
	-- 设置当前连锁的对象玩家
	Duel.SetTargetPlayer(p)
	-- 设置当前连锁的对象参数（伤害数值）
	Duel.SetTargetParam(1000)
	-- 设置操作信息：给与目标玩家1000分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,p,1000)
end
-- 执行效果：根据目标玩家，给与双方或对方1000分伤害
function c94667532.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if p==PLAYER_ALL then
		-- 给与回合玩家（自己）伤害（分步处理）
		Duel.Damage(0,d,REASON_EFFECT,true)
		-- 给与非回合玩家（对方）伤害（分步处理）
		Duel.Damage(1,d,REASON_EFFECT,true)
		-- 完成分步伤害处理，触发相关时点
		Duel.RDComplete()
	else
		-- 给与目标玩家伤害
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
