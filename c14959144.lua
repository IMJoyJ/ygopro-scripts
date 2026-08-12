--天極輝士－熊斗竜巧α
-- 效果：
-- 这个卡名在规则上也当作「北极天熊」卡、「龙辉巧」卡使用。这张卡不能通常召唤，用卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：除「天极辉士-熊斗龙巧α」外的，「北极天熊」怪兽或「龙辉巧」怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从卡组把1张「北极天熊」魔法·陷阱卡或「龙辉巧」魔法·陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片的特殊召唤条件和起动效果
function s.initial_effect(c)
	-- 设置该卡不能通常召唤，只能通过效果特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 设置效果①的发动条件、处理流程和效果分类
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
-- 限制该卡只能通过动作效果（如战斗、效果）特殊召唤
function s.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 过滤场上存在的「北极天熊」或「龙辉巧」怪兽（不包括自身）
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x163,0x154) and not c:IsCode(id)
end
-- 检查自己场上是否存在符合条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在符合条件的怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果①的发动时点判定条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有足够的特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的连锁操作信息，包含特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 过滤卡组中「北极天熊」或「龙辉巧」魔法·陷阱卡
function s.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x163,0x154) and c:IsAbleToHand()
end
-- 执行效果①的处理流程，包括特殊召唤和检索手牌
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断该卡是否能被特殊召唤并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		-- 检查卡组中是否存在符合条件的魔法·陷阱卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 询问玩家是否从卡组检索魔法·陷阱卡
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否从卡组把魔法·陷阱卡加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择卡组中符合条件的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		-- 中断当前效果处理，使后续处理视为错时点
		Duel.BreakEffect()
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
