--グレイヴ・オージャ
-- 效果：
-- 只要自己场上存在里侧守备表示的怪兽，这张卡不能被选择为攻击对象。每次自己场上的怪兽反转召唤，给与对方300分伤害。
function c40937767.initial_effect(c)
	-- 只要自己场上存在里侧守备表示的怪兽，这张卡不能被选择为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e1:SetCondition(c40937767.ccon)
	-- 设置效果的Value为aux.imval1，使效果以“不免疫此效果的怪兽不能被选择为攻击对象”的方式生效，即这张卡在满足条件时不能被选为攻击对象。
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- 每次自己场上的怪兽反转召唤，给与对方300分伤害。
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
-- 定义条件函数ccon，用于判断效果持有者自己场上是否存在里侧守备表示怪兽，以决定“不能被选择为攻击对象”的效果是否适用。
function c40937767.ccon(e)
	-- 检查以效果持有者（e:GetHandlerPlayer()）为视角的自己主要怪兽区域（LOCATION_MZONE）中是否存在至少1张里侧守备表示（POS_FACEDOWN_DEFENSE）的怪兽。
	return Duel.IsExistingMatchingCard(Card.IsPosition,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 定义伤害效果的触发条件：反转召唤成功的怪兽属于自己（ep==tp），且触发反转召唤的怪兽不是这张卡自身。
function c40937767.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and eg:GetFirst()~=e:GetHandler()
end
-- 定义伤害效果的发动目标设定函数：在效果发动时（chk==0）直接通过，并记录对方玩家为承受伤害的对象，伤害值为300，同时登记操作信息为将造成300点效果伤害。
function c40937767.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的效果对象玩家设置为对方玩家（1-tp），即确定受到伤害的玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的效果对象参数设置为300，即确定伤害数值为300。
	Duel.SetTargetParam(300)
	-- 登记操作信息：本次连锁的效果分类为伤害（CATEGORY_DAMAGE），目标玩家为对方（1-tp），伤害数值为300（不取对象，targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 定义伤害效果的处理函数：效果结算时从连锁信息中取得之前记录的目标玩家和伤害值，并执行实际伤害。
function c40937767.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家（CHAININFO_TARGET_PLAYER）和目标参数（CHAININFO_TARGET_PARAM），保存到局部变量p和d中。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对玩家p造成d点效果伤害（REASON_EFFECT表示伤害来源为卡的效果），即给予对方300分伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
