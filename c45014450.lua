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
	-- 为这张灵摆怪兽卡添加灵摆召唤、灵摆放置等基本属性；active_effect=false表示不注册灵摆卡“卡的发动”效果，仅作为灵摆怪兽存在。
	aux.EnablePendulumAttribute(c,false)
	-- 为这张卡添加融合召唤手续：以1只「凶饿毒」怪兽和1只「异色眼」怪兽作为融合素材进行融合召唤。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1050),aux.FilterBoolFunction(Card.IsFusionSetCard,0x99),true)
	-- 这张卡用融合召唤以及灵摆召唤才能特殊召唤。
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
-- 特殊召唤条件的判定：仅允许以融合召唤或灵摆召唤的方式特殊召唤这张卡，其他特殊召唤方式均不被允许。
function c45014450.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION or bit.band(st,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 过滤条件：表侧表示且为融合怪兽，用于选择自己场上的融合怪兽作为灵摆效果的对象。
function c45014450.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION)
end
-- 灵摆效果①的发动条件与取对象处理：需要自己场上存在1只表侧表示融合怪兽，且对方场上存在怪兽（用于计算上升数值）；满足条件时选择1只符合条件的融合怪兽作为对象。
function c45014450.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c45014450.atkfilter(chkc) end
	-- 发动条件检查阶段：确认自己场上存在至少1只满足条件的表侧表示融合怪兽，可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c45014450.atkfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时确认对方场上存在至少1只怪兽，否则攻击力上升数值无意义，不能发动。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	-- 向操作者显示选择提示，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行对象选择：选择自己场上1只表侧表示融合怪兽，并将其记录为当前连锁的对象。
	Duel.SelectTarget(tp,c45014450.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 灵摆效果①的处理：获得对象怪兽和对方场上怪兽数量，令该对象怪兽的攻击力上升（对方场上怪兽数量×1000），直到回合结束时适用。
function c45014450.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的融合怪兽对象。
	local tc=Duel.GetFirstTarget()
	-- 获取对方场上存在的怪兽数量，用于计算攻击力上升的数值。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) and ct>0 then
		-- 那只怪兽的攻击力直到回合结束时上升对方场上的怪兽数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000*ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 复制效果①的发动代价：通过标志位限制该效果1回合只能发动1次；若本回合尚未发动过则注册标志，否则无法发动。
function c45014450.copycost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(45014450)==0 end
	e:GetHandler():RegisterFlagEffect(45014450,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 复制效果的对象过滤条件：表侧表示怪兽且不是衍生物（衍生物不能复制卡名/效果）。
function c45014450.copyfilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
end
-- 复制效果①的发动条件与取对象处理：选择对方场上1只表侧表示的非衍生物怪兽作为对象；满足条件时进行选择并记录。
function c45014450.copytg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c45014450.copyfilter(chkc) end
	-- 发动条件检查阶段：确认对方场上存在至少1只满足条件的表侧表示怪兽，可以作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c45014450.copyfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择提示，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 执行对象选择：选择对方场上1只表侧表示非衍生物怪兽，并将其记录为当前连锁的对象。
	Duel.SelectTarget(tp,c45014450.copyfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 复制效果①的处理：若此卡与对象怪兽均与效果相关且表侧表示，则此卡获得对象怪兽的原本卡名；若对象不是陷阱怪兽，则复制其效果；同时此卡攻击力上升对象怪兽当前攻击力数值，以上状态保持到结束阶段。
function c45014450.copyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取复制效果选择的对方怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsType(TYPE_TOKEN) then
		local code=tc:GetOriginalCodeRule()
		-- 这张卡得到和那只怪兽相同的原本的卡名·效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(code)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		if not tc:IsType(TYPE_TRAPMONSTER) then
			local cid=c:CopyEffect(code,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,1)
			-- 直到结束阶段，这张卡得到和那只怪兽相同的原本的卡名·效果（结束时清除复制状态）。
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
		-- 直到结束阶段，这张卡的攻击力上升那只怪兽的攻击力数值。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(atk)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 结束阶段时清除复制来的效果和卡名变更效果，并向对方提示复制效果结束。
function c45014450.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then
		c:ResetEffect(cid,RESET_COPY)
		c:ResetEffect(RESET_DISABLE,RESET_EVENT)
	end
	local e1=e:GetLabelObject()
	e1:Reset()
	-- 向玩家显示这张卡作为被操作对象的动画，并记录其为对象。
	Duel.HintSelection(Group.FromCards(c))
	-- 向对方玩家提示“对方选择了：”并显示该效果描述，告知对方复制效果已经结束。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 灵摆效果②的发动条件：这张卡被破坏前位于怪兽区域且为表侧表示，满足“怪兽区域的这张卡被破坏”的条件。
function c45014450.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 特殊召唤过滤条件：判断灵摆区域的卡是否能够被效果特殊召唤（不检查苏生限制等条件）。
function c45014450.penfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 灵摆效果②的发动条件：自己主要怪兽区域有空位，且自己的灵摆区域存在可以特殊召唤的卡；满足则设置将灵摆区1张卡特殊召唤的操作信息。
function c45014450.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确保自己场上主要怪兽区域至少有一个可用空格，用于后续特殊召唤灵摆区的卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己的灵摆区域是否存在至少1张满足特殊召唤条件的卡。
		and Duel.IsExistingMatchingCard(c45014450.penfilter,tp,LOCATION_PZONE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：本次效果处理涉及特殊召唤，预定处理1张卡，来源为自己的灵摆区域。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_PZONE)
end
-- 灵摆效果②的处理：若这张卡仍与效果相关且主要怪兽区域有空位，则从自己的灵摆区域选择1张卡特殊召唤；若成功，则把这张卡放置到自己的灵摆区域。
function c45014450.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理前的安全性检查：若这张卡已与效果失去联系或自己场上没有可用怪兽区域，则终止处理。
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 向操作者显示选择提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的灵摆区域选择1张满足条件的卡，准备特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c45014450.penfilter,tp,LOCATION_PZONE,0,1,1,nil,e,tp)
	-- 检查是否成功选择了卡且特殊召唤成功（至少1张），成功后继续执行放置灵摆区域。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 把这张卡移动到自己的灵摆区域，实现“这张卡在自己的灵摆区域放置”。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
