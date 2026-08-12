--ガーベージ・ゴーレム
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有攻击力或守备力是0的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：把阶级不同的额外卡组3只超量怪兽给对方观看，以场上1张其他卡为对象才能发动。那张卡和这张卡破坏。
-- ③：把墓地的这张卡除外才能发动。自己场上1个超量素材取除。那之后，可以从自己的手卡·墓地把1只攻击力或守备力是0的怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册3个起动效果——e1为手卡发动的特殊召唤效果（1回合1次），e2为场上发动的取对象破坏效果（1回合1次），e3为墓地发动的以除外自身为cost的取除超量素材并可特殊召唤的效果（1回合1次）
function s.initial_effect(c)
	-- ①：自己场上有攻击力或守备力是0的怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把阶级不同的额外卡组3只超量怪兽给对方观看，以场上1张其他卡为对象才能发动。那张卡和这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。自己场上1个超量素材取除。那之后，可以从自己的手卡·墓地把1只攻击力或守备力是0的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"取除素材"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 设置效果cost：把墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选攻击力或守备力是0且表侧表示的怪兽
function s.cfilter(c)
	return (c:IsAttack(0) or c:IsDefense(0)) and c:IsFaceup()
end
-- 发动条件判定：检查自己场上是否存在攻击力或守备力是0的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在至少1只满足条件（攻击力或守备力为0且表侧表示）的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时可行性检查：确认自己主要怪兽区有空位且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查：自己主要怪兽区有1个以上可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次连锁将对这张卡进行1次特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与此连锁关联，则将其从手卡特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：筛选超量怪兽
function s.cfilter2(c)
	return c:IsType(TYPE_XYZ)
end
-- cost处理：从自己额外卡组选出阶级各不相同的3只超量怪兽，给对方观看确认
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 取得自己额外卡组中所有超量怪兽的卡片组
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetRank)>2 end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从额外卡组的超量怪兽中选出3只阶级各不相同的怪兽组成子组
	local sg=g:SelectSubGroup(tp,aux.drkcheck,false,3,3)
	-- 把选出的3只超量怪兽给对方玩家观看确认
	Duel.ConfirmCards(1-tp,sg)
end
-- 对象与发动可行性检查：对象须为这张卡以外的场上的卡；chk==0时确认这张卡可以被破坏且场上存在这张卡以外可作为对象的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return c:IsDestructable()
		-- 检查双方场上是否存在至少1张这张卡以外可以成为效果对象的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择双方场上1张这张卡以外的卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	g:AddCard(c)
	-- 设置操作信息：声明本次连锁将破坏对象卡和这张卡共2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：若这张卡和对象卡都仍与连锁关联且对象卡在场上，则将这两张卡一起破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsOnField() then
		local g=Group.FromCards(c,tc)
		-- 以效果破坏为由，将这张卡和对象卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤函数：筛选攻击力或守备力是0且可以被特殊召唤的怪兽
function s.spfilter(c,e,tp)
	return (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时可行性检查：确认自己可以以效果为由取除1个超量素材
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时检查：自己场上的超量怪兽至少有1个可以取除的超量素材
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- 效果处理：取除自己场上1个超量素材；若成功取除且主要怪兽区有空位、手卡·墓地存在可特殊召唤的攻击力或守备力为0的怪兽且玩家选择是，则选1只将其特殊召唤
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果为由取除自己场上1个超量素材，并确认取除成功
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0
		-- 确认自己主要怪兽区还有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1只不受「王家长眠之谷」影响、攻击力或守备力是0且可以被特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否进行特殊召唤，选择是则继续处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否特殊召唤？"
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己的手卡·墓地选择1只不受「王家长眠之谷」影响、攻击力或守备力是0且可特殊召唤的怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 把选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
