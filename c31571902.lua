--邪神機－獄炎
-- 效果：
-- ①：这张卡可以不用解放作召唤。
-- ②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡送去墓地。那之后，自己受到这张卡的原本攻击力数值的伤害。这个效果在场上没有这张卡以外的不死族怪兽存在的场合进行发动和处理。
function c31571902.initial_effect(c)
	-- 效果原文内容：①：这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31571902,0))  --"不用解放作召唤"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c31571902.ntcon)
	e1:SetOperation(c31571902.ntop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否满足不需解放召唤的条件
function c31571902.ntcon(e,c,minc)
	if c==nil then return true end
	-- 规则层面操作：召唤时不需要解放，等级不低于5，且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 效果原文内容：②：这张卡的①的方法召唤的场合，结束阶段发动。这张卡送去墓地。那之后，自己受到这张卡的原本攻击力数值的伤害。这个效果在场上没有这张卡以外的不死族怪兽存在的场合进行发动和处理。
function c31571902.ntop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 规则层面操作：注册结束阶段触发效果，用于处理送去墓地和造成伤害
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
-- 规则层面操作：过滤场上存在的不死族怪兽
function c31571902.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end
-- 规则层面操作：判断场上是否没有其他不死族怪兽
function c31571902.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：若场上不存在其他不死族怪兽则发动效果
	return not Duel.IsExistingMatchingCard(c31571902.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler())
end
-- 规则层面操作：设置效果处理时的目标和伤害信息
function c31571902.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面操作：设置将自身送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 规则层面操作：设置对自己造成自身原本攻击力数值伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,e:GetHandler():GetBaseAttack())
end
-- 规则层面操作：执行将自身送去墓地并造成伤害的效果
function c31571902.tgop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：确认自身存在于场上且能被送去墓地
	if c:IsRelateToEffect(e) and c:IsFaceup() and Duel.SendtoGrave(c,REASON_EFFECT)~=0 then
		-- 规则层面操作：中断当前连锁处理，避免时点错乱
		Duel.BreakEffect()
		-- 规则层面操作：对自身控制者造成2400点伤害
		Duel.Damage(tp,2400,REASON_EFFECT)
	end
end
