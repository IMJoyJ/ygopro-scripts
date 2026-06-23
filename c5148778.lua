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
-- 初始化卡片效果，启用融合召唤限制，添加融合召唤手续，设置灵摆属性，注册灵摆区域特殊召唤成功时的处理函数，创建自定义延迟事件代码，注册触发效果，注册快速效果，注册破坏时的灵摆区域放置效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用满足融合类型为融合怪兽和融合种族为幻透翼的怪兽各1只为素材进行融合召唤
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionType,TYPE_FUSION),aux.FilterBoolFunction(Card.IsFusionSetCard,0xff),true)
	-- 设置卡片为灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 创建一个持续性字段效果，当对方特殊召唤成功时触发处理函数acop
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	-- 注册合并的延迟事件监听器，用于监听特殊召唤成功事件并统一触发后续效果
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 创建一个触发效果，当自定义事件发生时，选择目标怪兽使其效果无效并提升攻击力
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
	-- 创建一个快速效果，在场上其他卡发动效果时破坏一张场上的卡
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
	-- 创建一个破坏时的触发效果，将此卡放置到自己的灵摆区域
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
-- 定义过滤函数，筛选对方控制且表侧表示的怪兽
function s.cofilter(c,tp)
	return c:IsFaceup() and c:IsControler(1-tp)
end
-- 处理灵摆区域特殊召唤成功的效果，为符合条件的怪兽添加捕食指示物并改变其等级
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	local sg=eg:Filter(s.cofilter,nil,tp)
	-- 遍历符合条件的怪兽组
	for tc in aux.Next(sg) do
		if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
			-- 创建一个改变等级的效果，将怪兽等级变为1星
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
-- 定义等级变化条件，当怪兽拥有捕食指示物时生效
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
-- 定义过滤函数，筛选对方特殊召唤的表侧表示怪兽且可成为效果对象且攻击力大于0
function s.disfilter(c,tp,e)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e)
		and c:GetAttack()>0
end
-- 定义触发条件，判断是否有对方特殊召唤的怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有对方特殊召唤的怪兽
	return eg:IsExists(aux.AND(Card.IsSummonPlayer,Card.IsFaceup),1,nil,1-tp)
end
-- 设置触发效果的目标选择逻辑，根据怪兽数量决定是否需要选择目标
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.disfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 设置操作信息，指定要使目标怪兽无效化
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择效果对象
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		-- 选择目标怪兽
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置操作信息，指定要使目标怪兽无效化
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
end
-- 处理触发效果的执行逻辑，提升攻击力并使目标怪兽效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	local atk=tc:GetAttack()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and c:IsRelateToChain() and c:IsFaceup() and atk>0 then
		-- 创建一个提升攻击力的效果，提升值为目标怪兽的攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_DISABLE)
		e1:SetValue(atk)
		c:RegisterEffect(e1)
		if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 创建一个使目标怪兽效果无效的效果
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			-- 创建一个使目标怪兽效果失效的效果
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_EFFECT)
			e3:SetValue(RESET_TURN_SET)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
-- 定义破坏效果的触发条件，判断是否在场上发动且不是战斗破坏且不是自己发动
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的触发位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		and re:GetHandler()~=e:GetHandler()
end
-- 设置破坏效果的目标选择逻辑，选择场上的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 筛选场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息，指定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 处理破坏效果的执行逻辑，选择并破坏一张场上的卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择要破坏的卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 破坏选定的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 定义灵摆区域放置效果的触发条件，判断此卡是否从怪兽区域被破坏且表侧表示
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆区域放置效果的目标选择逻辑，检查是否有空的灵摆区域
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有空的灵摆区域
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
	local c=e:GetHandler()
	if c:IsLocation(LOCATION_GRAVE) then
		-- 设置操作信息，指定要离开墓地的卡
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
	end
end
-- 处理灵摆区域放置效果的执行逻辑，将此卡移动到自己的灵摆区域
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与连锁相关且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡移动到自己的灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
