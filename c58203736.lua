--潜海奇襲Ⅱ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「海」使用。
-- ②：自己场上的水属性怪兽不会成为水属性以外的对方怪兽的效果的对象。
-- ③：自己·对方的战斗阶段开始时才能发动。从自己的手卡·墓地选1只有「海」的卡名记述的怪兽或者水属性通常怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在那次战斗阶段结束时破坏。
function c58203736.initial_effect(c)
	-- 注册卡片效果中记述了卡名「海」（卡号22702055）的事实
	aux.AddCodeList(c,22702055)
	-- 设置这张卡在魔法与陷阱区域、墓地存在时，卡名当作「海」使用
	aux.EnableChangeCode(c,22702055,LOCATION_SZONE+LOCATION_GRAVE)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- ②：自己场上的水属性怪兽不会成为水属性以外的对方怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c58203736.eftg)
	e1:SetValue(c58203736.efilter)
	c:RegisterEffect(e1)
	-- ③：自己·对方的战斗阶段开始时才能发动。从自己的手卡·墓地选1只有「海」的卡名记述的怪兽或者水属性通常怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽在那次战斗阶段结束时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58203736,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,58203736)
	e2:SetTarget(c58203736.sptg)
	e2:SetOperation(c58203736.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的水属性怪兽作为不能成为效果对象的目标
function c58203736.eftg(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤出水属性以外的对方怪兽的效果
function c58203736.efilter(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsControler(1-e:GetHandlerPlayer()) and rc:IsNonAttribute(ATTRIBUTE_WATER)
end
-- 过滤手卡·墓地中可以守备表示特殊召唤的、记述了「海」卡名的怪兽或水属性通常怪兽
function c58203736.spfilter(c,e,tp)
	-- 检查卡片是否记述了「海」的卡名，或者是水属性通常怪兽
	return (aux.IsCodeListed(c,22702055) or (c:IsType(TYPE_NORMAL) and c:IsAttribute(ATTRIBUTE_WATER)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c58203736.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动检测时，检查自己的手卡或墓地是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c58203736.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置在效果处理时将从手卡或墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤效果的具体处理函数，包含特殊召唤及注册结束阶段破坏的延迟效果
function c58203736.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择1只满足条件的怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58203736.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若成功将选中的怪兽以表侧守备表示特殊召唤
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(58203736,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		-- 这个效果特殊召唤的怪兽在那次战斗阶段结束时破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c58203736.descon)
		e1:SetOperation(c58203736.desop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在战斗阶段结束时触发的延迟破坏效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查需要破坏的怪兽是否仍带有对应的标记，以确定是否执行破坏
function c58203736.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(58203736)==e:GetLabel()
end
-- 执行破坏操作的函数
function c58203736.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将该怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
