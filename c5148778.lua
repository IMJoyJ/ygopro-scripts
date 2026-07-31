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
-- 初始化卡片效果，启用融合召唤限制，添加融合召唤手续，设置灵摆属性，注册灵摆区域特殊召唤成功时的处理效果，注册触发效果代码，注册怪兽效果1、2、3
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足融合类型为融合怪兽和融合种族为幻透翼的怪兽各1只为素材进行融合召唤
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),aux.FilterBoolFunction(Card.IsFusionSetCard,0xff),true)
	-- 设置卡片为灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 当对方场上有怪兽特殊召唤成功时，执行s.acop函数处理
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- 注册合并的延迟事件监听，限制自身诱发效果在连锁中只响应一次
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 设置怪兽效果1，当对方把怪兽表侧表示特殊召唤时，可以发动此效果，使目标怪兽效果无效并提升自身攻击力
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
	-- 设置怪兽效果2，当场上的其他卡的效果发动时，可以发动此效果，破坏场上一张卡
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
	-- 设置怪兽效果3，当自身被破坏时，可以发动此效果，将自身放置在自己的灵摆区域
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
-- 定义过滤函数，用于筛选对方控制的表侧表示怪兽
function s.cofilter(c,tp)
	return c:IsFaceup() and c:IsControler(1-tp)
end
-- 处理灵摆区域特殊召唤成功的效果，给符合条件的怪兽添加捕食指示物，并改变其等级
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(s.cofilter,nil,tp)
	-- 遍历符合条件的怪兽组
	for tc in aux.Next(sg) do
		if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
			-- 创建一个改变等级的效果并注册到目标怪兽上
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
-- 定义等级变化条件函数，当目标怪兽拥有捕食指示物时生效
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 定义过滤函数，用于筛选满足条件的目标怪兽
function s.disfilter(c,tp,e)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
		and c:GetAttack()>0
end
-- 判断是否满足怪兽效果1的发动条件，即对方有怪兽特殊召唤成功
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有对方控制的表侧表示怪兽被特殊召唤
	return eg:IsExists(aux.AND(Card.IsSummonPlayer,Card.IsFaceup),1,nil,1-tp)
end
-- 设置怪兽效果1的目标选择函数，根据目标数量决定是否需要选择目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.disfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 设置操作信息，指定要无效化和提升攻击力的对象
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择目标对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择目标怪兽
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置操作信息，指定要无效化的对象
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
end
-- 执行怪兽效果1的操作，提升自身攻击力并使目标怪兽效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local atk=tc:GetAttack()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and c:IsRelateToChain() and c:IsFaceup() and atk>0 then
		-- 创建一个提升攻击力的效果并注册到自身上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 使目标怪兽的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 创建一个使目标怪兽效果无效的效果并注册到目标怪兽上
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 创建一个使目标怪兽效果被无效化的效果并注册到目标怪兽上
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 判断是否满足怪兽效果2的发动条件，即场上的其他卡的效果发动时
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁触发位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:GetHandler()~=e:GetHandler()
end
-- 设置怪兽效果2的目标选择函数，选择场上一张卡进行破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有卡的卡片组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息，指定要破坏的对象
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行怪兽效果2的操作，选择并破坏场上一张卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的一张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将目标卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 判断是否满足怪兽效果3的发动条件，即自身在怪兽区域被破坏
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置怪兽效果3的目标选择函数，检查灵摆区域是否有空位
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家的灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，指定要离开墓地的对象
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 执行怪兽效果3的操作，将自身放置在自己的灵摆区域
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足放置灵摆区域的条件，即自身在怪兽区域被破坏且处于表侧表示状态
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身移动到玩家的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
