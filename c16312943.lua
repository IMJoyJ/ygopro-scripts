--リブロマンサー・ファイア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把「书灵师·炽火」以外的1只「书灵师」怪兽加入手卡。
local s,id,o=GetID()
-- 创建并注册两个效果：①作为起动效果，展示手牌仪式怪兽为代价从手卡特殊召唤自身；②作为诱发效果，在特殊召唤成功时从卡组检索「书灵师」怪兽加入手牌，且两个效果各自设置1回合只能使用1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把手卡1只仪式怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合才能发动。从卡组把「书灵师·炽火」以外的1只「书灵师」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：对手牌中满足“仪式怪兽且怪兽卡且当前不是公开状态”的卡进行筛选，用于选择给对方确认的仪式怪兽。
function s.cfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 发动代价处理：首先检查手牌是否存在符合条件的仪式怪兽；若存在，弹出选择提示并从中选择1张，给对方确认后洗切手牌，完成展示代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价的合法性检查（chk==0阶段）：确认自己手牌中至少存在1张满足s.cfilter条件的仪式怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 弹出“请选择给对方确认的卡”的选择提示，用于引导玩家在后续选择操作中选择要展示的仪式怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己的手牌中选择1张满足s.cfilter条件的仪式怪兽（不选择已公开的卡），作为展示给对方确认的对象。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的仪式怪兽展示给对方玩家确认，满足“给对方观看”的发动条件。
	Duel.ConfirmCards(1-tp,g)
	-- 由于展示手牌后对方获知了手牌信息，此处洗切自己的手牌，避免因展示造成手牌顺序等信息泄露。
	Duel.ShuffleHand(tp)
end
-- 设定①效果的发动目标条件：自己主要怪兽区有空位，且这张卡自身能够被特殊召唤；满足时通过 chk==0 返回真。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否有可用空格，确保特殊召唤后能放置到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为“特殊召唤”，对象为本卡，数量为1，供后续效果处理和相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若这张卡仍与当前效果保持关联，则将其以表侧表示特殊召唤到自己的主要怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果e关联（例如未被连锁离场等），确认关联后将其表侧表示特殊召唤，完成自卡特招。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- 定义检索卡组的筛选函数：必须是「书灵师」系列怪兽卡、可以被加入手牌、且卡名不是「书灵师·炽火」本身。
function s.filter(c)
	return c:IsSetCard(0x17c) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 设定②效果的发动条件：卡组中存在符合条件的「书灵师」怪兽；并设置操作信息为“从卡组加入手牌”。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在②效果发动时检查卡组是否存在至少1张满足s.filter条件的「书灵师」怪兽，作为能否发动的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将从卡组把1张卡加入手牌，用于连锁处理和效果发动后的检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「书灵师」怪兽加入手牌，并让对方确认加入手牌的卡。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要加入手牌的卡”的选择提示，供玩家在检索时选择目标卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己的卡组中选择1张满足s.filter条件的「书灵师」怪兽，作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡以效果原因送入其持有者的手卡，即完成检索加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认，让对方知道检索到了哪张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
