--征覇竜－ブレイズ
-- 效果：
-- 7星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上1张卡和对方场上1张卡破坏。
-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到额外卡组。
local s,id,o=GetID()
-- 初始化效果，添加XYZ召唤手续并启用复活限制，注册两个起动效果
function s.initial_effect(c)
	-- 为该卡添加等级为7、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,7,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。自己的手卡·场上1张卡和对方场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把2只龙族或炎属性的怪兽从自己的手卡·墓地除外才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合回到额外卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果Cost，检查并移除1个超量素材作为代价
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果Target，判断是否满足破坏条件（自己场上有卡且对方场上有卡）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己手牌或场上的卡是否存在
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil)
		-- 判断对方场上的卡是否存在
		and Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取己方手牌组
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if hg:GetCount()==0 then
		-- 获取己方场上的卡组
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息，指定将要破坏的2张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	else
		-- 获取对方场上的卡组
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		-- 设置连锁操作信息，指定将要破坏的1张卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果Operation，选择并破坏己方手牌或场上1张卡和对方场上1张卡
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方手牌或场上是否有卡、对方场上是否有卡
	if Duel.GetFieldGroupCount(tp,LOCATION_HAND+LOCATION_ONFIELD,0)>0 and Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 then
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择己方手牌或场上的1张卡
		local g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡
		local g2=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		g1:Merge(g2)
		-- 显示所选卡被选为对象的动画效果
		Duel.HintSelection(g1)
		-- 将所选卡破坏
		Duel.Destroy(g1,REASON_EFFECT)
	end
end
-- 过滤函数，判断是否为龙族或炎属性且可作为除外代价的怪兽
function s.rfilter(c)
	return (c:IsRace(RACE_DRAGON) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤Cost，选择并除外2只符合条件的怪兽作为代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方手牌或墓地是否存在至少2只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,e:GetHandler()) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择2只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,e:GetHandler())
	-- 将所选怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 特殊召唤Target，判断是否可以特殊召唤此卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方场上是否有空位且此卡可被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤Operation，将此卡从墓地特殊召唤并注册离开场时返回额外卡组的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与效果相关且己方场上是否有空位
	if not c:IsRelateToEffect(e) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 特殊召唤后注册效果，使该卡从场上离开时回到额外卡组
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_DECK)
		c:RegisterEffect(e1,true)
	end
end
