--守護天使 ジャンヌ
-- 效果：
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
function c68007326.initial_effect(c)
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。自己基本分回复那只怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68007326,0))  --"LP回复"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCondition(c68007326.reccon)
	e1:SetTarget(c68007326.rectg)
	e1:SetOperation(c68007326.recop)
	c:RegisterEffect(e1)
end
-- 确认发动条件：自身仍与本次战斗关联，且被战斗破坏的怪兽已送去墓地
function c68007326.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc:IsLocation(LOCATION_GRAVE)
end
-- 效果发动的目标选择与信息注册：获取被破坏怪兽的原本攻击力，并设定回复基本分的对象玩家与数值
function c68007326.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	local rec=bc:GetBaseAttack()
	if rec<0 then rec=0 end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为被破坏怪兽的原本攻击力数值
	Duel.SetTargetParam(rec)
	-- 设置当前连锁的操作信息为：使自己回复对应数值的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理：获取设定的对象玩家和回复数值，执行回复基本分的操作
function c68007326.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分数值
	Duel.Recover(p,d,REASON_EFFECT)
end
