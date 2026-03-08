--グレイヴ・オージャ
-- 效果：
-- 只要自己场上存在里侧守备表示的怪兽，这张卡不能被选择为攻击对象。每次自己场上的怪兽反转召唤，给与对方300分伤害。
function c40937767.initial_effect(c)
	-- 效果原文内容：只要自己场上存在里侧守备表示的怪兽，这张卡不能被选择为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c40937767.ccon)
	-- 规则层面操作：设置效果值为aux.imval1函数，用于判断是否免疫攻击对象效果
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 效果原文内容：每次自己场上的怪兽反转召唤，给与对方300分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40937767,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetCondition(c40937767.damcon)
	e2:SetTarget(c40937767.damtg)
	e2:SetOperation(c40937767.damop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断场上是否存在里侧守备表示的怪兽
function c40937767.ccon(e)
	-- 规则层面操作：检查以效果持有者为玩家，在自己场上是否存在至少1张里侧守备表示的怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 规则层面操作：判断反转召唤的玩家是否为效果持有者且召唤的怪兽不是自己
function c40937767.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst()~=e:GetHandler()
end
-- 规则层面操作：设置连锁处理时的目标玩家为对方玩家，目标参数为300，操作信息设置为伤害效果
function c40937767.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置连锁处理时的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 规则层面操作：设置连锁处理时的目标参数为300
	Duel.SetTargetParam(300)
	-- 规则层面操作：设置连锁操作信息为伤害效果，目标玩家为对方，伤害值为300
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 规则层面操作：执行伤害效果，对目标玩家造成指定伤害
function c40937767.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁处理的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面操作：以效果为原因，对指定玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
