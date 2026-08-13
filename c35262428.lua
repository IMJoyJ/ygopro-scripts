--賢者の聖杯
-- 效果：
-- 自己场上没有怪兽存在的场合，选择对方墓地存在的1只怪兽才能发动。选择的怪兽在自己场上特殊召唤。这个回合的结束阶段时，这个效果特殊召唤的怪兽的控制权转移给对方。此外，这个效果特殊召唤的怪兽不能解放，也不能作为同调素材。
function c35262428.initial_effect(c)
	-- 对应效果原文：自己场上没有怪兽存在的场合，选择对方墓地存在的1只怪兽才能发动。选择的怪兽在自己场上特殊召唤。这个回合的结束阶段时，这个效果特殊召唤的怪兽的控制权转移给对方。此外，这个效果特殊召唤的怪兽不能解放，也不能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c35262428.condition)
	e1:SetTarget(c35262428.target)
	e1:SetOperation(c35262428.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定函数，检查我方场上是否存在怪兽，规则上对应“自己场上没有怪兽存在的场合”这一发动条件。
function c35262428.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计我方场上主要怪兽区域的怪兽数量，数量为0时才满足发动条件。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 目标筛选函数，判断对方墓地的怪兽是否能够被当前效果特殊召唤（包含苏生限制等召唤条件的检查）。
function c35262428.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时目标选择函数：校验选择的对象是否合法（对方墓地且可特殊召唤），并检查发动条件是否满足；规则上对应“选择对方墓地存在的1只怪兽才能发动”。
function c35262428.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c35262428.filter(chkc,e,tp) end
	-- 发动条件检查第一部分：自己场上需要有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查第二部分：对方墓地存在至少1只满足特殊召唤条件的怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c35262428.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 弹出选择提示，向玩家显示“请选择要特殊召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从对方墓地选择1只符合条件的怪兽，并登记为本次效果的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c35262428.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置操作信息，通告系统本效果将进行1只怪兽的特殊召唤，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的整体函数：确认场上仍有空格后，将对象怪兽特殊召唤到自己场上，并为其附加“不能解放”“不能作为同调素材”的限制，以及结束阶段控制权转移的效果。
function c35262428.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用怪兽区域，若没有空格则整个效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽与效果仍有关联，则将目标怪兽以表侧表示特殊召唤到自己场上，若特殊召唤成功则继续执行后续附加效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 对应效果原文“这个效果特殊召唤的怪兽不能解放”中的“不能作为上级召唤的祭品”限制。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1,true)
		-- 对应效果原文“这个效果特殊召唤的怪兽不能解放”中的“不能作为上级召唤以外的祭品”限制，与上一效果共同实现完全不能解放。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1)
		tc:RegisterEffect(e2,true)
		-- 对应效果原文“也不能作为同调素材”。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
		-- 对应效果原文“这个回合的结束阶段时，这个效果特殊召唤的怪兽的控制权转移给对方”。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetOperation(c35262428.ctlop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetLabel(1-tp)
		tc:RegisterEffect(e4,true)
	end
end
-- 结束阶段触发的辅助效果处理函数：获取需要转移控制权的怪兽和目标玩家，若目标怪兽仍在原召唤者（效果发动者tp）的控制下，则将其控制权转移给label存储的对方玩家p。
function c35262428.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local p=e:GetLabel()
	if tc:IsControler(1-p) then
		-- 将目标怪兽的控制权转移给玩家p，即转移给对方玩家，实现“控制权转移给对方”的结算。
		Duel.GetControl(tc,p)
	end
end
