--アルカナ トライアンフジョーカー
-- 效果：
-- ①：这张卡在手卡·墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把「王后骑士」「卫兵骑士」「国王骑士」各1只送去墓地才能发动。这张卡特殊召唤。
-- ②：这张卡的攻击力上升双方手卡数量×500。
-- ③：丢弃1张手卡才能发动。和丢弃的卡相同种类（怪兽·魔法·陷阱）的对方场上的表侧表示的卡全部破坏。
function c93880808.initial_effect(c)
	-- 在卡片中记录其效果文本中记有「王后骑士」、「卫兵骑士」、「国王骑士」的卡名
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：这张卡在手卡·墓地存在的场合，从手卡以及自己场上的表侧表示怪兽之中把「王后骑士」「卫兵骑士」「国王骑士」各1只送去墓地才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93880808,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCost(c93880808.spcost)
	e1:SetTarget(c93880808.sptg)
	e1:SetOperation(c93880808.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升双方手卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c93880808.atkval)
	c:RegisterEffect(e2)
	-- ③：丢弃1张手卡才能发动。和丢弃的卡相同种类（怪兽·魔法·陷阱）的对方场上的表侧表示的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93880808,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c93880808.descost)
	e3:SetTarget(c93880808.destg)
	e3:SetOperation(c93880808.desop)
	c:RegisterEffect(e3)
end
-- 创建用于依次检查是否包含「王后骑士」、「卫兵骑士」、「国王骑士」各1张的条件检查函数数组
c93880808.tgchecks=aux.CreateChecks(Card.IsCode,{25652259,64788463,90876561})
-- 过滤手卡或场上表侧表示的「王后骑士」、「卫兵骑士」、「国王骑士」且能作为代价送去墓地的卡片
function c93880808.cfilter(c)
	return c:IsCode(25652259,64788463,90876561) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤效果的代价（Cost）处理函数
function c93880808.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡及自己场上表侧表示的、满足条件的「王后骑士」、「卫兵骑士」、「国王骑士」卡片组
	local g=Duel.GetMatchingGroup(c93880808.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil)
	-- 在发动阶段，检查是否能从上述卡片组中选出各1张送去墓地，且送去墓地后能腾出足够的怪兽区域空位
	if chk==0 then return g:CheckSubGroupEach(c93880808.tgchecks,aux.mzctcheck,tp) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择「王后骑士」、「卫兵骑士」、「国王骑士」各1只，并确保满足怪兽区域空位要求
	local sg=g:SelectSubGroupEach(tp,c93880808.tgchecks,false,aux.mzctcheck,tp)
	-- 将选中的卡片作为发动代价送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- 特殊召唤效果的目标（Target）处理函数
function c93880808.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的效果处理（Operation）函数
function c93880808.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 攻击力上升数值的计算函数
function c93880808.atkval(e,c)
	-- 返回双方手卡总数乘以500的数值
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,LOCATION_HAND)*500
end
-- 过滤可以作为丢弃代价的手卡，且对方场上存在与之相同种类（怪兽/魔法/陷阱）的表侧表示卡片
function c93880808.descostfilter(c,tp)
	local type=bit.band(c:GetType(),0x7)
	-- 检查卡片是否可以丢弃，且对方场上是否存在至少1张相同种类的表侧表示卡片
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c93880808.desfilter,tp,0,LOCATION_ONFIELD,1,nil,type)
end
-- 过滤对方场上与丢弃卡片相同种类（怪兽/魔法/陷阱）的表侧表示卡片
function c93880808.desfilter(c,type)
	return c:IsType(type) and c:IsFaceup()
end
-- 破坏效果的代价（Cost）处理函数
function c93880808.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		-- 检查手卡中是否存在可作为代价丢弃且能触发破坏效果的卡
		return Duel.IsExistingMatchingCard(c93880808.descostfilter,tp,LOCATION_HAND,0,1,nil,tp)
	end
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择1张满足条件的手卡作为丢弃对象
	local cost=Duel.SelectMatchingCard(tp,c93880808.descostfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	e:SetLabel(bit.band(cost:GetType(),0x7))
	-- 将选中的手卡作为发动代价丢弃送去墓地
	Duel.SendtoGrave(cost,REASON_COST+REASON_DISCARD)
end
-- 破坏效果的目标（Target）处理函数
function c93880808.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return true
	end
	local type=e:GetLabel()
	-- 获取对方场上与丢弃卡片相同种类的所有表侧表示卡片
	local g=Duel.GetMatchingGroup(c93880808.desfilter,tp,0,LOCATION_ONFIELD,nil,type)
	-- 设置连锁信息，表明此效果包含破坏对方场上这些卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 破坏效果的效果处理（Operation）函数
function c93880808.desop(e,tp,eg,ep,ev,re,r,rp)
	local type=e:GetLabel()
	-- 重新获取对方场上与丢弃卡片相同种类的所有表侧表示卡片
	local g=Duel.GetMatchingGroup(c93880808.desfilter,tp,0,LOCATION_ONFIELD,nil,type)
	-- 若存在满足条件的卡，则将这些卡全部破坏
	if #g>0 then Duel.Destroy(g,REASON_EFFECT) end
end
