--三幻魔の操世者
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
-- ②：丢弃1张手卡才能发动。除丢弃的卡外的1只8星以外的「三幻魔」怪兽从自己的手卡·墓地守备表示特殊召唤。
-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
local s,id,o=GetID()
-- 注册手卡特召、场上丢卡特召以及墓地除外特召「三幻魔」怪兽的效果
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。选自己1张手卡丢弃，从手卡把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES_SELF)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：丢弃1张手卡才能发动。从手卡·墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地把1只8星以外的「三幻魔」怪兽守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	-- 将墓地的此卡除外作为效果发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.sptg3)
	e3:SetOperation(s.spop3)
	c:RegisterEffect(e3)
end
-- 把手卡的此卡给对方观看作为效果发动的代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 可丢弃的手卡过滤条件（需有可被特殊召唤的「三幻魔」怪兽存在）
function s.hfilter(c,e,tp)
	return c:IsDiscardable(REASON_EFFECT+REASON_DISCARD)
		-- 检查自己手卡中是否存在满足条件的「三幻魔」怪兽以供特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
-- 可特殊召唤的8星以外「三幻魔」怪兽的过滤条件
function s.spfilter(c,e,tp)
	if not c:IsSetCard(0x1144) or c:IsLevel(8) then return false end
	-- 获取怪兽是否可守备表示特殊召唤的合法性条件
	return c:IsCanBeSpecialSummoned(e,0,tp,false,aux.PhantasmsSpSummonType(c),POS_FACEUP_DEFENSE)
end
-- 特殊召唤「三幻魔」怪兽的具体处理函数
function s.spsummon(c,tp)
	-- 获取该「三幻魔」怪兽所特有的特殊召唤类型标记
	local flag=aux.PhantasmsSpSummonType(c)
	-- 特殊召唤成功后，若有特殊召唤类型，则完成其正规召唤程序
	if Duel.SpecialSummon(c,0,tp,tp,false,flag,POS_FACEUP_DEFENSE)>0 and flag then
		c:CompleteProcedure()
	end
end
-- 手卡特殊召唤效果的发动准备
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在可执行丢弃以及特召条件的卡片
		and Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息为丢弃自己1张手卡
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,1)
end
-- 手卡特殊召唤效果的执行
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local dres=0
	-- 若自己手卡中没有满足双重过滤条件的卡片
	if not Duel.IsExistingMatchingCard(s.hfilter,tp,LOCATION_HAND,0,1,nil,e,tp) then
		-- 将手卡中任意1张卡丢弃
		dres=Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	else
		-- 选择手卡中1张符合过滤条件的卡片丢弃
		dres=Duel.DiscardHand(tp,s.hfilter,1,1,REASON_EFFECT+REASON_DISCARD,nil,e,tp)
	end
	if dres>0 then
		-- 检查自己场上是否有空闲怪兽区域
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 向玩家发送提示，请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择手卡中1只满足条件的8星以外「三幻魔」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			s.spsummon(tc,tp)
		end
	else
		-- 若丢卡数量为0，则强制选择1张手卡丢弃作为惩罚
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 丢弃手卡以从手卡或墓地特殊召唤怪兽的过滤条件
function s.hfilter2(c,e,tp)
	return c:IsDiscardable()
		-- 检查手卡和墓地是否存在满足特殊召唤条件的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c,e,tp)
end
-- 丢弃1张手卡作为效果②的发动代价
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃且能满足后续特召条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.hfilter2,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 选择手卡中1张卡丢弃
	Duel.DiscardHand(tp,s.hfilter2,1,1,REASON_COST+REASON_DISCARD,nil,e,tp)
	-- 获取被丢弃的那张卡片
	local og=Duel.GetOperatedGroup()
	-- 将作为代价丢弃的卡片设为目标卡以防自己特召该卡本身
	Duel.SetTargetCard(og)
end
-- 手卡/墓地特殊召唤效果的发动准备
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或墓地是否存在可被特殊召唤的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息为从手卡或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 手卡/墓地特殊召唤效果的执行
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取在代价阶段被丢弃的目标卡片
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then tc=nil end
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择手卡或墓地中1只满足条件的「三幻魔」怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,tc,e,tp)
	local sc=g:GetFirst()
	if sc then
		s.spsummon(sc,tp)
	end
end
-- 墓地特殊召唤效果的发动准备
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空闲的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在除自身外满足特召条件的「三幻魔」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 设置操作信息为从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地特殊召唤效果的执行
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已无空怪兽区域，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地中1只满足条件的「三幻魔」怪兽特殊召唤
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		s.spsummon(tc,tp)
	end
end
