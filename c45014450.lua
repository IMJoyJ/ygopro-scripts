--覇王紫竜オッドアイズ・ヴェノム・ドラゴン
-- 效果：
-- ←1 【灵摆】 1→
-- ①：1回合1次，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升对方场上的怪兽数量×1000。
-- 【怪兽效果】
-- 「凶饿毒」怪兽＋「异色眼」怪兽
-- 这张卡用融合召唤以及灵摆召唤才能特殊召唤。
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的攻击力数值，这张卡得到和那只怪兽相同的原本的卡名·效果。
-- ②：怪兽区域的这张卡被破坏的场合才能发动。选自己的灵摆区域1张卡特殊召唤，这张卡在自己的灵摆区域放置。
function c45014450.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 设置融合召唤手续，使用满足条件的「凶饿毒」怪兽和「异色眼」怪兽各1只为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1050),aux.FilterBoolFunction(Card.IsFusionSetCard,0x99),true)
	-- ①：1回合1次，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升对方场上的怪兽数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c45014450.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1只融合怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升对方场上的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45014450,0))  --"融合怪兽攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c45014450.atktg)
	e2:SetOperation(c45014450.atkop)
	c:RegisterEffect(e2)
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。直到结束阶段，这张卡的攻击力上升那只怪兽的攻击力数值，这张卡得到和那只怪兽相同的原本的卡名·效果。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45014450,1))  --"复制效果"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c45014450.copycost)
	e3:SetTarget(c45014450.copytg)
	e3:SetOperation(c45014450.copyop)
	c:RegisterEffect(e3)
	-- ②：怪兽区域的这张卡被破坏的场合才能发动。选自己的灵摆区域1张卡特殊召唤，这张卡在自己的灵摆区域放置。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetDescription(aux.Stringid(45014450,3))  --"灵摆区域卡特殊召唤"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c45014450.pencon)
	e6:SetTarget(c45014450.pentg)
	e6:SetOperation(c45014450.penop)
	c:RegisterEffect(e6)
end
-- 限制此卡只能通过融合召唤或灵摆召唤特殊召唤
function c45014450.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤满足条件的融合怪兽
function c45014450.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 设置效果目标为己方场上的融合怪兽
function c45014450.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c45014450.atkfilter(chkc) end
	-- 检查己方场上是否存在融合怪兽
	if chk==0 then return Duel.IsExistingTarget(c45014450.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在怪兽
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择己方场上的融合怪兽作为效果对象
	Duel.SelectTarget(tp,c45014450.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 处理效果，使目标融合怪兽攻击力上升
function c45014450.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取对方场上的怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and ct>0 then
		-- 使目标融合怪兽攻击力上升对方场上的怪兽数量×1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 设置复制效果的费用，防止重复发动
function c45014450.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(45014450)==0 end
	e:GetHandler():RegisterFlagEffect(45014450,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤满足条件的对方表侧表示怪兽
function c45014450.copyfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 设置效果目标为对方场上的表侧表示怪兽
function c45014450.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c45014450.copyfilter(chkc) end
	-- 检查对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c45014450.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,c45014450.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果，使此卡复制目标怪兽的卡名和效果
function c45014450.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		-- 使此卡的卡号变为目标怪兽的原始卡号
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			-- 设置复制效果在结束阶段结束后自动解除
			local e3=Effect.CreateEffect(c)
			e3:SetDescription(aux.Stringid(45014450,2))  --"结束复制效果"
			e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e3:SetCode(EVENT_PHASE+PHASE_END)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e3:SetCountLimit(1)
			e3:SetRange(LOCATION_MZONE)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e3:SetLabelObject(e1)
			e3:SetLabel(cid)
			e3:SetOperation(c45014450.rstop)
			c:RegisterEffect(e3)
		end
		local atk=tc:GetAttack()
		-- 使此卡攻击力上升目标怪兽的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 处理复制效果的结束操作
function c45014450.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 显示被选为对象的卡的动画效果
	Duel.HintSelection(Group.FromCards(c))
	-- 提示对方玩家选择了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 判断此卡是否从怪兽区域被破坏
function c45014450.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 过滤满足条件的灵摆区域卡片
function c45014450.penfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置灵摆区域特殊召唤的效果目标
function c45014450.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方灵摆区域是否存在可特殊召唤的卡片
		and Duel.IsExistingMatchingCard(c45014450.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤灵摆区域的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
-- 处理灵摆区域特殊召唤效果
function c45014450.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍存在于场上且己方场上是否有空位
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择己方灵摆区域的卡片进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c45014450.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 将此卡移回灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
