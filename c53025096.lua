--オッドアイズ・ドラゴン
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
function c53025096.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地的场合发动。给与对方那只怪兽的原本攻击力一半数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53025096,0))  --"基本分伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c53025096.damcon)
	e1:SetTarget(c53025096.damtg)
	e1:SetOperation(c53025096.damop)
	c:RegisterEffect(e1)
end
-- 发动条件判断：确认这张卡仍与本次战斗关联，且其战斗对象（被战斗破坏的怪兽）位于墓地且是怪兽，即满足“战斗破坏对方怪兽送去墓地”的触发条件。
function c53025096.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE) and bc:IsType(TYPE_MONSTER)
end
-- 发动时的目标设定：无发动限制；取得被战斗破坏的怪兽，计算其原本攻击力的一半作为伤害值，将该怪兽设为连锁对象，将对象玩家设为对方，并登记本次操作为伤害效果。
function c53025096.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetBattleTarget()
	local dam=math.floor(bc:GetBaseAttack()/2)
	-- 将被战斗破坏的那只对方怪兽设置为当前连锁的对象卡，便于后续处理时确认和关联。
	Duel.SetTargetCard(bc)
	-- 将当前连锁的对象玩家设为对方玩家（1-tp），表示伤害的承受者是对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为计算出的伤害值（原本攻击力的一半），保存该数值供效果处理时使用。
	Duel.SetTargetParam(dam)
	-- 登记本次效果处理的操作信息：类别为伤害效果，预计对对方玩家造成 dam 点效果伤害（targets 为 nil 表示伤害不以卡为对象）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果处理时的实际操作：取得连锁中登记的对象卡，若该卡仍与效果关联，则从连锁信息中获取对象玩家和伤害值（重新基于原本攻击力计算），给对方造成效果伤害。
function c53025096.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡，即之前登记的被战斗破坏的那只对方怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 从当前连锁信息中取得对象玩家（之前设定为对方玩家），作为伤害的承受者。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.floor(tc:GetBaseAttack()/2)
		-- 以效果伤害方式给予玩家 p 造成 dam 点伤害，dam 为被战斗破坏怪兽的原本攻击力的一半。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
