--クレイ・チャージ
-- 效果：
-- 自己场上的「元素英雄 黏土侠」被选择为攻击对象时才能发动（若选择的卡是里侧守备表示的场合，那张卡需要确认）。攻击怪兽和选择的「元素英雄 黏土侠」破坏，给与对方基本分800分的伤害。
function c22479888.initial_effect(c)
	-- 向这张卡登记「元素英雄」系列字段（0x3008），使卡名相关判定（如「元素英雄 黏土侠」）在效果处理时能够正确匹配。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 自己场上的「元素英雄 黏土侠」被选择为攻击对象时才能发动（若选择的卡是里侧守备表示的场合，那张卡需要确认）。攻击怪兽和选择的「元素英雄 黏土侠」破坏，给与对方基本分800分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c22479888.condition)
	e1:SetTarget(c22479888.target)
	e1:SetOperation(c22479888.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：被选择为攻击对象的怪兽必须是自己场上、卡名为「元素英雄 黏土侠」的怪兽。
function c22479888.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被选为攻击对象的怪兽（即攻击目标）。
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsCode(84327329)
end
-- 发动时的目标选择与合法性判定：确认攻击怪兽和攻击目标（黏土侠）都在场上且都能成为效果对象，并设置后续破坏与伤害的操作信息。
function c22479888.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前发动攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取当前被选为攻击对象的怪兽（即攻击目标）。
	local at=Duel.GetAttackTarget()
	if chkc then return false end
	if chk==0 then return a:IsOnField() and a:IsCanBeEffectTarget(e)
		and at:IsOnField() and at:IsCanBeEffectTarget(e) end
	if at:IsFacedown() then
		-- 若攻击目标是里侧守备表示，则将该卡向对方玩家展示确认。
		Duel.ConfirmCards(1-tp,at)
	end
	local g=Group.FromCards(a,at)
	-- 将攻击怪兽和攻击目标（黏土侠）设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：这次效果将破坏2张卡（攻击怪兽和黏土侠），用于连锁处理时的破坏效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置操作信息：这次效果将对对方造成800点伤害，用于连锁处理时的伤害效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果处理：取回连锁对象中仍与效果关联的卡，若正好有2张（攻击怪兽和黏土侠），则将它们破坏并给予对方800点伤害。
function c22479888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡组，并过滤出仍然与本次效果存在关联的卡（防止对象已离场或失去关系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将过滤后仍关联的2张卡（攻击怪兽和黏土侠）以效果原因破坏。
		Duel.Destroy(g,REASON_EFFECT)
		-- 以效果原因给予对方玩家800点伤害。
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
