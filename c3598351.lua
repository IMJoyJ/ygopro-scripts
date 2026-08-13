--E-HERO トキシック・バブル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是「英雄」怪兽不能特殊召唤。
-- ②：这张卡特殊召唤的场合，若「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在则能发动。自己抽2张。
local s,id,o=GetID()
-- 初始化函数：将①的从手卡特殊召唤的规则效果（EFFECT_SPSUMMON_PROC）和②的特殊召唤成功时抽2张的诱发效果注册到卡片上，并设置各自的发动次数限制、条件与处理函数。
function s.initial_effect(c)
	-- 将卡名中记载的「暗黑融合」（卡号94820406）加入代码列表，用于识别「暗黑融合」的效果才能特殊召唤的融合怪兽这一条件。
	aux.AddCodeList(c,94820406)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡特殊召唤的场合，若「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在则能发动。自己抽2张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则效果的条件：c为nil时返回true（规则询问）；否则检查这张卡的控制者主要怪兽区是否有空位，有空位才可以从手卡进行规则特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	-- 返回这张卡控制者场上主要怪兽区的可用空格数大于0，即存在可特殊召唤的区域。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 特殊召唤成功后的处理：给自己玩家设置一个誓约效果，本回合内不能特殊召唤「英雄」以外的怪兽，结束阶段时该限制重置。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤过的回合，自己不是「英雄」怪兽不能特殊召唤。②：这张卡特殊召唤的场合，若「暗黑融合」的效果才能特殊召唤的融合怪兽在自己场上存在则能发动。自己抽2张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将生成的“不能特殊召唤非英雄怪兽”的誓约效果登记到玩家tp身上，使其持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：目标怪兽不是「英雄」（0x8）时禁止特殊召唤，即本回合只能特殊召唤「英雄」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0x8)
end
-- 过滤函数：识别场上表侧表示且带有dark_calling标记的怪兽，该标记表示此怪兽是由「暗黑融合」的效果才能特殊召唤的融合怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c.dark_calling
end
-- ②效果的发动条件判定与操作登记：当自己场上有符合条件的融合怪兽且自己能抽2张时，将对象玩家设为自己、抽卡数设为2，并登记抽卡操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己场上有满足条件的融合怪兽存在，且自己可以抽2张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsPlayerCanDraw(tp,2) end
	-- 设定效果的目标玩家为当前玩家tp，表示抽卡对象。
	Duel.SetTargetPlayer(tp)
	-- 设定效果的目标参数为2，即抽卡张数。
	Duel.SetTargetParam(2)
	-- 登记连锁操作信息：此效果为抽卡效果（CATEGORY_DRAW），目标玩家为tp，预计抽2张，供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果的处理函数：从连锁信息中取得对象玩家与抽卡数，并让该玩家抽对应数量的卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家p和参数d（抽卡数），用于后续抽卡。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）让玩家p抽取d张卡，完成“自己抽2张”的处理。
	Duel.Draw(p,d,REASON_EFFECT)
end
