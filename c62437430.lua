--異次元海溝
-- 效果：
-- 这张卡的发动时，选自己的手卡·场上·墓地1只水属性怪兽从游戏中除外。那之后，场上表侧表示存在的这张卡被破坏时，这张卡的效果除外的怪兽在自己场上特殊召唤。
function c62437430.initial_effect(c)
	-- 这张卡的发动时，选自己的手卡·场上·墓地1只水属性怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c62437430.target)
	e1:SetOperation(c62437430.operation)
	c:RegisterEffect(e1)
	-- 那之后，场上表侧表示存在的这张卡被破坏时，这张卡的效果除外的怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62437430,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetCondition(c62437430.spcon)
	e2:SetTarget(c62437430.sptg)
	e2:SetOperation(c62437430.spop)
	c:RegisterEffect(e2)
	e1:SetLabelObject(e2)
end
-- 过滤函数：筛选手卡、场上、墓地的水属性且可以除外的怪兽（若在场上则必须表侧表示）
function c62437430.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToRemove()
		and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
-- 效果1（发动时除外）的靶向/检测函数
function c62437430.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的手卡、场上、墓地是否存在至少1只满足过滤条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c62437430.filter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：此效果在处理时会从手卡、场上或墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE)
end
-- 效果1（发动时除外）的效果处理函数
function c62437430.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家发送提示信息，要求选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡、场上或墓地选择1只满足条件的水属性怪兽（受王家长眠之谷影响）
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c62437430.filter),tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil):GetFirst()
	-- 若成功选择并因效果表侧表示除外该怪兽，且该怪兽确实移动到了除外区
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		tc:RegisterFlagEffect(62437430,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():SetLabelObject(tc)
	end
end
-- 效果2（破坏时特召）的触发条件：这张卡在场上表侧表示存在并因破坏而离场，且存在被此卡除外的怪兽
function c62437430.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	return tc and c:IsReason(REASON_DESTROY) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果2（破坏时特召）的靶向/检测函数：确认被除外的怪兽仍带有标记，且该怪兽是被此卡的效果除外的
function c62437430.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetLabelObject():GetFlagEffect(62437430)~=0
		and e:GetLabelObject():GetReasonEffect():GetHandler()==e:GetHandler() end
	-- 将被此卡效果除外的怪兽设为当前连锁的效果处理对象
	Duel.SetTargetCard(e:GetLabelObject())
	-- 设置操作信息：此效果在处理时会特殊召唤1只被除外的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetLabelObject(),1,0,0)
end
-- 效果2（破坏时特召）的效果处理函数
function c62437430.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设为对象的被除外怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到发动效果的玩家场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
