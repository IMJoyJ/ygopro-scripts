--星遺物の齎す崩界
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以场上1只连接怪兽为对象才能发动。那只怪兽的攻击力上升除外的怪兽的原本攻击力数值。
-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗或者对方的效果破坏的场合，把这张卡除外才能发动。从自己墓地选1只电子界族连接怪兽特殊召唤。
function c36197902.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：从自己的手卡·墓地以及自己场上的表侧表示怪兽之中把1只「星遗物」怪兽除外，以场上1只连接怪兽为对象才能发动。那只怪兽的攻击力上升除外的怪兽的原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetLabel(0)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	e2:SetCountLimit(1,36197902)
	-- 设置效果e2的发动条件为“非伤害步骤或伤害计算前”，即限制该效果不能在伤害计算后发动。
	e2:SetCondition(aux.dscon)
	e2:SetCost(c36197902.atkcost)
	e2:SetTarget(c36197902.atktg)
	e2:SetOperation(c36197902.atkop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的状态，自己场上的连接怪兽被战斗或者对方的效果破坏的场合，把这张卡除外才能发动。从自己墓地选1只电子界族连接怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36197902,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,36197903)
	-- 设置e3的发动代价为“把墓地的这张卡除外”的辅助代价函数。
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c36197902.spcon)
	e3:SetTarget(c36197902.sptg)
	e3:SetOperation(c36197902.spop)
	c:RegisterEffect(e3)
end
-- ①效果的代价函数：在代价判定阶段仅设置标记为1并返回true，真正的除外操作在目标选择阶段执行，以此记录被除外的星遗物怪兽。
function c36197902.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 定义①代价的怪兽过滤条件：从手卡·墓地以及自己场上表侧表示怪兽中选出1只「星遗物」怪兽，要求是怪兽、字段为星遗物、原本攻击力>0、能作为除外代价，且场上存在可成为对象的表侧连接怪兽。
function c36197902.cfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfe) and c:GetBaseAttack()>0
		and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		-- 同时确认场上存在1只表侧表示、可作为效果对象的连接怪兽（用于保证取对象可行）。
		and Duel.IsExistingMatchingCard(c36197902.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,e)
end
-- 筛选①效果的对象：场上表侧表示且能被效果取对象的连接怪兽。
function c36197902.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsCanBeEffectTarget(e)
end
-- ①效果的发动时点判定与目标选择：在合法时从手卡·墓地及自己场上表侧表示怪兽中选1只星遗物怪兽除外，再选场上1只表侧表示连接怪兽作为对象；同时记录被除外的怪兽供处理时使用。
function c36197902.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查是否存在可作为代价除外的「星遗物」怪兽（并满足后续对象存在条件）。
		return Duel.IsExistingMatchingCard(c36197902.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,e)
	end
	e:SetLabel(0)
	-- 向操作玩家显示“请选择要除外的卡”的提示，用于选择代价怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从手卡·墓地以及自己场上表侧表示怪兽中选择1只符合条件的「星遗物」怪兽作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c36197902.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,e)
	-- 将选中的「星遗物」怪兽以表侧表示除外，作为①效果的发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	-- 向操作玩家显示“请选择表侧表示的卡”的提示，用于选择取对象的目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示连接怪兽作为①效果的对象，并登记为连锁对象。
	Duel.SelectTarget(tp,c36197902.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
end
-- ①效果处理：取得对象连接怪兽和被除外的星遗物怪兽；若相关卡仍合法，则为对象连接怪兽赋予上升其原本攻击力数值的攻击力变化效果。
function c36197902.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的连接怪兽对象（唯一对象）。
	local tc=Duel.GetFirstTarget()
	local sc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and sc then
		local atk=math.max(sc:GetBaseAttack(),0)
		-- 那只怪兽的攻击力上升除外的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义②效果的触发条件过滤：被破坏的怪兽必须是自己场上表侧表示的连接怪兽，且破坏原因是战斗或对方玩家的效果。
function c36197902.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ②效果的发动条件：当自己场上的连接怪兽被战斗或对方的效果破坏时满足。
function c36197902.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36197902.cfilter2,1,nil,tp)
end
-- 筛选②效果可特殊召唤的对象：自己墓地中电子界族的连接怪兽，且满足当前特殊召唤限制。
function c36197902.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的目标检查：确认我方主要怪兽区有空位，且墓地存在1只可特殊召唤的电子界族连接怪兽。
function c36197902.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认我方主要怪兽区域还有可用空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地存在至少1只满足条件的电子界族连接怪兽可供特殊召唤。
		and Duel.IsExistingMatchingCard(c36197902.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息为“特殊召唤”，预期从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：若仍有空位，从自己墓地选择1只电子界族连接怪兽以表侧表示特殊召唤。
function c36197902.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区有空位，没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的电子界族连接怪兽。
	local g=Duel.SelectMatchingCard(tp,c36197902.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的电子界族连接怪兽表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
