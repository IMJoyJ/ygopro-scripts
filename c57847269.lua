--道化の一座『開演』
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组·额外卡组把1只「道化一座」怪兽无视召唤条件特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
-- ②：自己·对方的结束阶段才能发动。自己抽出这个回合被解放的怪兽种类（仪式·融合·同调·超量·灵摆·连接）的数量。那之后，可以从手卡把1张魔法·陷阱卡盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①效果（起动效果）、②效果（结束阶段诱发效果）以及用于记录解放怪兽种类的全局监听器
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。从卡组·额外卡组把1只「道化一座」怪兽无视召唤条件特殊召唤。这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段才能发动。自己抽出这个回合被解放的怪兽种类（仪式·融合·同调·超量·灵摆·连接）的数量。那之后，可以从手卡把1张魔法·陷阱卡盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"抽卡效果"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	if not s.global_check then
		s.global_check=true
		s[0]=0
		-- 自己抽出这个回合被解放的怪兽种类（仪式·融合·同调·超量·灵摆·连接）的数量。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果，用于监听并记录整局游戏中怪兽被解放的事件
		Duel.RegisterEffect(ge1,0)
		-- 自己抽出这个回合被解放的怪兽种类（仪式·融合·同调·超量·灵摆·连接）的数量。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge2:SetOperation(s.clearop)
		-- 注册全局效果，用于在每个回合的抽卡阶段开始时重置被解放怪兽种类的记录
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤函数：检索卡组或额外卡组中可以无视召唤条件特殊召唤的「道化一座」怪兽，并确认场上有足够的怪兽区域
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1dc) and c:IsType(TYPE_MONSTER)
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP)
		-- 过滤条件：若目标卡在卡组，则需要自己场上有可用的怪兽区域
		and (c:IsLocation(LOCATION_DECK) and Duel.GetMZoneCount(tp)>0
			-- 过滤条件：若目标卡在额外卡组，则需要自己场上有可用的额外怪兽区域
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- ①效果的发动准备：检查卡组或额外卡组是否存在可特殊召唤的怪兽，并向双方玩家宣告特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组或额外卡组是否存在至少1只满足特殊召唤条件的「道化一座」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表明此效果包含从卡组或额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_EXTRA)
end
-- ①效果的处理：特殊召唤1只「道化一座」怪兽，并对自身施加“直到下个回合结束时不能发动从卡组·额外卡组特殊召唤的怪兽的效果”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组或额外卡组选择1只满足条件的「道化一座」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽无视召唤条件以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到下个回合的结束时自己不能把从卡组·额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	-- 注册该玩家限制效果，使其在场上生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：限制发动效果的怪兽必须是处于怪兽区、且是从卡组或额外卡组特殊召唤的怪兽
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonType(SUMMON_TYPE_SPECIAL) and rc:IsLocation(LOCATION_MZONE) and rc:IsSummonLocation(LOCATION_DECK+LOCATION_EXTRA)
end
-- 监听解放事件的处理函数：遍历被解放的卡片，若为怪兽，则通过按位或运算记录其怪兽类型（仪式、融合、同调、超量、灵摆、连接）
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历当前事件中所有被解放的卡片
	for tc in aux.Next(eg) do
		if tc:IsType(TYPE_MONSTER) then
			s[0]=bit.bor(s[0],tc:GetType())
		end
	end
end
-- 回合开始时的重置函数：将记录被解放怪兽类型的全局变量重置为0
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	s[0]=0
end
-- ②效果的发动条件：检查本回合是否有仪式、融合、同调、超量、灵摆、连接怪兽被解放
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(s[0],TYPE_RITUAL+TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK)>0
end
-- ②效果的发动准备：计算本回合被解放的怪兽种类数量，检查玩家是否可以抽取对应数量的卡，并设置抽卡的操作信息
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=0
	local type={TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_PENDULUM,TYPE_LINK}
	for i=1,#type do
		local value=type[i]
		if bit.band(s[0],value)~=0 then
			ct=ct+1
		end
	end
	-- 检查玩家当前是否可以从卡组抽取计算出的怪兽种类数量的卡片
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct) end
	-- 设置连锁的操作信息，表明此效果包含让玩家抽取对应数量卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
-- ②效果的处理：让玩家抽取本回合被解放的怪兽种类数量的卡片，之后可以从手卡将1张魔法·陷阱卡盖放
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local ct=0
	local type={TYPE_RITUAL,TYPE_FUSION,TYPE_SYNCHRO,TYPE_XYZ,TYPE_PENDULUM,TYPE_LINK}
	for i=1,#type do
		local value=type[i]
		if bit.band(s[0],value)~=0 then
			ct=ct+1
		end
	end
	-- 尝试让玩家因效果抽取对应数量的卡片，并确认是否成功抽卡
	if Duel.Draw(tp,ct,REASON_EFFECT)~=0 then
		-- 获取玩家手卡中所有可以盖放到魔陷区的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 若手卡有可盖放的魔陷，询问玩家是否进行盖放
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡盖放？"
			-- 中断当前效果处理，使后续的盖放卡片处理与抽卡处理不视为同时进行
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的魔法·陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 让玩家洗切手卡，以重置手卡洗牌检测状态
			Duel.ShuffleHand(tp)
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
