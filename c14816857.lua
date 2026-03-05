--鉄獣戦線 ナーベル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 纳贝尔」以外的1只「铁兽」怪兽加入手卡。
function c14816857.initial_effect(c)
	-- ①：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14816857,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,14816857)
	e1:SetCost(c14816857.spcost)
	e1:SetTarget(c14816857.sptg)
	e1:SetOperation(c14816857.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 纳贝尔」以外的1只「铁兽」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14816857,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,14816858)
	e2:SetTarget(c14816857.thtg)
	e2:SetOperation(c14816857.thop)
	c:RegisterEffect(e2)
end
-- 设置效果cost为spcost函数
function c14816857.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选墓地中的兽族·兽战士族·鸟兽族怪兽
function c14816857.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 判断是否满足特殊召唤条件
function c14816857.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 判断额外卡组中是否满足特殊召唤条件的连接怪兽
function c14816857.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查是否有足够的特殊召唤位置
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置效果target为sptg函数
function c14816857.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家墓地中的兽族·兽战士族·鸟兽族怪兽
	local cg=Duel.GetMatchingGroup(c14816857.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取玩家额外卡组中满足条件的连接怪兽
	local tg=Duel.GetMatchingGroup(c14816857.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c14816857.fselect,1,maxlink,tg)
	end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=cg:SelectSubGroup(tp,c14816857.fselect,false,1,maxlink,tg)
	-- 将选择的怪兽除外作为cost
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 筛选满足特殊召唤条件且连接数等于指定值的怪兽
function c14816857.spfilter1(c,e,tp,lk)
	return c14816857.spfilter(c,e,tp) and c:IsLink(lk)
end
-- 设置效果operation为spop函数
function c14816857.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个影响场上所有非兽族·兽战士族·鸟兽族怪兽不能作为连接素材的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置该效果的目标为非兽族·兽战士族·鸟兽族怪兽
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c14816857.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 提示玩家选择要特殊召唤的连接怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c14816857.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的连接怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置限制函数sumlimit
function c14816857.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 筛选卡组中除纳贝尔外的铁兽怪兽
function c14816857.thfilter(c)
	return c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) and not c:IsCode(14816857) and c:IsAbleToHand()
end
-- 设置效果target为thtg函数
function c14816857.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c14816857.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果operation为thop函数
function c14816857.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14816857.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
