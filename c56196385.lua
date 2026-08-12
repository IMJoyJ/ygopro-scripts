--鉄獣戦線 キット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 姬特」以外的1张「铁兽」卡送去墓地。
function c56196385.initial_effect(c)
	-- ①：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56196385,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,56196385)
	e1:SetCost(c56196385.spcost)
	e1:SetTarget(c56196385.sptg)
	e1:SetOperation(c56196385.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 姬特」以外的1张「铁兽」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56196385,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,56196386)
	e2:SetTarget(c56196385.tgtg)
	e2:SetOperation(c56196385.tgop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价（Cost）处理函数，将标签设为100以在target中确认是否为发动时支付代价
function c56196385.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤自己墓地中可以作为Cost除外的兽族、兽战士族或鸟兽族怪兽
function c56196385.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 检查除外的怪兽数量是否与额外卡组中某只怪兽的连接标记数量相同
function c56196385.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 过滤额外卡组中可以特殊召唤的兽族、兽战士族或鸟兽族连接怪兽
function c56196385.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 检查怪兽是否可以特殊召唤，且额外卡组怪兽出场的可用区域数量大于0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果的发动准备（Target）处理函数，确认是否有可除外的怪兽和可特召的怪兽，并进行除外Cost的处理
function c56196385.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中满足除外条件的兽族、兽战士族、鸟兽族怪兽组
	local cg=Duel.GetMatchingGroup(c56196385.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中满足特召条件的兽族、兽战士族、鸟兽族连接怪兽组
	local tg=Duel.GetMatchingGroup(c56196385.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c56196385.fselect,1,maxlink,tg)
	end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,c56196385.fselect,false,1,maxlink,tg)
	-- 将选中的怪兽作为发动代价（Cost）表侧表示除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置连锁信息，表示该效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤额外卡组中连接标记数量等于除外数量的兽族、兽战士族、鸟兽族连接怪兽
function c56196385.spfilter1(c,e,tp,lk)
	return c56196385.spfilter(c,e,tp) and c:IsLink(lk)
end
-- ①效果的效果处理（Operation）函数，适用连接素材限制并特殊召唤额外卡组的连接怪兽
function c56196385.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 姬特」以外的1张「铁兽」卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置不能作为连接素材的怪兽对象为非兽族、非兽战士族、非鸟兽族的怪兽
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c56196385.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该连接素材限制效果
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只连接标记数量等于除外数量的兽族、兽战士族、鸟兽族连接怪兽
	local g=Duel.SelectMatchingCard(tp,c56196385.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的连接怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 限制效果仅适用于自己场上的怪兽
function c56196385.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 过滤卡组中「铁兽战线 姬特」以外的「铁兽」卡
function c56196385.tgfilter(c)
	return c:IsSetCard(0x14d) and not c:IsCode(56196385) and c:IsAbleToGrave()
end
-- ②效果的发动准备（Target）处理函数，确认卡组中是否存在可送去墓地的「铁兽」卡
function c56196385.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在可送去墓地的「铁兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c56196385.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果的效果处理（Operation）函数，从卡组选择1张「铁兽」卡送去墓地
function c56196385.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张「铁兽战线 姬特」以外的「铁兽」卡
	local g=Duel.SelectMatchingCard(tp,c56196385.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
