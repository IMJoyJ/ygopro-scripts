--幻煌龍の戦渦
-- 效果：
-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：把墓地的这张卡除外，以自己场上1只通常怪兽为对象才能发动。那只怪兽可以装备的自己场上的全部「幻煌龙」装备魔法卡给那只通常怪兽装备。
function c34302287.initial_effect(c)
	-- 将「海」（卡号22702055）登记为该卡记载的卡名，用于场上有「海」时的效果判定。
	aux.AddCodeList(c,22702055)
	-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c34302287.condition)
	e1:SetTarget(c34302287.target)
	e1:SetOperation(c34302287.activate)
	c:RegisterEffect(e1)
	-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34302287,1))  --"适用「幻煌龙的战涡」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(c34302287.handcon)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上1只通常怪兽为对象才能发动。那只怪兽可以装备的自己场上的全部「幻煌龙」装备魔法卡给那只通常怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34302287,0))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置②效果发动时的代价：将墓地的这张卡除外（通过通用除外代价函数aux.bfgcost实现）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c34302287.eqtg)
	e3:SetOperation(c34302287.eqop)
	c:RegisterEffect(e3)
end
-- 目标过滤函数：如果怪兽是里侧表示或不是通常怪兽，则返回true（用于检测是否不存在这样的怪兽，从而保证只有通常怪兽）。
function c34302287.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_NORMAL)
end
-- ①效果的发动条件：自己场上存在怪兽，且场上不存在里侧表示或非通常怪兽（即自己的怪兽全部是表侧通常怪兽）。
function c34302287.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否有怪兽存在（数量大于0）。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己怪兽区不存在任何里侧表示或非通常怪兽，确保自己场上的怪兽只有通常怪兽。
		and not Duel.IsExistingMatchingCard(c34302287.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的取对象处理：选择对方场上1张卡作为对象，并设置破坏的操作信息。
function c34302287.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 效果发动时检查：对方场上是否存在可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡（任意卡）作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁的操作信息：本次效果类别为破坏（CATEGORY_DESTROY），对象为选中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得对象卡，若对象仍与该效果关联则将其破坏。
function c34302287.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时对应的对象卡（Duel.GetFirstTarget取当前连锁的第一个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 手牌发动条件的判定：检查场上是否存在「海」的场地效果。
function c34302287.handcon(e)
	-- 检测当前生效的场地卡是否为「海」（卡号22702055）。
	return Duel.IsEnvironment(22702055)
end
-- 目标选择过滤：目标是表侧表示的通常怪兽，且自己魔陷区至少有1张能装备给它的「幻煌龙」装备魔法卡。
function c34302287.efilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
		-- 检查自己魔陷区是否存在至少1张满足条件的「幻煌龙」装备魔法卡（能装备给目标怪兽）。
		and Duel.IsExistingMatchingCard(c34302287.eqfilter,tp,LOCATION_SZONE,0,1,nil,c)
end
-- 装备卡过滤：该卡是表侧表示的装备魔法卡，属于「幻煌龙」系列（0xfa），且当前能正确装备给目标怪兽。
function c34302287.eqfilter(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(0xfa) and c:CheckEquipTarget(tc)
end
-- ②效果的取对象处理：选择自己场上1只符合条件的通常怪兽（表侧且可装备幻煌龙装备卡）作为对象。
function c34302287.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c34302287.efilter(chkc,tp) end
	-- 效果发动时检查：自己场上是否存在符合条件的通常怪兽目标。
	if chk==0 then return Duel.IsExistingTarget(c34302287.efilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示“请选择表侧表示的卡”的选择提示（HINTMSG_FACEUP）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己怪兽区选择1只符合条件的表侧通常怪兽作为效果对象。
	Duel.SelectTarget(tp,c34302287.efilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ②效果处理：将那只通常怪兽可以装备的自己场上的全部「幻煌龙」装备魔法卡装备给它。
function c34302287.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②选择的对象通常怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 获取自己魔陷区所有能够装备给对象怪兽的表侧「幻煌龙」装备魔法卡。
	local g=Duel.GetMatchingGroup(c34302287.eqfilter,tp,LOCATION_SZONE,0,nil,tc)
	local eq=g:GetFirst()
	while eq do
		-- 将符合条件的装备魔法卡装备给对象怪兽（true,true表示表侧表示并作为装备过程分解步骤，暂不触发时点）。
		Duel.Equip(tp,eq,tc,true,true)
		eq=g:GetNext()
	end
	-- 装备操作全部完成，触发装备成功时的时点。
	Duel.EquipComplete()
end
