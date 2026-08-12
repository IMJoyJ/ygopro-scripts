--マシンナーズ・ギアフレーム
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「机甲机械骨架」以外的1只「机甲」怪兽加入手卡。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
function c42940404.initial_effect(c)
	-- 为卡片注册同盟怪兽机制，使其具备装备、特殊召唤等效果
	aux.EnableUnionAttribute(c,c42940404.filter)
	-- ①：这张卡召唤成功时才能发动。从卡组把「机甲机械骨架」以外的1只「机甲」怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(42940404,2))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e5:SetCode(EVENT_SUMMON_SUCCESS)
	e5:SetTarget(c42940404.stg)
	e5:SetOperation(c42940404.sop)
	c:RegisterEffect(e5)
end
-- 定义同盟怪兽可装备的怪兽种族为机械族
function c42940404.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义检索条件：卡名为「机甲」系列且不是自身、类型为怪兽、可以加入手牌
function c42940404.sfilter(c)
	return c:IsSetCard(0x36) and not c:IsCode(42940404) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果的发动条件为卡组存在满足条件的怪兽，用于检索效果的处理
function c42940404.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在至少1张符合条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42940404.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将从卡组检索1张怪兽卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数，用于执行检索和展示操作
function c42940404.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c42940404.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认展示被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
