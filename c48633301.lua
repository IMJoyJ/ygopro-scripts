--TG ブースター・ラプトル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「科技属」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 推进盗龙」以外的1只「科技属」怪兽加入手卡。
function c48633301.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己场上有「科技属」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,48633301+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c48633301.sprcon)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c48633301.regop)
	c:RegisterEffect(e2)
end
-- 检索/判定用过滤条件：该怪兽须表侧表示且属于「科技属」系列（0x27）。用于确认自己场上是否存在表侧表示的「科技属」怪兽。
function c48633301.sprfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x27)
end
-- 特殊召唤规则的效果条件：当询问能否特殊召唤（c==nil）时返回true；否则要求自己的主要怪兽区有空位，且自己场上有表侧表示的「科技属」怪兽，才能从手卡特殊召唤。
function c48633301.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区是否有可用的空格，以保证特殊召唤能腾出位置。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上（主要怪兽区）是否存在至少1张满足sprfilter条件的怪兽，即表侧表示的「科技属」怪兽。
		and Duel.IsExistingMatchingCard(c48633301.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 当这张卡从场上被破坏并送去墓地时，若满足条件（之前在场且破坏原因），则在墓地中注册一个结束阶段可发动的诱发效果；该效果就是②的检索效果。
function c48633301.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 推进盗龙」以外的1只「科技属」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(48633301,0))
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c48633301.thtg)
		e1:SetOperation(c48633301.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 检索过滤条件：目标是「科技属」系列怪兽，卡名不是「科技属 推进盗龙」，是怪兽卡，且可以被加入手牌。
function c48633301.thfilter(c)
	return c:IsSetCard(0x27) and not c:IsCode(48633301) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ②效果的发动条件和目标设定：检查卡组是否存在满足thfilter的卡片，若存在则设置操作信息为将1张卡从卡组加入手牌。
function c48633301.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认卡组中至少有1张符合检索过滤条件的「科技属」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c48633301.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息，表明效果处理时会将1张卡从卡组加入手牌（检索效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的实际处理：从卡组选择1张符合条件的「科技属」怪兽加入手牌，并向对方展示。具体步骤包括提示选择、从卡组选取、送入持有者手牌、让对方确认。
function c48633301.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向当前玩家显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选出1张满足thfilter条件的卡片作为检索对象。
	local g=Duel.SelectMatchingCard(tp,c48633301.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把检索到手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
