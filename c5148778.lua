--覇王暴竜スターヴ・ヴェノム・ウィング・ドラゴン
-- 效果：
-- ←10 【灵摆】 10→
-- ①：只要这张卡在灵摆区域存在，每次对方场上有怪兽特殊召唤，给那些怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- 【怪兽效果】
-- 融合怪兽＋「幻透翼」怪兽
-- ①：1回合1次，对方把怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力数值，那只怪兽的效果无效化。
-- ②：1回合1次，这张卡以外的卡的效果在场上发动时才能发动。场上1张卡破坏。
-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
local s,id,o=GetID()
-- 初始化这张卡：设置融合怪兽的苏生限制与融合召唤手续、添加灵摆属性，并注册灵摆区域的放置捕食指示物永续效果、怪兽区域的①效果（攻击上升并无效化）、②效果（破坏场上1张卡）和③效果（被破坏时放置到灵摆区域）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤手续：以融合怪兽和「幻透翼」怪兽（卡片系列0xff）各1只作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),aux.FilterBoolFunction(Card.IsFusionSetCard,0xff),true)
	-- 为这张卡添加灵摆怪兽属性，但不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 只要这张卡在灵摆区域存在，每次对方场上有怪兽特殊召唤，给那些怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- 为这张卡注册合并的延迟特殊召唤事件监听，使其诱发效果在同一连锁中只响应一次
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ①：1回合1次，对方把怪兽表侧表示特殊召唤的场合，以那之内的1只为对象才能发动。直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力数值，那只怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效并上升攻击力"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，这张卡以外的卡的效果在场上发动时才能发动。场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏效果"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	-- ③：怪兽区域的这张卡被破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"放置灵摆区域"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end
s.mentioned_counter={
	[0x1041]=true,
}
-- 过滤函数：筛选表侧表示且控制者为对方的卡
function s.cofilter(c,tp)
	return c:IsFaceup() and c:IsControler(1-tp)
end
-- 放置捕食指示物处理：在特殊召唤成功的怪兽中筛出对方场上的表侧表示怪兽，给每只放置1个捕食指示物，若为2星以上则登记一个将其等级变为1星的永续效果
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(s.cofilter,nil,tp)
	-- 依次遍历筛选出的对方特殊召唤怪兽，逐一处理
	for tc in aux.Next(sg) do
		if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
			-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetCondition(s.lvcon)
			e1:SetValue(1)
			tc:RegisterEffect(e1)
		end
	end
end
-- 等级变化的适用条件：该怪兽放置有捕食指示物（数量大于0）
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 过滤函数：筛选对方特殊召唤的、在怪兽区域表侧表示、可作为效果对象且攻击力大于0的怪兽
function s.disfilter(c,tp,e)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
		and c:GetAttack()>0
end
-- 发动条件：本次特殊召唤成功的怪兽中存在由对方以表侧表示特殊召唤的怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查特殊召唤成功的怪兽组中是否至少有1只由对方以表侧表示特殊召唤
	return eg:IsExists(aux.AND(Card.IsSummonPlayer,Card.IsFaceup),1,nil,1-tp)
end
-- 选择对象处理：筛出符合条件的怪兽，只有1只时直接取为对象，有多只时提示玩家选择1只作为对象，并设置效果无效化的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.disfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 候选怪兽只有1只时，直接将其设置为当前连锁的对象
		Duel.SetTargetCard(sg)
	else
		-- 向玩家提示请选择效果的对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 让玩家从符合条件的怪兽中选择1只作为效果的对象
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置操作信息：本连锁将无效化作为对象的1只怪兽的效果
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
end
-- 效果处理：取得对象怪兽并记录其攻击力，双方仍与连锁相关且这张卡表侧表示时，这张卡攻击力上升该数值直到回合结束，并使对象怪兽的效果无效化直到回合结束
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local atk=tc:GetAttack()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and c:IsRelateToChain() and c:IsFaceup() and atk>0 then
		-- 直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 将与对象怪兽相关的连锁全部无效化（该怪兽被盖放则重置）
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那只怪兽的效果无效化（直到回合结束）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 那只怪兽的效果无效化（直到回合结束，被盖放则重置）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 发动条件：发动效果的卡在场上、这张卡不是因战斗破坏且发动效果的卡不是这张卡本身
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中发动效果的卡的所在位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:GetHandler()~=e:GetHandler()
end
-- 选择目标处理：取得双方场上的所有卡，确认存在可破坏的卡后设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得双方场上所有卡作为可破坏的候选
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：本连锁将破坏场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：提示后由玩家选择场上1张卡，显示选择动画并将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张要破坏的卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为选择的卡显示被选中的动画并记录选择
		Duel.HintSelection(g)
		-- 以效果原因破坏选择的1张卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 发动条件：这张卡被破坏前位于怪兽区域且为表侧表示
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 目标处理：确认自己的灵摆区域有空位；若这张卡在墓地，则设置离开墓地的操作信息
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的灵摆区域是否至少有一个空位可用
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 这张卡在墓地时，设置操作信息：本连锁将使这张卡离开墓地
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 效果处理：这张卡仍与连锁相关且不受王家长眠之谷影响时，将其以表侧表示放置到自己的灵摆区域
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁相关，且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 把这张卡以表侧表示移动到自己的灵摆区域并立即适用其效果
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
