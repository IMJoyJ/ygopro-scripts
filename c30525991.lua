--スパルタクァの呪術師
-- 效果：
-- 这张卡在场上表侧表示存在的场合，每次怪兽从卡组特殊召唤，给与对方基本分500分伤害。
function c30525991.initial_effect(c)
	-- 这张卡在场上表侧表示存在的场合，每次怪兽从卡组特殊召唤，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30525991,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c30525991.con)
	e1:SetTarget(c30525991.tg)
	e1:SetOperation(c30525991.op)
	c:RegisterEffect(e1)
end
-- 判断被特殊召唤的怪兽在特殊召唤前是否位于卡组，用于筛选“从卡组特殊召唤的怪兽”。
function c30525991.cfilter(c)
	return c:IsPreviousLocation(LOCATION_DECK)
end
-- 发动条件：本次特殊召唤的怪兽集合中不包含这张卡自身，且存在至少1只是从卡组特殊召唤的怪兽。
function c30525991.con(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c30525991.cfilter,1,nil)
end
-- 效果发动时的目标处理：确认此卡仍与效果关联；将对象玩家设为对方、伤害数值设为500，并登记本次将造成伤害的操作信息。
function c30525991.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 将当前连锁效果的对象玩家设置为对方玩家（1-tp），即伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁效果的对象参数设置为500，表示造成的伤害数值。
	Duel.SetTargetParam(500)
	-- 登记本次效果处理将造成伤害（CATEGORY_DAMAGE），对象为对方玩家，伤害值为500，供效果发动时点及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理时的操作：若效果发动者已与效果失去联系（例如离场）或处于里侧表示则不处理；否则取出先前设定的对象玩家和伤害数值，对对方造成伤害。
function c30525991.op(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 从当前连锁信息中获取预先设置的对象玩家和参数值（伤害数值），分别赋给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式，给对象玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
