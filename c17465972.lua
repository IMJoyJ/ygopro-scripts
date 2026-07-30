--BF－南風のアウステル
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：这张卡召唤成功时，以除外的1只自己的4星以下的「黑羽」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●选自己场上1只「黑翼龙」放置对方场上的卡数量的黑羽指示物。
-- ●给对方场上的表侧表示怪兽全部尽可能各放置1个楔指示物（最多1个）。
function c17465972.initial_effect(c)
	-- 将卡片9012916的代码添加到该卡片的CodeList中，用于记录这张卡上记载着另一张卡名。
	aux.AddCodeList(c,9012916)
	-- 创建效果e1，设置其类型为单次生效效果，代码为特殊召唤条件，并设置属性为不可无效化和不可复制。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e1)
	-- 创建效果e2，描述信息来自aux.Stringid(17465972,0)，类别为特殊召唤，类型为单次触发效果，代码为通常召唤成功时，属性为取对象，目标函数为c17465972.sumtg，操作函数为c17465972.sumop。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17465972,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c17465972.sumtg)
	e2:SetOperation(c17465972.sumop)
	c:RegisterEffect(e2)
	-- 创建效果e3，描述信息来自aux.Stringid(17465972,1)，类别为指示物效果，类型为起动效果，生效范围为墓地，代价函数为aux.bfgcost，目标函数为c17465972.cttg1，操作函数为c17465972.ctop1。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17465972,1))  --"「黑翼龙」放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置代价函数为aux.bfgcost，用于将这张卡除外作为效果的代价。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c17465972.cttg1)
	e3:SetOperation(c17465972.ctop1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetDescription(aux.Stringid(17465972,2))  --"对方全部怪兽放置指示物"
	e4:SetTarget(c17465972.cttg2)
	e4:SetOperation(c17465972.ctop2)
	c:RegisterEffect(e4)
end
c17465972.mentioned_counter={
	[0x10]=true,
	[0x1002]=true,
}
-- 定义过滤函数c17465972.filter，用于筛选表侧表示、星级低于4、属于0x33系列且可以特殊召唤的怪兽。
function c17465972.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 定义目标选择函数c17465972.sumtg，在检查时判断除外区域的卡片是否为当前玩家控制，并满足c17465972.filter条件。在确认时，判断是否有可作为特殊召唤目标的怪兽以及场上是否有空的怪兽区。
function c17465972.sumtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c17465972.filter(chkc,e,tp) end
	-- 如果正在进行确认(chk==0)，则检查是否存在满足过滤条件的卡片。
	if chk==0 then return Duel.IsExistingTarget(c17465972.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp)
		-- 并且确保玩家的怪兽区域有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 使用提示信息HINT_SELECTMSG，向当前玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 调用Duel.SelectTarget函数，让当前玩家从除外区选择满足c17465972.filter条件的怪兽。
	local g=Duel.SelectTarget(tp,c17465972.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置操作信息，表示这是一个特殊召唤效果，目标是选中的怪兽卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 定义操作函数c17465972.sumop，获取第一个被选择的目标卡tc，如果该卡与当前效果相关联，则将其以表侧守备表示特殊召唤到场上。
function c17465972.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取Duel.GetFirstTarget()返回的第一个目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 使用Duel.SpecialSummon函数将目标怪兽特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 定义过滤函数c17465972.ctfilter1，用于筛选表侧表示、代码为9012916且可以添加指示物的卡片。
function c17465972.ctfilter1(c,ct)
	return c:IsFaceup() and c:IsCode(9012916) and c:IsCanAddCounter(0x10,ct)
end
-- 定义目标选择函数c17465972.cttg1，获取场上怪兽数量，在检查时判断是否存在满足c17465972.ctfilter1条件的卡片。在确认时，向对方玩家显示提示信息，并设置操作信息。
function c17465972.cttg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家场上的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 如果正在进行确认(chk==0)，则检查是否存在满足c17465972.ctfilter1条件的卡片。
	if chk==0 then return ct>0 and Duel.IsExistingMatchingCard(c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,nil,ct) end
	-- 使用提示信息HINT_OPSELECTED，向对方玩家显示选择的描述信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示这是一个指示物效果，目标数量为场上怪兽的数量，指示物的类型为0x10。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,ct,0,0x10)
end
-- 定义操作函数c17465972.ctop1，获取场上怪兽数量，如果存在怪兽则选择满足c17465972.ctfilter1条件的卡片，并为其添加指示物。
function c17465972.ctop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前玩家场上的怪兽数量。
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	if ct>0 then
		-- 调用Duel.SelectMatchingCard函数，让当前玩家从场上选择满足c17465972.ctfilter1条件的卡片。
		local g=Duel.SelectMatchingCard(tp,c17465972.ctfilter1,tp,LOCATION_MZONE,0,1,1,nil,ct)
		local tc=g:GetFirst()
		if tc then
			tc:AddCounter(0x10,ct)
		end
	end
end
-- 定义过滤函数c17465972.ctfilter2，用于筛选表侧表示、没有楔形指示物且可以添加楔形指示物的怪兽。
function c17465972.ctfilter2(c)
	return c:IsFaceup() and c:GetCounter(0x1002)==0 and c:IsCanAddCounter(0x1002,1)
end
-- 定义目标选择函数c17465972.cttg2，在检查时判断是否存在满足c17465972.ctfilter2条件的卡片。在确认时，向对方玩家显示提示信息，并设置操作信息。
function c17465972.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果正在进行确认(chk==0)，则检查是否存在满足c17465972.ctfilter2条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c17465972.ctfilter2,tp,0,LOCATION_MZONE,1,nil) end
	-- 使用提示信息HINT_OPSELECTED，向对方玩家显示选择的描述信息。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示这是一个指示物效果，目标数量为1，指示物的类型为0x1002。
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1002)
end
-- 定义操作函数c17465972.ctop2，获取满足c17465972.ctfilter2条件的怪兽组，遍历该组中的每张卡片，并为其添加楔形指示物。
function c17465972.ctop2(e,tp,eg,ep,ev,re,r,rp)
	-- 使用Duel.GetMatchingGroup函数获取满足c17465972.ctfilter2条件的怪兽组。
	local g=Duel.GetMatchingGroup(c17465972.ctfilter2,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		tc:AddCounter(0x1002,1)
		tc=g:GetNext()
	end
end
