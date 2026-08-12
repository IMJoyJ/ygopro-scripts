--雷霆ノ魔軍神
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除，以「雷霆之魔军神」以外的自己墓地1只4星或4阶的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名直到结束阶段当作「雷霆之魔军神」使用。
local s,id,o=GetID()
-- 初始化效果函数，注册卡名代码列表、XYZ召唤手续、两个效果
function s.initial_effect(c)
	-- 记录该卡的卡号为自身卡号，用于同名卡限制
	aux.AddCodeList(c,id)
	-- 设置XYZ召唤条件为4星等级、叠放数量为2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以「雷霆之魔军神」以外的自己墓地1只4星或4阶的念动力族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的卡名直到结束阶段当作「雷霆之魔军神」使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡名变更"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.codecon)
	e2:SetTarget(s.codetg)
	e2:SetOperation(s.codeop)
	c:RegisterEffect(e2)
end
-- 效果支付代价：移除自身1个超量素材作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤墓地符合条件的怪兽（非本卡、4星或4阶、念动力族、可特殊召唤）
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and (c:IsLevel(4) or c:IsRank(4)) and c:IsRace(RACE_PSYCHO)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置①效果的目标选择函数，用于判断目标是否满足条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在符合条件的墓地怪兽作为目标
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理函数，将选中的墓地怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在连锁中且未被王家长眠之谷影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的触发条件，确保不是由自身特殊召唤触发
function s.codecon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler())
end
-- 过滤场上正面表示且非本卡的怪兽
function s.codefilter(c)
	return c:IsFaceup() and not c:IsCode(id)
end
-- 设置②效果的目标选择函数，用于判断目标是否满足条件
function s.codetg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.codefilter(chkc) and chkc~=c end
	-- 检查场上是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.codefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 选择符合条件的场上怪兽作为目标
	local g=Duel.SelectTarget(tp,s.codefilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
end
-- ②效果的处理函数，使目标怪兽在结束阶段前卡名变为雷霆之魔军神
function s.codeop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) then
		-- 创建一个使目标怪兽卡名改变的效果并注册到该怪兽上
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(id)
		tc:RegisterEffect(e1)
	end
end
