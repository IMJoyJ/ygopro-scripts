--ナチュラル・ディザスター
-- 效果：
-- 每次名字带有「云魔物」的怪兽的效果把对方控制的卡破坏送去墓地，给与对方基本分500分伤害。
function c18158397.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，对应一速的【……发动】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18158397,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c18158397.condition)
	e2:SetTarget(c18158397.target)
	e2:SetOperation(c18158397.operation)
	c:RegisterEffect(e2)
end
-- 检查目标怪兽是否在发动时控制者与破坏时控制者相同
function c18158397.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp)
end
-- 效果发动条件：被破坏的卡为对方控制的卡，且破坏效果来自名字带有「云魔物」的怪兽，且破坏对象中存在对方控制的卡，且此卡处于激活状态
function c18158397.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and re and re:GetHandler():IsSetCard(0x18)
		and eg:IsExists(c18158397.cfilter,1,nil,1-tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果处理准备：确认此卡存在于场上，设置伤害对象为对方玩家，设置伤害值为500，设置连锁操作信息为伤害效果
function c18158397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 设置连锁操作的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作的目标参数为500
	Duel.SetTargetParam(500)
	-- 设置当前处理的连锁的操作信息为伤害效果，目标玩家为对方，伤害值为500
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理：从连锁信息中获取目标玩家和伤害值，对目标玩家造成对应伤害
function c18158397.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因，对目标玩家造成对应伤害值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
