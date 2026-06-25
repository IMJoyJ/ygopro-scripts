--デーモンの根源
local s,id,o=GetID()
-- 注册卡片效果的初始化函数（在手牌将自身以外的1只「恶魔」怪兽解放来特殊召唤，在召唤·特殊召唤成功时特殊召唤1只攻击力2500的6星恶魔族怪兽，以及场上有「恶魔的召唤」存在时无效并破坏对方发动的怪兽效果）
function s.initial_effect(c)
	-- 记录该卡片记有卡名「恶魔的召唤」（卡号：70781052）的事实
	aux.AddCodeList(c,70781052)
	-- 这张卡在手牌存在的场合，将此卡以外我方手牌·场上的1只「恶魔」怪兽解放可以发动。将此卡特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 此卡召唤·特殊召唤成功的场合可以发动。从我方手牌·卡组·墓地将1只攻击力2500的6星恶魔族怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 我方场上有「恶魔的召唤」存在的场合，对方发动怪兽效果时可以发动。将该发动无效并破坏
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.negcon)
	e4:SetTarget(s.negtg)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 过滤手牌或场上属于「恶魔」系列怪兽，且解放后能空出怪兽区域的过滤函数
function s.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x45)
		-- 并且该怪兽解放后可以使当前玩家的可召唤区域数量大于0
		and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①特殊召唤效果的发动代价函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在chk==0时，检查当前玩家手牌或场上是否存在满足解放条件的「恶魔」怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,c,tp) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 让玩家在手牌或场上选择1只满足解放条件的「恶魔」怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,c,tp)
	-- 将被选择的怪兽作为代价解放
	Duel.Release(g,REASON_COST)
end
-- 效果①特殊召唤效果的发动准备与检查函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理的分类为特殊召唤，数量为1，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①特殊召唤效果的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手牌、卡组或墓地中攻击力为2500、种族为恶魔族且等级为6，并可以特殊召唤的怪兽的过滤函数
function s.spfilter2(c,e,tp)
	return c:IsAttack(2500) and c:IsRace(RACE_FIEND) and c:IsLevel(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②特殊召唤效果的发动准备与检查函数
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时，检查自己场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌、卡组或墓地是否存在可以特殊召唤的目标怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理的分类为特殊召唤，数量为1，目标位置为手牌·卡组·墓地
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②特殊召唤效果的处理函数
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若没有可用的怪兽区域，则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家在手牌、卡组或墓地选择1只符合条件的怪兽，并过滤「王家长眠之谷」的影响
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示「恶魔的召唤」的过滤函数
function s.cfilter1(c)
	return c:IsFaceup() and c:IsCode(70781052)
end
-- 效果③无效并破坏对方怪兽效果的发动条件函数
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的怪兽效果，且该发动能被无效
	return rp~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		-- 并且检查自己场上是否存在表侧表示的「恶魔的召唤」
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果③无效并破坏效果的发动准备与检查函数
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理的分类为发动无效，目标为被连锁的效果
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理的分类为破坏，目标为被连锁的效果的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果③无效并破坏效果的处理函数
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功将该发动无效，并且对方的卡与连锁相关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 将无效了发动的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
