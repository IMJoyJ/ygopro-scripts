--ナチュラル・ディザスター
-- 效果：
-- 每次名字带有「云魔物」的怪兽的效果把对方控制的卡破坏送去墓地，给与对方基本分500分伤害。
function c18158397.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次名字带有「云魔物」的怪兽的效果把对方控制的卡破坏送去墓地，给与对方基本分500分伤害。
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
-- 筛选进入墓地的卡是否满足“由玩家tp控制”的条件：同时检查卡的当前控制者和上一个控制者都是tp，即该卡在被破坏前确实由tp控制且未被变更过控制权。
function c18158397.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp)
end
-- 触发条件判定：存在由「云魔物」字段怪兽发动的效果，该效果将对方控制的卡破坏并送入墓地（r包含0x41相关破坏标志），且送墓的卡中至少有一张满足对方控制条件，同时本卡效果处于有效状态。
function c18158397.condition(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,0x41)==0x41 and re and re:GetHandler():IsSetCard(0x18)
		and eg:IsExists(c18158397.cfilter,1,nil,1-tp) and e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED)
end
-- 效果发动时的合法性检查与数据设定：chk==0时确认本卡仍与效果关联；随后将对象玩家设为对方、伤害值设为500，并登记伤害相关的连锁信息。
function c18158397.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 将当前连锁的效果对象玩家设置为对方（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果参数设置为500，表示要造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 向连锁登记操作信息：本次处理属于伤害效果（CATEGORY_DAMAGE），伤害对象玩家为对方，伤害数值为500；由于不取对象，目标卡组设为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理函数：从连锁信息中取得之前设置的对象玩家和参数，并对该玩家执行效果伤害。
function c18158397.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中同时获取对象玩家（CHAININFO_TARGET_PLAYER）和对象参数（CHAININFO_TARGET_PARAM），分别存入变量p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害（REASON_EFFECT）的形式，向玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
