--六武式真伝天魔六段衝
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「六武众」同调怪兽3种类以上存在的场合才能发动（为这张卡发动而需要的怪兽种类改成自己场上的武士道指示物每有6个则少要1种类的数量）。对方场上的卡全部破坏。
-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。从卡组·额外卡组把1只「六武众」怪兽或「紫炎」效果怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- ①：自己场上有「六武众」同调怪兽3种类以上存在的场合才能发动（为这张卡发动而需要的怪兽种类改成自己场上的武士道指示物每有6个则少要1种类的数量）。对方场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被对方的所发动的效果所破坏的场合或者所除外的场合才能发动。从卡组·额外卡组把1只「六武众」怪兽或「紫炎」效果怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x3]=true,
}
-- 发动条件过滤：场上表侧表示的「六武众」同调怪兽
function s.cfilter(c)
	return c:IsSetCard(0x103d) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
-- 发动条件检查：计算所需怪兽种类数并判断场上卡名数量
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的武士道指示物数量
	local ct=Duel.GetCounter(tp,1,0,0x3)
	local rt=3-math.floor(ct/6)
	if rt<=0 then return true end
	-- 获取自己场上满足条件的「六武众」同调怪兽组
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil)
	return g:GetCount()>0 and g:GetClassCount(Card.GetCode)>=rt
end
-- 效果发动准备与目标确认
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：对方场上存在卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息：破坏对方场上的所有卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 破坏效果处理：破坏对方场上的所有卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 将选中的卡全部破坏
	Duel.Destroy(sg,REASON_EFFECT)
end
-- 特殊召唤效果发动条件检查：盖放的这张卡被对方发动的效果破坏或除外
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and re and re:IsActivated()
end
-- 特殊召唤过滤条件：「六武众」怪兽或「紫炎」效果怪兽
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x103d) or c:IsSetCard(0x20) and c:IsType(TYPE_EFFECT))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断从卡组特殊召唤时怪兽区是否有空位
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 判断从额外卡组特殊召唤时是否有可用位置
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 特殊召唤效果发动准备与目标确认
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组或额外卡组存在可特殊召唤的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息：从卡组或额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- 特殊召唤效果处理：选择并特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
