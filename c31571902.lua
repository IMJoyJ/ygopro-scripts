--邪神機－獄炎
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡送去墓地。那之后，自己受到这张卡的原本攻击力数值的伤害。这个效果在场上没有这张卡以外的不死族怪兽存在的场合进行发动和处理。
function c31571902.initial_effect(c)
	-- ①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31571902,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c31571902.ntcon)
	e1:SetOperation(c31571902.ntop)
	c:RegisterEffect(e1)
end
-- 定义“不用解放作召唤”的召唤手续条件：当c为nil（规则询问是否可用此方式召唤）时返回true，否则要求解放数量为0、怪兽等级5以上且自己主怪兽区有空位。
function c31571902.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否满足无解放召唤条件：不解放（minc==0）、等级≥5、自己场上有可用主怪兽区空格。
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- ①效果的无解放召唤成功时，为这张卡注册②的诱发效果（结束阶段送墓+伤害），包括设置效果类型为场地诱发必发、发动时机为结束阶段、条件为场上没有其他表侧不死族怪兽，并设置送墓与伤害的操作信息，效果在离场等条件下重置。
function c31571902.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡送去墓地。那之后，自己受到这张卡的原本攻击力数值的伤害。这个效果在场上没有这张卡以外的不死族怪兽存在的场合进行发动和处理。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31571902,1))  --"送墓"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCondition(c31571902.tgcon)
	e1:SetTarget(c31571902.tgtg)
	e1:SetOperation(c31571902.tgop)
	e1:SetReset(RESET_EVENT+0xc6e0000)
	c:RegisterEffect(e1)
end
-- 定义过滤条件：表侧表示且种族为不死族的怪兽。
function c31571902.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 定义②效果的发动条件：场上不存在这张卡以外的表侧不死族怪兽（即这张卡是场上唯一的不死族怪兽）。
function c31571902.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足filter条件的其他不死族怪兽，不存在时返回true。
	return not Duel.IsExistingMatchingCard(c31571902.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- ②效果的发动时点处理：效果发动时确定要执行的操作，即把这张卡送去墓地，并给与自己原本攻击力数值的伤害，写入连锁的操作信息。
function c31571902.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含把这张卡送去墓地的效果，对象确定为这张卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次处理包含伤害效果，伤害对象为这张卡的控制者，伤害数值为这张卡的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,e:GetHandler():GetBaseAttack())
end
-- ②效果处理时：若这张卡仍与效果相关且表侧表示，则将其送去墓地；送墓成功后，中断连锁处理流程（使送墓与伤害不同时处理），然后给与这张卡的控制者2400点伤害（原攻击力数值）。
function c31571902.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定这张卡是否仍与效果关联、是否表侧表示，并且成功被效果送去墓地；满足这些条件才继续处理伤害。
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
		-- 中断当前效果处理，使送墓与后续伤害处理不在同一时点，避免时点被错过，保证伤害在送墓后另行处理。
		Duel.BreakEffect()
		-- 给与效果发动者（这张卡的控制者）2400点效果伤害（即原本攻击力数值）。
		Duel.Damage(tp,2400,REASON_EFFECT)
	end
end
