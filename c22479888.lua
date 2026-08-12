--クレイ・チャージ
-- 效果：
-- 自己场上的「元素英雄 黏土侠」被选择为攻击对象时才能发动（若选择的卡是里侧守备表示的场合，那张卡需要确认）。攻击怪兽和选择的「元素英雄 黏土侠」破坏，给与对方基本分800分的伤害。
function c22479888.initial_effect(c)
	-- 为卡片添加元素英雄系列编码，用于后续效果判断
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
-- 效果发动条件：攻击对象是自己的「元素英雄 黏土侠」
function c22479888.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击对象
	local at=Duel.GetAttackTarget()
	return at:IsControler(tp) and at:IsCode(84327329)
end
-- 效果处理目标阶段：判断攻击怪兽和攻击对象是否在场且可成为效果对象
function c22479888.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取当前攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前攻击对象
	local at=Duel.GetAttackTarget()
	if chkc then return false end
	if chk==0 then return a:IsOnField() and a:IsCanBeEffectTarget(e)
		and at:IsOnField() and at:IsCanBeEffectTarget(e) end
	if at:IsFacedown() then
		-- 若攻击对象为里侧表示，则确认其卡面
		Duel.ConfirmCards(1-tp,at)
	end
	local g=Group.FromCards(a,at)
	-- 设置连锁处理的目标卡片组
	Duel.SetTargetCard(g)
	-- 设置连锁操作信息：破坏2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置连锁操作信息：对对方造成800点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 效果发动时的处理函数：破坏目标怪兽并造成伤害
function c22479888.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被指定的目标卡片组，并筛选出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()==2 then
		-- 将目标卡片组中的卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
		-- 对对方玩家造成800点伤害
		Duel.Damage(1-tp,800,REASON_EFFECT)
	end
end
