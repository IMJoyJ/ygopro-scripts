--神芸学都アルトメギア
-- 效果：
-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「无垢者 米底乌斯」召唤。
-- ②：从手卡丢弃1张魔法·陷阱卡，宣言1个同名怪兽不在自己场上存在的「神艺」怪兽的卡名才能发动（这个回合，不能为这个卡名的这个效果发动而宣言相同卡名）。宣言的1只怪兽从卡组加入手卡。这个回合，自己不是「神艺」怪兽以及「无垢者 米底乌斯」不能特殊召唤（除从额外卡组的特殊召唤外）。
local s,id,o=GetID()
-- 卡片效果初始化函数。
function s.initial_effect(c)
	-- 在卡片中注册记载了「无垢者 米底乌斯」的卡名。
	aux.AddCodeList(c,97556336)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己在通常召唤外加上只有1次，自己主要阶段可以把1只「无垢者 米底乌斯」召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"使用「神艺学都 神艺学园」的效果召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置额外召唤效果的对象为「无垢者 米底乌斯」。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,97556336))
	c:RegisterEffect(e2)
	-- ②：从手卡丢弃1张魔法·陷阱卡，宣言1个同名怪兽不在自己场上存在的「神艺」怪兽的卡名才能发动（这个回合，不能为这个卡名的这个效果发动而宣言相同卡名）。宣言的1只怪兽从卡组加入手卡。这个回合，自己不是「神艺」怪兽以及「无垢者 米底乌斯」不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_ANNOUNCE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中可以丢弃的魔法·陷阱卡。
function s.costfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 效果②的发动代价处理函数：从手卡丢弃1张魔法·陷阱卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可作为发动代价丢弃的魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手卡中的魔法·陷阱卡。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤卡组中满足宣言条件的「神艺」怪兽（同名怪兽不在自己场上存在，且本回合未被该效果宣言过）。
function s.anfilter(c,tp)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		-- 检查自己场上不存在该卡名的同名怪兽。
		and not Duel.IsExistingMatchingCard(s.anexfilter,tp,LOCATION_MZONE,0,1,nil,c:GetCode())
		and not c:IsHasEffect(id,tp)
end
-- 过滤自己场上表侧表示的指定卡名的怪兽。
function s.anexfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 过滤卡组中与宣言卡名相同且可加入手卡的「神艺」怪兽。
function s.thfilter(c,code)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and c:IsCode(code)
end
-- 效果②的发动准备处理函数：进行卡名宣言并设置相关限制。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可宣言并加入手卡的「神艺」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.anfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 获取卡组中所有满足宣言条件的「神艺」怪兽卡片组。
	local g=Duel.GetMatchingGroup(s.anfilter,tp,LOCATION_DECK,0,nil,tp)
	local ag=Group.CreateGroup()
	local codes={}
	-- 遍历满足宣言条件的卡片组，用于提取所有可宣言的卡名。
	for c in aux.Next(g) do
		local code=c:GetCode()
		if not ag:IsExists(Card.IsCode,1,nil,code) then
			ag:AddCard(c)
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
	ag:Clear()
	local ncodes={}
	-- 获取自己场上所有表侧表示的「神艺」怪兽卡片组。
	local exg=Duel.GetMatchingGroup(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,nil,0x1cd)
	-- 遍历场上的「神艺」怪兽，用于提取场上已存在的卡名以进行后续过滤。
	for c in aux.Next(exg) do
		local code=c:GetCode()
		if not ag:IsExists(Card.IsCode,1,nil,code) then
			ag:AddCard(c)
			table.insert(ncodes,code)
		end
	end
	-- 提示玩家需要宣言一个卡名。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)  --"请宣言一个卡名"
	-- 让玩家从符合过滤条件的卡名列表中宣言一个卡名。
	local ac=Duel.AnnounceCard(tp,table.unpack(afilter))
	local af={
		TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT,
		0x1cd,OPCODE_ISSETCARD,OPCODE_AND,
		TYPE_MONSTER,OPCODE_ISTYPE,OPCODE_AND
	}
	for i=1,#ncodes do
		table.insert(af,ncodes[i])
		table.insert(af,OPCODE_ISCODE)
		table.insert(af,OPCODE_NOT)
		table.insert(af,OPCODE_AND)
	end
	getmetatable(e:GetHandler()).announce_filter=af
	-- 将宣言的卡名保存为当前连锁的效果处理参数。
	Duel.SetTargetParam(ac)
	-- 设置操作信息为宣言卡名。
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,0)
	-- 设置操作信息为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- （这个回合，不能为这个卡名的这个效果发动而宣言相同卡名）
	local e0=Effect.CreateEffect(e:GetHandler())
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(id)
	e0:SetTargetRange(1,0)
	e0:SetTarget(s.thlimit)
	e0:SetLabel(ac)
	e0:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于记录本回合已宣言卡名的全局效果。
	Duel.RegisterEffect(e0,tp)
end
-- 限制函数：使玩家不能再次宣言与本次效果相同的卡名。
function s.thlimit(e,c,tp,re)
	return c:IsCode(e:GetLabel())
end
-- 效果②的实际处理函数：将宣言的怪兽加入手卡，并施加特殊召唤限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时宣言并保存的卡名参数。
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张与宣言卡名相同的「神艺」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,ac)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不是「神艺」怪兽以及「无垢者 米底乌斯」不能特殊召唤（除从额外卡组的特殊召唤外）。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制特殊召唤的全局效果。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制函数：非额外卡组特殊召唤时，只能特殊召唤「神艺」怪兽以及「无垢者 米底乌斯」。
function s.splimit(e,c)
	return not (c:IsSetCard(0x1cd) or c:IsCode(97556336)) and not c:IsLocation(LOCATION_EXTRA)
end
