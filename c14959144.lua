--天極輝士－熊斗竜巧α
-- 效果：
-- 这个卡名在规则上也当作「北极天熊」卡、「龙辉巧」卡使用。这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：除「天极辉士-熊斗龙巧α」外的，「北极天熊」怪兽或「龙辉巧」怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「北极天熊」魔法·陷阱卡或「龙辉巧」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 创建并注册两个效果：e1为特殊召唤条件效果，限制只能用卡的效果特殊召唤；e2为起动效果，满足发动条件时从手卡特殊召唤自身，并可选检索「北极天熊」或「龙辉巧」魔法·陷阱卡。
function s.initial_effect(c)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的效果1回合只能使用1次。①：除「天极辉士-熊斗龙巧α」外的，「北极天熊」怪兽或「龙辉巧」怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「北极天熊」魔法·陷阱卡或「龙辉巧」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判定发起特殊召唤的行为是否属于卡的效果动作（EFFECT_TYPE_ACTIONS），以此限定本卡只能通过卡的效果特殊召唤，不能通过通常召唤或其他非效果方式特殊召唤。
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤函数：用于筛选自己场上的表侧表示怪兽，要求其属于「北极天熊」或「龙辉巧」字段，且不是天极辉士-熊斗龙巧α自身。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163,0x154) and not c:IsCode(id)
end
-- 发动条件判定：自己场上存在至少1只满足s.cfilter的「北极天熊」或「龙辉巧」表侧怪兽（不含自身）时，这个效果才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只满足s.cfilter的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的合法性检查：确认自己场上有可用的主要怪兽区空格，且这张卡可以（通过效果）特殊召唤，满足条件时才允许发动该效果。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的主要怪兽区空格，作为特殊召唤的前置条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息登记为‘特殊召唤这张卡’，数量1，供其他卡片（如星尘龙、王家长眠之谷等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索过滤函数：从卡组中筛选属于「北极天熊」或「龙辉巧」字段的魔法·陷阱卡，且该卡没有加入手卡的限制。
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x163,0x154) and c:IsAbleToHand()
end
-- 效果处理：若自己场上没有怪兽区空格则直接结束；否则确认这张卡仍与效果关联且特殊召唤成功；成功后若卡组存在符合条件的魔法·陷阱卡，且玩家选择‘是’，则选择1张，先中断当前效果链，再将其加入手卡，并向对方展示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有空余的怪兽区，则中止本次效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认这张卡仍与当前效果保持关联（未被重置/离场），并且以表侧表示特殊召唤成功（成功数>0）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 确认卡组中还存在至少1张符合条件的「北极天熊」或「龙辉巧」魔法·陷阱卡，以此决定是否给予玩家后续检索选项。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否要执行‘那之后，可以从卡组把1张……加入手卡’的追加处理；只有选择是才会继续检索。
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把魔法·陷阱卡加入手卡？"
		-- 向玩家显示选择提示，内容为‘请选择要加入手牌的卡’，将选择消息写入缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1张满足s.thfilter的卡（「北极天熊」或「龙辉巧」魔法·陷阱卡），作为加入手牌的对象。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 打断当前效果链，使后续‘加入手卡’与‘特殊召唤’不在同一时点处理，符合‘那之后’的时点规则。
		Duel.BreakEffect()
		-- 将选中的卡以效果原因加入其持有者的手卡（player为nil表示由持有者接收）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示检索并加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
