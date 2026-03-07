--賢者の聖杯
-- 效果：
-- 自己场上没有怪兽存在的场合，选择对方墓地存在的1只怪兽才能发动。选择的怪兽在自己场上特殊召唤。这个回合的结束阶段时，这个效果特殊召唤的怪兽的控制权转移给对方。此外，这个效果特殊召唤的怪兽不能解放，也不能作为同调素材。
function c35262428.initial_effect(c)
	-- 效果定义：发动条件为己方场上没有怪兽存在，选择对方墓地1只怪兽特殊召唤到己方场上，结束阶段将该怪兽控制权转移给对方，且该怪兽不能解放也不能作为同调素材。
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
-- 效果作用：判断己方场上是否没有怪兽存在
function c35262428.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文内容：自己场上没有怪兽存在的场合
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果作用：判断目标怪兽是否可以被特殊召唤
function c35262428.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标为对方墓地的怪兽
function c35262428.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c35262428.filter(chkc,e,tp) end
	-- 效果作用：判断己方场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断对方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c35262428.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择对方墓地满足条件的1只怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c35262428.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：处理效果发动后的特殊召唤及后续效果设置
function c35262428.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断己方场上是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 效果作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认目标怪兽有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 效果原文内容：这个效果特殊召唤的怪兽不能解放
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1,true)
		-- 效果原文内容：这个效果特殊召唤的怪兽不能解放，也不能作为同调素材
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(1)
		tc:RegisterEffect(e2,true)
		-- 效果原文内容：这个效果特殊召唤的怪兽不能解放，也不能作为同调素材
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(1)
		tc:RegisterEffect(e3,true)
		-- 效果原文内容：这个回合的结束阶段时，这个效果特殊召唤的怪兽的控制权转移给对方
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
-- 效果作用：处理结束阶段时控制权转移的效果
function c35262428.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	local p=e:GetLabel()
	if tc:IsControler(1-p) then
		-- 效果作用：将目标怪兽的控制权转移给指定玩家
		Duel.GetControl(tc,p)
	end
end
