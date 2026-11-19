--氷水呪縛
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要场上有「冰水」怪兽以及「冰水底 铬离子少女摇篮」存在，对方不能把这个回合召唤·反转召唤·特殊召唤的场上的怪兽的效果发动。
-- ②：自己的「冰水」怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c83670388.initial_effect(c)
	-- 登记卡片文本中记述的关联卡名「冰水底 铬离子少女摇篮」
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
	-- 这个卡名的②的效果1回合只能使用1次。②：自己的「冰水」怪兽的战斗让怪兽被破坏时，以那1只破坏的怪兽为对象才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
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
-- 过滤场上的「冰水」怪兽：须为表侧表示且属于「冰水」字段
function c83670388.actfilter(c)
	return c:IsSetCard(0x16c) and c:IsFaceup()
end
-- 检查①效果的适用条件：双方怪兽区存在表侧表示的「冰水」怪兽，且场上当前场地环境为「冰水底 铬离子少女摇篮」
function c83670388.actcon(e)
	-- 检查双方场上是否存在至少1只表侧表示的「冰水」怪兽
	return Duel.IsExistingMatchingCard(c83670388.actfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查当前场地环境是否为「冰水底 铬离子少女摇篮」
		and Duel.IsEnvironment(7142724)
end
-- 效果发动限制过滤函数：禁止对方发动位于怪兽区且在本回合内召唤·反转召唤·特殊召唤出场的怪兽的效果
function c83670388.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsLocation(LOCATION_MZONE)
		and rc:IsStatus(STATUS_SUMMON_TURN+STATUS_FLIP_SUMMON_TURN+STATUS_SPSUMMON_TURN)
end
-- 检查②效果的发动条件：确认自己方参与这次战斗的怪兽属于「冰水」字段
function c83670388.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗中由自己控制的进行战斗的怪兽
	local a=Duel.GetBattleMonster(tp)
	return a and a:IsSetCard(0x16c)
end
-- 过滤被战斗破坏的怪兽：原本攻击力大于0、可以成为效果对象且当前位于墓地或除外区
function c83670388.damfilter(c,e)
	return c:GetBaseAttack()>0 and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ②效果的发动检查与取对象处理：确认被战斗破坏的怪兽中有符合条件者，若同时破坏多只则让玩家选1只作为对象，并登记给与对方其原本攻击力数值伤害的操作信息
function c83670388.damtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c83670388.damfilter(chkc,e) end
	if chk==0 then return eg:IsExists(c83670388.damfilter,1,nil,e) end
	local g=eg
	if #eg>1 then
		-- 向发动玩家发送选择效果对象的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=eg:FilterSelect(tp,c83670388.damfilter,1,1,nil,e)
	end
	-- 将选出的被战斗破坏怪兽设定为当前连锁的对象
	Duel.SetTargetCard(g)
	-- 登记本次连锁包含给与对方玩家等于对象怪兽原本攻击力数值效果伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetBaseAttack())
end
-- 执行②效果处理：确认对象怪兽仍与效果关联后，给与对方玩家等于其原本攻击力数值的效果伤害
function c83670388.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选中的被战斗破坏的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果给与对方玩家等于对象怪兽原本攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetBaseAttack(),REASON_EFFECT)
	end
end
