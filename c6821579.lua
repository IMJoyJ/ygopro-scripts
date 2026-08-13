--R.B.バルカンブースター
-- 效果：
-- 机械族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「反叛曲机器人」魔法卡加入手卡。
-- ②：这张卡在额外怪兽区域存在的场合才能发动。从自己的手卡·墓地把1只「反叛曲机器人」怪兽守备表示特殊召唤。那之后，可以让自己场上的这张卡向其他的自己的主要怪兽区域移动。这个回合，自己不是攻击力1500以下的机械族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化效果：设置连接怪兽的苏生限制和连接召唤手续，注册①效果（连接召唤场合检索卡组魔法，1回合1次）和②效果（额外怪兽区域存在时特殊召唤，1回合1次）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：以2只机械族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_MACHINE),2,2)
	-- ①：这张卡连接召唤的场合才能发动。从卡组把1张「反叛曲机器人」魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在额外怪兽区域存在的场合才能发动。从自己的手卡·墓地把1只「反叛曲机器人」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡是连接召唤成功的
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索过滤条件：「反叛曲机器人」系列的魔法卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x1cf) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- ①效果的目标设定：确认卡组存在可检索的「反叛曲机器人」魔法卡，并向对方提示，设置加入手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能性的检查：自己的卡组存在至少1张满足条件的「反叛曲机器人」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：要从卡组把1张卡加入手卡（用于星尘龙、王家长眠之谷等的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：让自己从卡组选择1张「反叛曲机器人」魔法卡加入手卡，并向对方确认那张卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己从卡组选择1张满足条件的「反叛曲机器人」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的那张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：这张卡在额外怪兽区域存在（序号大于4）
function s.spcon(e)
	return e:GetHandler():GetSequence()>4
end
-- 特殊召唤过滤条件：「反叛曲机器人」怪兽且可以守备表示特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的目标设定：确认自己怪兽区域有空位，且手卡·墓地存在可特殊召唤的「反叛曲机器人」怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动可能性的检查：自己的主要怪兽区域有可用空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己的手卡·墓地存在至少1只可以守备表示特殊召唤的「反叛曲机器人」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了特殊召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：要从自己的手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- ②效果的处理：从自己手卡·墓地选1只「反叛曲机器人」怪兽守备表示特殊召唤，成功且这张卡仍在自己场上、主要怪兽区域有空位时，可以询问是否把这张卡向其他主要怪兽区域移动
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己的主要怪兽区域有可用空位才继续处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让自己从手卡·墓地选择1只满足条件且不受王家长眠之谷影响的「反叛曲机器人」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
		-- 把选择的怪兽守备表示特殊召唤成功，且这张卡与连锁关联
		if #g>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0
			and c:IsRelateToChain()
			and c:IsControler(tp)
			-- 且这张卡由自己控制，自己主要怪兽区域存在可以移动到的空位
			and Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0)>0
			-- 询问玩家是否把这张卡向其他的主要怪兽区域移动
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否移动？"
			-- 中断当前效果处理，使之后的移动处理视为不同时处理（对应「那之后」）
			Duel.BreakEffect()
			-- 提示玩家选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让自己选择1个主要怪兽区域的可用空位
			local fd=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,0)
			-- 高亮显示选择的目标区域
			Duel.Hint(HINT_ZONE,tp,fd)
			local seq=math.log(fd,2)
			-- 把这张卡移动到选择的主要怪兽区域
			Duel.MoveSequence(c,seq)
		end
	end
	-- 这个回合，自己不是攻击力1500以下的机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	-- 把特殊召唤限制效果作为发动玩家（tp）的玩家效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：从额外卡组特殊召唤的怪兽若不是攻击力1500以下的机械族怪兽，则不能特殊召唤
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsRace(RACE_MACHINE) and c:IsAttackBelow(1500))
end
