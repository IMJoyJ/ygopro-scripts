--エクスプロード・ウィング・ドラゴン
-- 效果：
-- 调整＋调整以外的龙族怪兽1只以上
-- 和持有这张卡的攻击力以下的攻击力的场上表侧表示存在的怪兽进行战斗的场合，可以不进行伤害计算把那只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
function c40529384.initial_effect(c)
	-- 为爆翼龙添加同调召唤手续：需要1只调整 + 1只以上调整以外的龙族怪兽作为同调素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_DRAGON),1)
	c:EnableReviveLimit()
	-- 和持有这张卡的攻击力以下的攻击力的场上表侧表示存在的怪兽进行战斗的场合，可以不进行伤害计算把那只怪兽破坏，给与对方基本分破坏怪兽的攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40529384,0))  --"破坏并伤害"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetTarget(c40529384.destg)
	e1:SetOperation(c40529384.desop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标判定与操作信息登记：确认战斗对象存在、表侧表示且攻击力不高于本卡，并登记破坏和伤害的对象及数值。
function c40529384.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前进行战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽就是本卡，则将战斗对象改为攻击目标（即与本卡战斗的对方怪兽）。
	if tc==c then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsFaceup() and tc:GetAttack()<=c:GetAttack() end
	-- 登记操作信息：将战斗对象确定为将被破坏的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 登记操作信息：将给予对方的伤害登记为战斗对象当前的攻击力数值。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetAttack())
end
-- 效果处理阶段：若战斗对象仍与本次战斗相关且攻击力不高于本卡，则将其破坏，并在破坏成功后给予对方该怪兽攻击力数值的伤害。
function c40529384.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在处理阶段再次获取当前进行战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是本卡，则将战斗对象改为攻击目标，以便处理破坏和伤害。
	if tc==c then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and tc:GetAttack()<=c:GetAttack() then
		local atk=tc:GetAttack()
		-- 若该战斗对象被效果成功破坏，则继续执行后续伤害处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 给予对方基本分该怪兽攻击力数值的伤害，伤害来源为本效果。
			Duel.Damage(1-tp,atk,REASON_EFFECT)
		end
	end
end
