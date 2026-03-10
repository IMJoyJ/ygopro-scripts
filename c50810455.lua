--鉄獣戦線 ケラス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把1只其他的兽族·兽战士族·鸟兽族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
function c50810455.initial_effect(c)
	-- ①：从手卡把1只其他的兽族·兽战士族·鸟兽族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50810455,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,50810455)
	e1:SetCost(c50810455.spcost)
	e1:SetTarget(c50810455.sptg)
	e1:SetOperation(c50810455.spop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(50810455,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,50810456)
	e2:SetCost(c50810455.spcost1)
	e2:SetTarget(c50810455.sptg1)
	e2:SetOperation(c50810455.spop1)
	c:RegisterEffect(e2)
end
-- 筛选手牌中满足种族为兽族、兽战士族或鸟兽族且可丢弃的怪兽
function c50810455.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsDiscardable()
end
-- 检查是否有满足条件的手牌并进行丢弃操作
function c50810455.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的手牌
	if chk==0 then return Duel.IsExistingMatchingCard(c50810455.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 执行丢弃1张符合条件的手牌的操作
	Duel.DiscardHand(tp,c50810455.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 判断是否可以将此卡特殊召唤
function c50810455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c50810455.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置标记用于识别是否已支付代价
function c50810455.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选墓地中满足种族为兽族、兽战士族或鸟兽族且可除外的怪兽
function c50810455.cfilter1(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 判断所选怪兽数量是否能与额外卡组中的连接怪兽匹配
function c50810455.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 筛选额外卡组中满足类型为连接、种族为兽族、兽战士族或鸟兽族且可特殊召唤的怪兽
function c50810455.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查该连接怪兽是否有足够的空位进行特殊召唤
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果目标，判断是否可以发动此效果并选择除外的怪兽
function c50810455.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取墓地中所有满足种族条件的怪兽
	local cg=Duel.GetMatchingGroup(c50810455.cfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中所有满足条件的连接怪兽
	local tg=Duel.GetMatchingGroup(c50810455.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c50810455.fselect,1,maxlink,tg)
	end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,c50810455.fselect,false,1,maxlink,tg)
	-- 将所选怪兽除外作为代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置效果处理信息，表明将要特殊召唤连接怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 筛选满足条件且连接数匹配的连接怪兽
function c50810455.spfilter1(c,e,tp,lk)
	return c50810455.spfilter(c,e,tp) and c:IsLink(lk)
end
-- 创建并注册一个永续效果，使非兽族·兽战士族·鸟兽族怪兽不能作为连接素材，并选择并特殊召唤连接怪兽
function c50810455.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册一个永续效果，使非兽族·兽战士族·鸟兽族怪兽不能作为连接素材
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置该效果的目标为非兽族·兽战士族·鸟兽族的怪兽
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c50810455.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 提示玩家选择要特殊召唤的连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c50810455.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将所选连接怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该怪兽是否为己方控制
function c50810455.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
