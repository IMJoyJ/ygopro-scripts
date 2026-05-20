--氷水呪縛
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要场上有「冰水」怪兽以及「冰水底 铬离子少女摇篮」存在，对方不能把这个回合召唤·反转召唤·特殊召唤的场上的怪兽的效果发动。
-- ②：自己的「冰水」怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c83670388.initial_effect(c)
	-- 将「冰水底 铬离子少女摇篮」的卡片密码加入此卡的关联卡片列表中
	aux.AddCodeList(c,7142724)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要场上有「冰水」怪兽以及「冰水底 铬离子少女摇篮」存在，对方不能把这个回合召唤·反转召唤·特殊召唤的场上的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c83670388.actcon)
	e2:SetValue(c83670388.aclimit)
	c:RegisterEffect(e2)
	-- ②：自己的「冰水」怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,83670388)
	e3:SetCondition(c83670388.damcon)
	e3:SetTarget(c83670388.damtg)
	e3:SetOperation(c83670388.damop)
	c:RegisterEffect(e3)
end
-- 过滤场上表侧表示的「冰水」怪兽
function c83670388.actfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- 效果①的生效条件：场上有「冰水」怪兽以及「冰水底 铬离子少女摇篮」存在
function c83670388.actcon(e)
	-- 检查场上是否存在表侧表示的「冰水」怪兽
	return Duel.IsExistingMatchingCard(c83670388.actfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查场上（或作为场地魔法）是否存在「冰水底 铬离子少女摇篮」
		and Duel.IsEnvironment(7142724)
end
-- 限制对方不能发动在本回合召唤·反转召唤·特殊召唤的场上怪兽的效果
function c83670388.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE)
		and rc:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 效果②的发动条件：自己的「冰水」怪兽的战斗让怪兽被破坏
function c83670388.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己进行战斗的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsSetCard(0x16c)
end
-- 过滤被战斗破坏并送去墓地或除外的、原本攻击力大于0且可以作为效果对象的怪兽
function c83670388.damfilter(c,e)
	return c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的靶向与发动准备：确认是否有符合条件的被破坏怪兽，并将其设为效果对象，声明给与伤害的操作信息
function c83670388.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c83670388.filter(chkc,e,tp) end
	if chk==0 then return eg:IsExists(c83670388.damfilter,1,nil,e) end
	local g=eg
	if #eg>1 then
		-- 提示玩家选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		e=eg:FilterSelect(tp,c83670388.damfilter,1,1,nil,e)
	end
	-- 将选中的被破坏怪兽设为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，声明将给与对方该怪兽原本攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 效果②的效果处理：给与对方作为对象的怪兽原本攻击力数值的伤害
function c83670388.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的被破坏怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 给与对方该怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
