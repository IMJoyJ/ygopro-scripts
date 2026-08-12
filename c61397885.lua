--幻煌龍の浸渦
-- 效果：
-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力下降1000，效果无效化。
-- ②：把墓地的这张卡除外，以自己场上1只通常怪兽为对象才能发动。从自己的手卡·墓地选1张「幻煌龙」装备魔法卡给那只通常怪兽装备。
function c61397885.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果中记有「海」（卡号22702055）。
	aux.AddCodeList(c,22702055)
	-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1只效果怪兽为对象才能发动。那只怪兽直到回合结束时攻击力·守备力下降1000，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP+TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c61397885.condition)
	e1:SetTarget(c61397885.target)
	e1:SetOperation(c61397885.activate)
	c:RegisterEffect(e1)
	-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(61397885,1))  --"适用「幻煌龙的浸涡」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c61397885.handcon)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只通常怪兽为对象才能发动。从自己的手卡·墓地选1张「幻煌龙」装备魔法卡给那只通常怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(61397885,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	-- 将此卡从墓地除外作为发动效果的cost。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c61397885.eqtg)
	e3:SetOperation(c61397885.eqop)
	c:RegisterEffect(e3)
end
-- 过滤条件：里侧表示怪兽或非通常怪兽（用于检测自己场上是否存在通常怪兽以外的怪兽）。
function c61397885.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_NORMAL)
end
-- 效果①的发动条件：自己场上有怪兽存在，且不存在通常怪兽以外的怪兽（即自己场上的怪兽只有通常怪兽），且不在伤害计算后。
function c61397885.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量大于0。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上不存在里侧表示怪兽或非通常怪兽（即自己场上的怪兽只有通常怪兽）。
		and not Duel.IsExistingMatchingCard(c61397885.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 限制在伤害步骤中不能在伤害计算后发动。
		and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 过滤条件：表侧表示的效果怪兽。
function c61397885.mfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果①的靶向处理：选择对方场上1只表侧表示的效果怪兽为对象，并设置无效化的操作信息。
function c61397885.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c61397885.mfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(c61397885.mfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示的效果怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c61397885.mfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为：使选中的1只怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的实际处理：使目标怪兽的攻击力·守备力下降1000，并使其效果无效化，持续到回合结束。
function c61397885.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 使与目标怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽直到回合结束时攻击力·守备力下降1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 效果无效化。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE_EFFECT)
		e4:SetValue(RESET_TURN_SET)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
-- 手卡发动条件判定函数。
function c61397885.handcon(e)
	-- 检查场上是否存在「海」（卡号22702055）。
	return Duel.IsEnvironment(22702055)
end
-- 过滤条件：自己场上表侧表示的通常怪兽，且手卡或墓地存在可以装备给它的「幻煌龙」装备魔法卡。
function c61397885.efilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
		-- 检查自己的手卡或墓地是否存在可以装备给该怪兽的装备卡。
		and Duel.IsExistingMatchingCard(c61397885.eqfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,c)
end
-- 过滤条件：属于「幻煌龙」系列（字段0xfa）的装备魔法卡，且可以装备给目标怪兽。
function c61397885.eqfilter(c,tc)
	return c:IsType(TYPE_EQUIP) and c:IsSetCard(0xfa) and c:CheckEquipTarget(tc)
end
-- 效果②的靶向处理：检查魔法与陷阱区域是否有空位，并选择自己场上1只表侧表示的通常怪兽作为效果对象。
function c61397885.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c61397885.efilter(chkc,tp) end
	-- 检查自己的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足条件的通常怪兽作为对象。
		and Duel.IsExistingTarget(c61397885.efilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择自己场上1只表侧表示的通常怪兽作为效果对象。
	Duel.SelectTarget(tp,c61397885.efilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果②的实际处理：从手卡或墓地选择1张「幻煌龙」装备魔法卡装备给选中的通常怪兽。
function c61397885.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法与陷阱区域是否有空位，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取作为装备对象的目标通常怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手卡或墓地选择1张不受「王家长眠之谷」影响的「幻煌龙」装备魔法卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c61397885.eqfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tc)
	local eq=g:GetFirst()
	if eq then
		-- 将选中的装备魔法卡装备给目标通常怪兽。
		Duel.Equip(tp,eq,tc)
	end
end
