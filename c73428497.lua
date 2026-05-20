--ギアギアーセナル
-- 效果：
-- 这张卡的攻击力上升自己场上的名字带有「齿轮齿轮」的怪兽数量×200的数值。此外，可以把这张卡解放，从卡组把「齿轮齿轮武库人」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。
function c73428497.initial_effect(c)
	-- 这张卡的攻击力上升自己场上的名字带有「齿轮齿轮」的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c73428497.atkval)
	c:RegisterEffect(e1)
	-- 此外，可以把这张卡解放，从卡组把「齿轮齿轮武库人」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73428497,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c73428497.spcost)
	e2:SetTarget(c73428497.sptg)
	e2:SetOperation(c73428497.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的名字带有「齿轮齿轮」的怪兽
function c73428497.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x72)
end
-- 计算攻击力上升数值的函数
function c73428497.atkval(e,c)
	-- 返回自己场上表侧表示的「齿轮齿轮」怪兽数量乘以200的数值
	return Duel.GetMatchingGroupCount(c73428497.atkfilter,c:GetControler(),LOCATION_MZONE,0,nil)*200
end
-- 特殊召唤效果的Cost（发动代价）函数，检查并执行解放自身
function c73428497.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中「齿轮齿轮武库人」以外的、可以表侧守备表示特殊召唤的「齿轮齿轮」怪兽
function c73428497.filter(c,e,tp)
	return c:IsSetCard(0x72) and not c:IsCode(73428497) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的Target（效果目标）函数，检查怪兽区域空格及卡组中是否存在可召唤的怪兽
function c73428497.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，由于自身作为Cost会被解放，因此怪兽区域可用空格数只需大于-1即可（即解放后会空出一个格子）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 并且卡组中存在至少1只满足过滤条件的「齿轮齿轮」怪兽
		and Duel.IsExistingMatchingCard(c73428497.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果的Operation（效果处理）函数，从卡组选择并特殊召唤怪兽
function c73428497.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有可用空格，若无则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足过滤条件的「齿轮齿轮」怪兽
	local g=Duel.SelectMatchingCard(tp,c73428497.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
