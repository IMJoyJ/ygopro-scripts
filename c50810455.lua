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
-- 筛选手卡中可作为①效果丢弃代价的怪兽：种族必须为兽族、兽战士族或鸟兽族，且可以被丢弃。
function c50810455.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsDiscardable()
end
-- ①效果的代价处理：确认手卡存在满足条件的其他怪兽后，丢弃1只符合条件的怪兽作为发动代价。
function c50810455.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检测：手卡中是否存在1只满足条件的其他兽族·兽战士族·鸟兽族怪兽（不包含这张卡自身）。
	if chk==0 then return Duel.IsExistingMatchingCard(c50810455.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际执行代价：从手卡丢弃1只满足条件的怪兽，丢弃原因标记为代价与丢弃。
	Duel.DiscardHand(tp,c50810455.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①效果发动条件检测：自己主要怪兽区存在空格，且这张卡能够被特殊召唤。
function c50810455.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记特殊召唤的操作信息，表明本效果将对这张卡进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其从手卡特殊召唤到自己场上。
function c50810455.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的代价预处理：仅设置标记为100并返回true，真正的除外选择将在Target阶段进行。
function c50810455.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选墓地中可作为②效果除外代价的怪兽：种族必须为兽族、兽战士族或鸟兽族，且可以作为代价被除外。
function c50810455.cfilter1(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 检查一组墓地怪兽的数量是否能找到一只连接标记数相同的符合条件的额外连接怪兽。
function c50810455.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 筛选额外卡组中可被②效果特殊召唤的怪兽：必须是连接怪兽、种族为兽族·兽战士族·鸟兽族、能够被特殊召唤，并且有可供额外卡组怪兽出场的空格。
function c50810455.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 进一步确认该连接怪兽可以被特殊召唤，且额外卡组怪兽有可用的特殊召唤区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的目标处理：取得墓地可除外怪兽与额外可特殊召唤连接怪兽，检查可从墓地选择1只至最大LINK值数量的怪兽且对应LINK值的额外怪兽存在；随后让玩家选择并除外墓地怪兽，记录数量，并登记特殊召唤操作信息。
function c50810455.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得自己墓地中满足除外代价条件的兽族·兽战士族·鸟兽族怪兽集合。
	local cg=Duel.GetMatchingGroup(c50810455.cfilter1,tp,LOCATION_GRAVE,0,nil)
	-- 取得额外卡组中满足特殊召唤条件的兽族·兽战士族·鸟兽族连接怪兽集合。
	local tg=Duel.GetMatchingGroup(c50810455.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c50810455.fselect,1,maxlink,tg)
	end
	-- 弹出选择提示，要求玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,c50810455.fselect,false,1,maxlink,tg)
	-- 将玩家选中的墓地怪兽以表侧表示除外，作为②效果的发动代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 登记操作信息：本次处理将特殊召唤额外卡组的1只怪兽，目标暂不确定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 在额外卡组中筛选连接标记数等于除外数量的符合条件的连接怪兽。
function c50810455.spfilter1(c,e,tp,lk)
	return c50810455.spfilter(c,e,tp) and c:IsLink(lk)
end
-- ②效果处理：先附加本回合‘自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材’的限制，然后特殊召唤1只LINK值等于除外数量的符合条件的连接怪兽。
function c50810455.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置限制效果的对象条件：只有不是兽族、兽战士族、鸟兽族的怪兽才会被该效果限制为不能作为连接素材。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c50810455.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘非兽族·兽战士族·鸟兽族怪兽不能作为连接素材’的限制效果注册到场上，持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 弹出选择提示，要求玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只LINK值等于已除外数量的符合条件的连接怪兽。
	local g=Duel.SelectMatchingCard(tp,c50810455.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的连接怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 自肃效果的值函数：对于尝试作为连接素材的怪兽，如果其控制者是效果持有者（自己），则禁止作为连接素材；否则不受限制。
function c50810455.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
