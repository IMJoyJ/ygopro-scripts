--オキシゲドン
-- 效果：
-- ①：这张卡被和炎族怪兽的战斗破坏送去墓地的场合发动。双方受到800伤害。
function c58071123.initial_effect(c)
	-- ①：这张卡被和炎族怪兽的战斗破坏送去墓地的场合发动。双方受到800伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58071123,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c58071123.damcon)
	e1:SetTarget(c58071123.damtg)
	e1:SetOperation(c58071123.damop)
	c:RegisterEffect(e1)
end
-- 确认这张卡在墓地，且战斗对象怪兽是炎族怪兽
function c58071123.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():GetBattleTarget():IsRace(RACE_PYRO)
end
-- 效果发动的目标确认，设置双方受到800点伤害的操作信息
function c58071123.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：双方玩家受到800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,PLAYER_ALL,800)
end
-- 效果处理：使双方玩家各受到800点伤害
function c58071123.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 给与自己（回合玩家）800点效果伤害（分步处理）
	Duel.Damage(tp,800,REASON_EFFECT,true)
	-- 给与对方玩家800点效果伤害（分步处理）
	Duel.Damage(1-tp,800,REASON_EFFECT,true)
	-- 完成分步伤害处理，触发伤害时点
	Duel.RDComplete()
end
