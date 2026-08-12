--幻煌龍の戦渦
-- 效果：
-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
-- ②：把墓地的这张卡除外，以自己场上1只通常怪兽为对象才能发动。那只怪兽可以装备的自己场上的全部「幻煌龙」装备魔法卡给那只通常怪兽装备。
function c34302287.initial_effect(c)
	-- 记录此卡与「海」的关联，用于效果条件判断
	aux.AddCodeList(c,22702055)
	-- 场上有「海」存在的场合，这张卡的发动从手卡也能用。
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
	-- ①：自己场上的怪兽只有通常怪兽的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
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
	-- 将此卡从墓地除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c34302287.eqtg)
	e3:SetOperation(c34302287.eqop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否存在非通常怪兽或里侧表示的怪兽
function c34302287.cfilter(c)
	return c:IsFacedown() or not c:IsType(TYPE_NORMAL)
end
-- 判断自己场上是否存在怪兽且全部为通常怪兽
function c34302287.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上是否不存在非通常怪兽或里侧表示的怪兽
		and not Duel.IsExistingMatchingCard(c34302287.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果目标为对方场上的任意一张卡
function c34302287.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查对方场上是否存在至少一张卡作为目标
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张卡作为目标
	local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息，表示将要破坏1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果，破坏目标卡
function c34302287.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断当前是否处于「海」场地效果影响下
function c34302287.handcon(e)
	-- 检查当前场地卡是否为「海」
	return Duel.IsEnvironment(22702055)
end
-- 过滤函数，用于判断场上是否存在可以装备的通常怪兽
function c34302287.efilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL)
		-- 检查该通常怪兽是否可以装备「幻煌龙」装备魔法卡
		and Duel.IsExistingMatchingCard(c34302287.eqfilter,tp,LOCATION_SZONE,0,1,nil,c)
end
-- 过滤函数，用于筛选「幻煌龙」装备魔法卡
function c34302287.eqfilter(c,tc)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP) and c:IsSetCard(0xfa) and c:CheckEquipTarget(tc)
end
-- 设置效果目标为己方场上的1只通常怪兽
function c34302287.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c34302287.efilter(chkc,tp) end
	-- 检查己方场上是否存在至少1只通常怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c34302287.efilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择表侧表示的通常怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择己方场上的1只通常怪兽作为目标
	Duel.SelectTarget(tp,c34302287.efilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 执行效果，将装备魔法卡装备给目标怪兽
function c34302287.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	-- 获取己方场上所有可装备的「幻煌龙」装备魔法卡
	local g=Duel.GetMatchingGroup(c34302287.eqfilter,tp,LOCATION_SZONE,0,nil,tc)
	local eq=g:GetFirst()
	while eq do
		-- 将装备魔法卡装备给目标怪兽
		Duel.Equip(tp,eq,tc,true,true)
		eq=g:GetNext()
	end
	-- 完成装备过程的时点处理
	Duel.EquipComplete()
end
