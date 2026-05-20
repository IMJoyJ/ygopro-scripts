--ネフティスの覚醒
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「奈芙提斯」怪兽的攻击力上升300。
-- ②：魔法与陷阱区域的表侧表示的这张卡被效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「奈芙提斯」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c82832464.initial_effect(c)
	-- 这张卡的发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置发动条件为不在伤害计算后
	e1:SetCondition(aux.dscon)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「奈芙提斯」怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 过滤并确定适用对象为自己场上的「奈芙提斯」怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x11f))
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- ②：魔法与陷阱区域的表侧表示的这张卡被效果破坏送去墓地的场合才能发动。从自己的手卡·卡组·墓地选1只「奈芙提斯」怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82832464,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,82832464)
	e3:SetCondition(c82832464.spcon)
	e3:SetTarget(c82832464.sptg)
	e3:SetOperation(c82832464.spop)
	c:RegisterEffect(e3)
end
-- 判定发动条件：这张卡原本在魔法与陷阱区域表侧表示存在，因效果被破坏并送去墓地
function c82832464.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEUP)
		and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT)
end
-- 判定特殊召唤效果的发动可行性（检查怪兽区域空位以及手卡、卡组、墓地是否存在可特殊召唤的「奈芙提斯」怪兽）
function c82832464.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡、卡组、墓地是否存在至少1只可以特殊召唤的「奈芙提斯」怪兽
		and Duel.IsExistingMatchingCard(c82832464.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表明该效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：属于「奈芙提斯」系列且可以被特殊召唤的怪兽
function c82832464.spfilter(c,e,tp)
	return c:IsSetCard(0x11f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的执行函数：从手卡、卡组、墓地选择1只「奈芙提斯」怪兽特殊召唤，并注册在结束阶段将其破坏的效果
function c82832464.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域空格，则不处理后续效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地（受王家长眠之谷影响）选择1只满足条件的「奈芙提斯」怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82832464.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选择的怪兽以表侧表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(82832464,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c82832464.descon)
		e1:SetOperation(c82832464.desop)
		-- 注册用于在结束阶段破坏该怪兽的全局时点效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定结束阶段破坏效果的适用条件：检查目标怪兽是否仍带有对应的标记，若标记不匹配则重置该效果
function c82832464.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(82832464)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的执行函数：破坏该特殊召唤的怪兽
function c82832464.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
