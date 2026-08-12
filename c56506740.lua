--原石の皇脈
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组把「原石的皇脉」以外的1张「原石」卡加入手卡。
-- ②：自己场上的通常怪兽以及「原石」怪兽的攻击力上升自己墓地的通常怪兽种类×300。
-- ③：宣言1个通常怪兽的卡名才能发动。宣言的1只通常怪兽从自己的手卡·卡组·墓地守备表示特殊召唤。这个回合，自己不能把特殊召唤的场上的怪兽的效果发动。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（发动时检索原石卡）、②效果（场上通常/原石怪兽根据墓地通常怪兽种类升攻）、③效果（宣言卡名特召通常怪兽并限制特召怪兽的效果发动）。
function s.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从卡组把「原石的皇脉」以外的1张「原石」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的通常怪兽以及「原石」怪兽的攻击力上升自己墓地的通常怪兽种类×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置②效果的影响对象为自己场上的通常怪兽以及「原石」怪兽。
	e2:SetTarget(aux.TargetBoolFunction(s.aufilter))
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	-- ③：宣言1个通常怪兽的卡名才能发动。宣言的1只通常怪兽从自己的手卡·卡组·墓地守备表示特殊召唤。这个回合，自己不能把特殊召唤的场上的怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.smtg)
	e3:SetOperation(s.smop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中「原石的皇脉」以外的「原石」卡。
function s.thfilter(c)
	return c:IsSetCard(0x1b9) and not c:IsCode(56506740) and c:IsAbleToHand()
end
-- ①效果的发动准备：检查卡组中是否存在可检索的「原石」卡，并设置操作信息为将1张卡从卡组加入手卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「原石的皇脉」以外的「原石」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息为将卡组的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选择1张「原石的皇脉」以外的「原石」卡加入手卡，并给对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「原石」卡。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：通常怪兽或「原石」怪兽。
function s.aufilter(c)
	return c:IsSetCard(0x1b9) or c:IsType(TYPE_NORMAL)
end
-- 计算攻击力上升值：获取自己墓地的通常怪兽，并根据其卡名种类数量乘以300。
function s.atkval(e)
	-- 获取自己墓地的所有通常怪兽。
	local g=Duel.GetMatchingGroup(Card.IsType,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil,TYPE_NORMAL)
	return g:GetClassCount(Card.GetCode)*300
end
-- 过滤条件：原本卡片类型为通常怪兽且可以守备表示特殊召唤的怪兽。
function s.smfilter(c,e,tp)
	return bit.band(c:GetOriginalType(),TYPE_NORMAL)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ③效果的发动准备：检查怪兽区域是否有空位，以及手卡·卡组·墓地是否存在可特召的通常怪兽。
function s.smtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡、卡组、墓地是否存在至少1只可以特殊召唤的通常怪兽。
		and Duel.IsExistingMatchingCard(s.smfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,e,tp) end
	-- 获取手卡、卡组、墓地中所有可以特殊召唤的通常怪兽。
	local g=Duel.GetMatchingGroup(s.smfilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp)
	local sg=Group.CreateGroup()
	local codes={}
	-- 遍历所有可特召的通常怪兽，用于提取不重复的卡名列表以供宣言。
	for c in aux.Next(g) do
		local code=c:GetCode()
		if not sg:IsExists(Card.IsCode,1,nil,code) then
			sg:AddCard(c)
			table.insert(codes,code)
		end
	end
	table.sort(codes)
	local afilter={codes[1],OPCODE_ISCODE}
	if #codes>1 then
		for i=2,#codes do
			table.insert(afilter,codes[i])
			table.insert(afilter,OPCODE_ISCODE)
			table.insert(afilter,OPCODE_OR)
		end
	end
	-- 提示玩家宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家从符合条件的通常怪兽卡名中宣言一个卡名。
	local code=Duel.AnnounceCard(tp,table.unpack(afilter))
	getmetatable(e:GetHandler()).announce_filter={TYPE_MONSTER,OPCODE_ISTYPE,TYPE_NORMAL,OPCODE_ISTYPE,5405694,OPCODE_ISCODE,OPCODE_OR,OPCODE_AND}
	-- 将宣言的卡名保存为效果的目标参数。
	Duel.SetTargetParam(code)
	-- 设置连锁的操作信息为宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 设置连锁的操作信息为从手卡、卡组、墓地特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- ③效果的处理：在怪兽区域有空位时，从手卡·卡组·墓地选择1只宣言卡名的通常怪兽守备表示特殊召唤，并适用“这个回合自己不能发动特殊召唤的场上怪兽的效果”的限制。
function s.smop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取发动时宣言的卡名。
		local code=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 获取手卡、卡组、墓地（受王家之谷影响）中与宣言卡名相同且可特召的怪兽。
		local og=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.smfilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,nil,e,tp):Filter(Card.IsCode,nil,code)
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local g=og:Select(tp,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧守备表示特殊召唤。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个回合，自己不能把特殊召唤的场上的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能发动特殊召唤的场上怪兽效果的限制。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能发动在场上特殊召唤的怪兽的效果。
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE)
end
