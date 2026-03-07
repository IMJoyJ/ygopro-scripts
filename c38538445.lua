--不死之炎鳥
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转回合的结束阶段时回到主人的手卡。这张卡给与对方玩家战斗伤害的场合，自己的基本分回复那个战斗伤害的数值。
function c38538445.initial_effect(c)
	-- 为卡片添加在召唤或反转召唤回合结束阶段回到手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该效果为无法特殊召唤的条件
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 这张卡给与对方玩家战斗伤害的场合，自己的基本分回复那个战斗伤害的数值
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(38538445,1))  --"回复"
	e4:SetCategory(CATEGORY_RECOVER)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c38538445.condition)
	e4:SetTarget(c38538445.target)
	e4:SetOperation(c38538445.operation)
	c:RegisterEffect(e4)
end
-- 判断造成战斗伤害的玩家是否为对方
function c38538445.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 设置连锁处理时的目标玩家和参数，并注册回复效果的操作信息
function c38538445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为造成的战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置连锁操作信息为回复效果，目标玩家为当前玩家，回复值为伤害值
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 执行回复效果，从连锁信息中获取目标玩家和伤害值并进行回复
function c38538445.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复指定数值的生命值，原因来自效果
	Duel.Recover(p,d,REASON_EFFECT)
end
