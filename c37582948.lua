--Live☆Twin トラブルサン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「直播☆双子」怪兽加入手卡。
-- ②：只要自己场上有「邪恶★双子」怪兽存在，每次对方把怪兽召唤·特殊召唤，自己回复200基本分，给与对方200伤害。
function c37582948.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「直播☆双子」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37582948+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c37582948.activate)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「邪恶★双子」怪兽存在，每次对方把怪兽召唤·特殊召唤，自己回复200基本分，给与对方200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c37582948.reccon)
	e2:SetOperation(c37582948.recop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义检索筛选器：判断卡组中的卡是否为「直播☆双子」怪兽且可以被加入手卡。
function c37582948.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1151) and c:IsAbleToHand()
end
-- ①效果的发动时的处理：若卡组存在符合条件的「直播☆双子」怪兽，则让玩家选择是否进行检索；选择后将那张卡加入手卡并展示给对方。
function c37582948.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己卡组筛选出所有满足thfilter条件的「直播☆双子」怪兽，组成临时卡片组g（不取对象）。
	local g=Duel.GetMatchingGroup(c37582948.thfilter,tp,LOCATION_DECK,0,nil)
	-- 检查卡组中是否有符合条件的怪兽，并弹出“是否从卡组把1只「直播☆双子」怪兽加入手卡？”的选择框让玩家确认。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(37582948,0)) then  --"是否从卡组把1只「直播☆双子」怪兽加入手卡？"
		-- 向玩家显示“请选择要加入手牌的卡”的选择提示，用于后续选卡界面。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「直播☆双子」怪兽以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将检索加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 定义过滤函数：判断怪兽是否由指定玩家tp召唤/特殊召唤（用于检测是否对方召唤）。
function c37582948.cfilter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 定义过滤函数：判断自己场上的表侧表示怪兽是否为「邪恶★双子」字段。
function c37582948.etfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2151)
end
-- ②效果的发动条件：当对方召唤·特殊召唤怪兽成功，且自己场上有表侧表示的「邪恶★双子」怪兽存在时，条件成立。
function c37582948.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本次成功召唤·特殊召唤的怪兽中是否有对方玩家召唤的怪兽，同时检查自己场上是否存在表侧表示的「邪恶★双子」怪兽，两者都满足才触发。
	return eg:IsExists(c37582948.cfilter,1,nil,1-tp) and Duel.IsExistingMatchingCard(c37582948.etfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果处理：向双方展示这张卡的发动动画，然后让自己回复200LP并给对方造成200伤害。
function c37582948.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向全场展示这张卡的卡图动画（效果发动提示）。
	Duel.Hint(HINT_CARD,0,37582948)
	-- 以效果原因让自己回复200基本分。
	Duel.Recover(tp,200,REASON_EFFECT)
	-- 以效果原因给对方造成200伤害。
	Duel.Damage(1-tp,200,REASON_EFFECT)
end
