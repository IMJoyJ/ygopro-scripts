--嵐忌竜デストゥビム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 对方不能把这张卡作为效果的对象。
-- 「岚祸龙 迪斯托宾」的以下效果1回合各能使用1次。
-- 可以从自己墓地把不能通常召唤的暗属性怪兽任意数量除外；把那个数量的对方场上的卡除外。对方场上的卡比自己场上多的场合，这个效果在对方回合也能发动。
-- 这张卡被送去墓地的场合：可以把自己除外状态的1只龙族怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册同调召唤手续、苏生限制、取对象抗性、墓地暗属性除外及场上卡除外效果（主要/即时）、送墓特召除外龙族怪兽效果
function s.initial_effect(c)
	-- 设定同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	-- 设置抗性对象范围：仅对方的效果
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	-- 可以从自己墓地把不能通常召唤的暗属性怪兽任意数量除外；把那个数量的对方场地上的卡除外。对方场地上的卡比自己场上多的场合，这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"除外效果"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon1)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCondition(s.rmcon2)
	c:RegisterEffect(e3)
	-- 这张卡被送去墓地的场合：可以把自己除外状态的1只龙族怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 主要阶段发动条件检查：对方场上的卡数量不超过自己场上的卡数量
function s.rmcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算对方场上的卡与自己场上的卡的数量差额
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct<=0
end
-- 自由奏效（即时效果）发动条件检查：对方场上的卡数量多于自己场上的卡数量
function s.rmcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
	-- 计算对方场上的卡与自己场上的卡的数量差额
	local ct=g:GetCount()-Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)
	return ct>0
end
-- Cost过滤条件：墓地中不能通常召唤的暗属性怪兽且可作为Cost除外
function s.cfilter(c)
	return not c:IsSummonableCard() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost()
end
-- 除外效果Cost：从自己墓地把任意数量不能通常召唤的暗属性怪兽除外，并记录除外数量
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方场上可被除外的卡片总数，以此限定Cost最大可除外数量
	local ct=Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- Cost检查：墓地是否存在至少1只满足条件的不能通常召唤的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要作为Cost除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1~ct只满足条件的暗属性怪兽
	local sg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,ct,nil)
	-- 将选中的怪兽表侧表示除外作为Cost
	Duel.Remove(sg,POS_FACEUP,REASON_COST)
	e:SetLabel(sg:GetCount())
end
-- 除外效果发动准备：检查对方场上是否存在可除外卡片并设置连锁操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 发动条件检查：对方场上是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有可除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：除外对方场上等同于Cost除外数量的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,e:GetLabel(),0,0)
end
-- 除外效果处理：选择对方场上对应数量的卡表侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	-- 若对方场上可除外卡片数量不足则终止效果处理
	if Duel.GetMatchingGroupCount(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)<ct then return end
	-- 提示玩家选择要除外的目标卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择指定数量可除外的卡
	local sg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	if #sg>0 then
		-- 高亮显示选中的目标卡片
		Duel.HintSelection(sg)
		-- 将选中的卡片表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end
-- 特殊召唤过滤条件：除外状态的表侧表示龙族怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_DRAGON)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果发动准备：检查怪兽区空位与可特召的除外龙族怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区域有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：除外区是否存在满足条件的龙族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从除外区特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 特殊召唤效果处理：从除外区选1只龙族怪兽表侧表示特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 怪兽区域无空位时终止效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从除外区选择1只满足条件的龙族怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
