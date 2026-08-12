--人造人間－サイコ・リターナー
-- 效果：
-- ①：这张卡可以直接攻击。
-- ②：这张卡被送去墓地时，以自己墓地1只「人造人-念力震慑者」为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在自己结束阶段破坏。
function c9418534.initial_effect(c)
	-- 注册卡片关联密码，表明本卡效果中记载了「人造人-念力震慑者」的卡名
	aux.AddCodeList(c,77585513)
	-- ②：这张卡被送去墓地时，以自己墓地1只「人造人-念力震慑者」为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在自己结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9418534,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c9418534.target)
	e1:SetOperation(c9418534.operation)
	c:RegisterEffect(e1)
	-- ①：这张卡可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选自己墓地中可以特殊召唤的「人造人-念力震慑者」
function c9418534.filter(c,e,tp)
	return c:IsCode(77585513) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的合法性检测与对象选择
function c9418534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c9418534.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的可选择对象
		and Duel.IsExistingTarget(c9418534.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「人造人-念力震慑者」作为效果对象
	local g=Duel.SelectTarget(tp,c9418534.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，包含特殊召唤的对象和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并注册结束阶段破坏的延迟效果
function c9418534.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的效果对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍符合条件，则将其以表侧表示特殊召唤到自己场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(9418534,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在自己结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c9418534.descon)
		e1:SetOperation(c9418534.desop)
		e1:SetCountLimit(1)
		-- 注册全局效果，用于在结束阶段触发破坏处理
		Duel.RegisterEffect(e1,tp)
	end
end
-- 破坏效果的触发条件：目标怪兽仍带有标记且当前为自己的回合
function c9418534.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(9418534)==e:GetLabel() then
		-- 检查当前回合玩家是否为自己
		return Duel.GetTurnPlayer()==tp
	else
		e:Reset()
		return false
	end
end
-- 破坏效果的具体执行：破坏目标怪兽
function c9418534.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
