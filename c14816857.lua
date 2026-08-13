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
-- 代价函数占位：发动前将效果标签设为100作为标记，表示已通过发动准备，随后返回true允许发动，真正的除外选择在目标函数中进行。
function c14816857.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 筛选出自己墓地中满足种族为兽族·兽战士族·鸟兽族，且可以作为代价除外的怪兽。
function c14816857.cfilter(c)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsAbleToRemoveAsCost()
end
-- 子组选择判定：判断额外卡组中是否存在连接标记数量等于已选组g中卡片数量的连接怪兽，用于支持除外的“任意数量”。
function c14816857.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 筛选额外卡组中可特殊召唤的兽族·兽战士族·鸟兽族连接怪兽，同时要求有可用区域容纳从额外卡组特殊召唤的怪兽。
function c14816857.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
		-- 进一步检查该连接怪兽能否被效果特殊召唤，以及自己场上是否仍有可用的额外卡组怪兽特殊召唤区域。
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ①效果的目标处理：选取可除外的墓地怪兽和可特殊召唤的额外怪兽，确认满足条件后由玩家选择除外任意数量符合条件的怪兽，实际除外并记录数量，同时设置特殊召唤的操作信息。
function c14816857.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己墓地中所有满足除外代价条件的兽族/兽战士族/鸟兽族怪兽，作为可选除外集合。
	local cg=Duel.GetMatchingGroup(c14816857.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中所有满足特殊召唤条件的兽族/兽战士族/鸟兽族连接怪兽，作为可选特召集合。
	local tg=Duel.GetMatchingGroup(c14816857.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		if #tg==0 then return false end
		return cg:CheckSubGroup(c14816857.fselect,1,maxlink,tg)
	end
	-- 向当前玩家发出“请选择要除外的卡”的选择提示，写入选择消息缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local rg=cg:SelectSubGroup(tp,c14816857.fselect,false,1,maxlink,tg)
	-- 将玩家选择的怪兽以表侧表示除外，作为效果发动的代价。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	e:SetLabel(rg:GetCount())
	-- 设置连锁信息：本次效果处理中将会从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 在基础可特召条件之上，追加筛选出连接标记数量等于lk（也就是已除外卡数量）的连接怪兽。
function c14816857.spfilter1(c,e,tp,lk)
	return c14816857.spfilter(c,e,tp) and c:IsLink(lk)
end
-- ①效果处理：先为全场（但只影响自己场上）设置“非兽族·兽战士族·鸟兽族不能作为连接素材”的限制，直到回合结束；然后按之前记录的除外数量，从额外卡组选择1只连接标记数相等的符合条件的连接怪兽表侧特殊召唤。
function c14816857.spop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：从自己墓地把兽族·兽战士族·鸟兽族怪兽任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只兽族·兽战士族·鸟兽族连接怪兽从额外卡组特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。②：这张卡被送去墓地的场合才能发动。从卡组把「铁兽战线 纳贝尔」以外的1只「铁兽」怪兽加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置限制效果的作用对象：不是兽族/兽战士族/鸟兽族的怪兽，即这些怪兽不能作为连接素材。
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c14816857.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述限制效果注册到双方场上，持续到结束阶段，实际生效由sumlimit判断只影响自己场上的怪兽。
	Duel.RegisterEffect(e1,tp)
	local lk=e:GetLabel()
	-- 向当前玩家发出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只连接标记数等于除外数量且满足可特召条件的连接怪兽。
	local g=Duel.SelectMatchingCard(tp,c14816857.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的连接怪兽以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断某只怪兽是否受“不能作为连接素材”限制：只有当该怪兽的控制者是效果持有者时才受限制。
function c14816857.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- ②效果的检索对象条件：卡组中的「铁兽」怪兽、是怪兽、卡名不是「铁兽战线 纳贝尔」、且可以被加入手卡。
function c14816857.thfilter(c)
	return c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) and not c:IsCode(14816857) and c:IsAbleToHand()
end
-- ②效果的目标处理：发动时检查卡组中存在符合条件的「铁兽」怪兽，并设置将卡片加入手卡的操作信息。
function c14816857.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若chk==0（发动条件确认），检查卡组是否存在至少1张满足thfilter的「铁兽」怪兽，存在才允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c14816857.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：本次处理将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只符合条件的「铁兽」怪兽加入手卡，并向对方展示。
function c14816857.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家发出“请选择要加入手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中实际选择1张满足thfilter的「铁兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c14816857.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡，原因记为效果处理。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
