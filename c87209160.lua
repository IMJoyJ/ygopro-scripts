--鉄獣戦線 フラクトール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1只3星以下的兽族·兽战士族·鸟兽族怪兽送去墓地。
-- ②：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
function c87209160.initial_effect(c)
	-- ①：把手卡·场上的这张卡送去墓地才能发动。从卡组把1只3星以下的兽族·兽战士族·鸟兽族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87209160,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,87209160)
	e1:SetCost(c87209160.tgcost)
	e1:SetTarget(c87209160.tgtg)
	e1:SetOperation(c87209160.tgop)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87209160,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,87209161)
	e2:SetCost(c87209160.spcost)
	e2:SetTarget(c87209160.sptg)
	e2:SetOperation(c87209160.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：卡组中等级3以下的兽族·兽战士族·鸟兽族怪兽
function c87209160.tgfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLevelBelow(3) and c:IsAbleToGrave()
end
-- ①效果的发动代价：将手卡·场上的自身送去墓地
function c87209160.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为发动代价
	Duel.SendtoGrave(c,REASON_COST)
end
-- ①效果的发动准备：检查卡组中是否存在符合条件的怪兽，并设置送去墓地的操作信息
function c87209160.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c87209160.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置送去墓地的操作信息，涉及卡片数量为1，位置为卡组
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：从卡组选择1只符合条件的怪兽送去墓地
function c87209160.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c87209160.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果的发动代价处理：标记此效果需要进行除外代价的检测与处理
function c87209160.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤条件：墓地中可以作为代价除外的兽族·兽战士族·鸟兽族怪兽
function c87209160.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 子群组选择过滤：检查额外卡组中是否存在连接标记数量等于所选卡片数量的怪兽
function c87209160.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 过滤条件：额外卡组中可以特殊召唤的兽族·兽战士族·鸟兽族连接怪兽
function c87209160.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查该怪兽是否可以特殊召唤，且额外怪兽区域或连接端有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动准备：计算可除外的数量，让玩家选择并除外对应数量的怪兽作为代价，并设置特殊召唤的操作信息
function c87209160.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有符合除外条件的怪兽
	local cg=Duel.GetMatchingGroup(c87209160.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中所有符合特殊召唤条件的连接怪兽
	local tg=Duel.GetMatchingGroup(c87209160.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c87209160.fselect,1,maxlink,tg)
	end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,c87209160.fselect,false,1,maxlink,tg)
	-- 将选中的怪兽表侧表示除外作为发动代价
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置特殊召唤的操作信息，涉及卡片数量为1，位置为额外卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：额外卡组中连接标记数量等于除外数量的符合条件的连接怪兽
function c87209160.spfilter1(c,e,tp,lk)
	return c87209160.spfilter(c,e,tp) and c:IsLink(lk)
end
-- ②效果的效果处理：适用连接素材限制，并从额外卡组特殊召唤对应连接标记数量的怪兽
function c87209160.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置连接素材限制的适用对象：非兽族·兽战士族·鸟兽族的怪兽
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c87209160.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将连接素材限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只连接标记数量等于除外数量的符合条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c87209160.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的连接怪兽表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制条件：连接素材限制仅适用于自己场上的怪兽
function c87209160.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
