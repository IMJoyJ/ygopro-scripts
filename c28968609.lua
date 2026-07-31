--ガーベージ・ゴーレム
local s,id,o=GetID()
-- 创建并注册该卡的三种效果：①从手卡特殊召唤，②破坏场上的卡，③从墓地特殊召唤
function s.initial_effect(c)
	-- 自分フィールド上に攻撃力0または守備力0のモンスターが存在する場合、手札からこのカードを特殊召喚できる。1ターンに1回発動可能。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 1ターンに1回、主要フェイズ時に発動できる。EXデッキから階級が異なる超量モンスター3体を選択して相手に見せ、相手フィールド上のカード1枚を選択して破壊する。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- このカードが墓地にある場合、1ターンに1回、自分のメインフェイズ開始時に発動できる。自分は自分の場上の超量素材1つを取り除き、手札・墓地から攻撃力0または守備力0のモンスター1体を選択して特殊召喚する。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 设置第三效果的cost为将自身除外（作为cost）
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤函数：返回场上攻击力0或守备力0的表侧表示怪兽
function s.cfilter(c)
	return (c:IsAttack(0) or c:IsDefense(0)) and c:IsFaceup()
end
-- 第一效果的发动条件：自己场上有攻击力0或守备力0的表侧怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场地上是否存在攻击力0或守备力0的表侧怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置第一效果的特召目标，检测是否有空位且自身可以被特召
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家tp的主要怪兽区是否有可用位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特召的操作信息，宣布将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤，将此卡以表侧攻击表示特殊召唤到场
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 特殊召唤此卡到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：返回是否为超量（XYZ）怪兽
function s.cfilter2(c)
	return c:IsType(TYPE_XYZ)
end
-- 设置第二效果的cost：选择额外卡组中3只阶级不同的超量怪兽给对方确认
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取额外卡组中所有超量怪兽
	local g=Duel.GetMatchingGroup(s.cfilter2,tp,LOCATION_EXTRA,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetRank)>2 end
	-- 提示玩家选择要确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择3只阶级不同的超量怪兽
	local sg=g:SelectSubGroup(tp,aux.drkcheck,false,3,3)
	-- 向对手展示所选的卡
	Duel.ConfirmCards(1-tp,sg)
end
-- 设置第二效果的目标，检测自己可破坏且场上有其他可破坏的卡
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc~=c end
	if chk==0 then return c:IsDestructable()
		-- 检查是否存在可破坏的卡作为对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张要破坏的卡
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	g:AddCard(c)
	-- 设置破坏操作信息，宣布将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果，破坏己方选择的卡和自身
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取之前选择的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsOnField() then
		local g=Group.FromCards(c,tc)
		-- 以效果原因破坏卡组
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 过滤函数：返回攻击力0或守备力0且可以被特召的怪兽
function s.spfilter(c,e,tp)
	return (c:IsAttack(0) or c:IsDefense(0)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置第三效果的目标，检测是否可以移除1个超量素材
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否有至少1个超量素材可以移除
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- 执行第三效果：移除1个超量素材，若满足条件则特殊召唤手牌或墓地的0攻/守怪兽
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除1个超量素材
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0
		-- 检查主要怪兽区是否有可用位置
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或墓地是否有攻击力0或守备力0的怪兽可特召（不受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
		-- 询问玩家是否发动特召效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择手牌或墓地中要特召的0攻/守怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		-- 特殊召唤所选怪兽到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
