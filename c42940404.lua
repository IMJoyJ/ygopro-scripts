--マシンナーズ・ギアフレーム
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「机甲机械骨架」以外的1只「机甲」怪兽加入手卡。
-- ②：1回合1次，可以从以下效果选择1个发动。
-- ●以自己场上1只机械族怪兽为对象，把这张卡当作装备卡使用给那只怪兽装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备的这张卡特殊召唤。
function c42940404.initial_effect(c)
	-- 为这张卡注册同盟怪兽的共用效果（机械族装备对象、战斗/效果代破、主要阶段装备及解除装备特殊召唤），对应②的同盟相关效果。
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
-- 定义同盟装备的合法装备对象过滤条件：仅可选择机械族怪兽作为这张卡的装备对象。
function c42940404.filter(c)
	return c:IsRace(RACE_MACHINE)
end
-- 定义检索过滤条件：从卡组选择持有「机甲」字段、不是「机甲机械骨架」自身、是怪兽且能够加入手卡的1张「机甲」怪兽。
function c42940404.sfilter(c)
	return c:IsSetCard(0x36) and not c:IsCode(42940404) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置①效果的发动条件和操作信息：满足条件时检索卡组中的「机甲」怪兽并加入手卡。
function c42940404.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定是否满足发动条件：自己卡组中存在至少1张符合条件的「机甲」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c42940404.sfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定本次连锁的操作信息：效果分类为回手牌和检索，预计处理1张卡，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果的检索操作：选择卡组中符合条件的「机甲」怪兽加入手卡，并向对方确认。
function c42940404.sop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合sfilter条件的「机甲」怪兽。
	local g=Duel.SelectMatchingCard(tp,c42940404.sfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送去持有者手卡（加入手牌）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
