--夜薔薇の黒騎士
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1只「黑蔷薇龙」或者4星以下的植物族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：只要自己场上有同调怪兽存在，自己场上的植物族怪兽的攻击力上升1000。
-- ③：以自己场上1只其他的植物族怪兽为对象才能发动。那只怪兽的等级上升或下降1星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①召唤·特殊召唤成功时特召墓地怪兽、②场上有同调怪兽时植物族怪兽攻击力上升、③改变场上其他植物族怪兽等级的效果。
function s.initial_effect(c)
	-- 将「黑蔷薇龙」（卡号73580471）加入该卡的效果关联卡片列表中。
	aux.AddCodeList(c,73580471)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己墓地把1只「黑蔷薇龙」或者4星以下的植物族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要自己场上有同调怪兽存在，自己场上的植物族怪兽的攻击力上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.atkcon)
	-- 设置永续效果的影响对象为植物族怪兽。
	e3:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- ③：以自己场上1只其他的植物族怪兽为对象才能发动。那只怪兽的等级上升或下降1星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"改变等级"
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
-- 过滤墓地中可特殊召唤的「黑蔷薇龙」或4星以下植物族怪兽的条件函数。
function s.spfilter(c,e,tp)
	return (c:IsCode(73580471) or c:IsRace(RACE_PLANT) and c:IsLevelBelow(4)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①（特殊召唤）的发动准备与合法性检测函数。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤怪兽的空余怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足特召条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息，表明此效果会从墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①（特殊召唤并无效化）的效果处理函数。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前自己场上是否有空余的怪兽区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给玩家发送提示信息，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己墓地选择1只满足特召条件且不受「王家长眠之谷」影响的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 如果成功选出怪兽，则尝试将其以表侧表示特殊召唤到场上（分步处理）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤的后续处理，使怪兽正式登场。
		Duel.SpecialSummonComplete()
	end
end
-- 效果②（攻击力上升）的条件判断函数，检查场上是否存在同调怪兽。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandlerPlayer()
	-- 检查自己场上是否存在表侧表示的同调怪兽。
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsType),p,LOCATION_MZONE,0,1,nil,TYPE_SYNCHRO)
end
-- 过滤场上表侧表示、等级在1以上且为植物族的怪兽的条件函数。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsRace(RACE_PLANT)
end
-- 效果③（改变等级）的发动准备、对象选择与合法性检测函数。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc~=c and s.lvfilter(chkc) end
	-- 检查自己场上是否存在除自身以外、满足等级改变条件的植物族怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,c) end
	-- 给玩家发送提示信息，要求选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择自己场上1只其他的植物族怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,c)
end
-- 效果③（改变等级）的效果处理函数。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果发动的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() then
		local op=0
		if tc:IsLevel(1) then op=1
		-- 如果对象怪兽的等级大于1，则让玩家选择等级上升1星或下降1星。
		else op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,2),1},  --"等级上升"
			{true,aux.Stringid(id,3),-1})  --"等级下降"
		end
		-- 那只怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(op)
		tc:RegisterEffect(e1)
	end
end
