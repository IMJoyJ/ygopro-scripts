--浮鵺城
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：这张卡同调召唤成功时，以自己墓地1只9星怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，召唤·特殊召唤的8星以下的怪兽在那个回合不能攻击。
function c9348522.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功时，以自己墓地1只9星怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9348522,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c9348522.spcon)
	e1:SetTarget(c9348522.sptg)
	e1:SetOperation(c9348522.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，召唤·特殊召唤的8星以下的怪兽在那个回合不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c9348522.limtg)
	c:RegisterEffect(e2)
	if not c9348522.global_check then
		c9348522.global_check=true
		-- ②：只要这张卡在怪兽区域存在，召唤·特殊召唤的8星以下的怪兽在那个回合不能攻击。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c9348522.checkop)
		-- 注册全局效果：用于记录通常召唤成功的怪兽
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 注册全局效果：用于记录特殊召唤成功的怪兽
		Duel.RegisterEffect(ge2,0)
	end
end
-- 召唤·特殊召唤成功时，给这些怪兽注册一个在回合结束时重置的标记，用于判定“在那个回合”
function c9348522.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(9348522,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 判定发动条件：这张卡同调召唤成功
function c9348522.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：自己墓地中等级为9且可以特殊召唤的怪兽
function c9348522.spfilter(c,e,tp)
	return c:IsLevel(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备：检查是否满足发动条件并选择对象
function c9348522.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c9348522.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的9星怪兽
		and Duel.IsExistingTarget(c9348522.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的9星怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c9348522.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，对象为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理：将选择的对象怪兽特殊召唤
function c9348522.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤不能攻击的怪兽：等级在8星以下，且带有在本回合召唤·特殊召唤成功的标记
function c9348522.limtg(e,c)
	return c:IsLevelBelow(8) and c:GetFlagEffect(9348522)~=0
end
