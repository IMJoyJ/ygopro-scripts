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
	-- 限制效果只能在伤害计算前的时机发动或适用
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
	-- 把这张卡除外作为发动cost
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c36197902.spcon)
	e3:SetTarget(c36197902.sptg)
	e3:SetOperation(c36197902.spop)
	c:RegisterEffect(e3)
end
-- 设置效果发动标记，用于判断是否满足发动条件
function c36197902.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
-- 过滤满足条件的「星遗物」怪兽，包括手牌、墓地和场上的表侧表示怪兽
function c36197902.cfilter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xfe) and c:GetBaseAttack()>0
		and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or not c:IsLocation(LOCATION_MZONE))
		-- 确保场上存在至少一只连接怪兽作为目标
		and Duel.IsExistingMatchingCard(c36197902.filter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,e)
end
-- 过滤场上表侧表示的连接怪兽
function c36197902.filter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsCanBeEffectTarget(e)
end
-- 检查是否满足发动条件并选择除外的「星遗物」怪兽和目标连接怪兽
function c36197902.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		-- 检查是否存在满足条件的「星遗物」怪兽用于除外
		return Duel.IsExistingMatchingCard(c36197902.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,e)
	end
	e:SetLabel(0)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的「星遗物」怪兽进行除外
	local g=Duel.SelectMatchingCard(tp,c36197902.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil,e)
	-- 将选中的怪兽除外作为发动cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择表侧表示的连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择目标连接怪兽
	Duel.SelectTarget(tp,c36197902.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e)
end
-- 将除外怪兽的攻击力加到目标连接怪兽上
function c36197902.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local sc=e:GetLabelObject()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and sc then
		local atk=math.max(sc:GetBaseAttack(),0)
		-- 将除外怪兽的攻击力数值加到目标怪兽上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 判断被破坏的怪兽是否为己方场上的连接怪兽且因战斗或对方效果被破坏
function c36197902.cfilter2(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and bit.band(c:GetPreviousTypeOnField(),TYPE_LINK)~=0
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- 判断是否满足发动条件，即己方场上的连接怪兽被破坏
function c36197902.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36197902.cfilter2,1,nil,tp)
end
-- 过滤满足条件的电子界族连接怪兽用于特殊召唤
function c36197902.spfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查是否满足发动条件并选择特殊召唤的怪兽
function c36197902.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的电子界族连接怪兽
		and Duel.IsExistingMatchingCard(c36197902.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行特殊召唤操作
function c36197902.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的电子界族连接怪兽
	local g=Duel.SelectMatchingCard(tp,c36197902.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
