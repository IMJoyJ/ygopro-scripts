--風来王 ワイルド・ワインド
-- 效果：
-- ①：自己场上有攻击力1500以下的恶魔族调整存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从卡组把1只攻击力1500以下的恶魔族调整加入手卡。
function c52589809.initial_effect(c)
	-- ①：自己场上有攻击力1500以下的恶魔族调整存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c52589809.spcon)
	e1:SetOperation(c52589809.spop)
	c:RegisterEffect(e1)
	-- ②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。从卡组把1只攻击力1500以下的恶魔族调整加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置②效果的发动条件：这张卡送去墓地的回合不能发动（使用辅助函数aux.exccon）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外（使用辅助函数aux.bfgcost）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52589809.thtg)
	e2:SetOperation(c52589809.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤条件用的过滤函数：判定怪兽是否为表侧表示且攻击力1500以下且恶魔族且调整。
function c52589809.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER)
end
-- ①效果的规则特殊召唤条件：c为空时返回true表示规则可适用；否则要求召唤者场上有主要怪兽区空格，并且自己场上存在满足filter的怪兽。
function c52589809.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查tp玩家的主要怪兽区是否存在可用空格，防止无法特殊召唤。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查tp玩家场上是否存在至少1只表侧表示、攻击力1500以下、恶魔族、调整的怪兽。
		and Duel.IsExistingMatchingCard(c52589809.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①特殊召唤成功后的处理：给tp玩家赋予“这个回合不能从额外卡组特殊召唤非同步怪兽”的自肃效果。
function c52589809.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 这个方法特殊召唤过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。②：从卡组把1只攻击力1500以下的恶魔族调整加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c52589809.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将新生成的自肃效果注册给玩家tp（作为对tp玩家的限制效果）。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定：从额外卡组特殊召唤的怪兽若不是同步怪兽则不能特殊召唤。
function c52589809.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- ②检索的过滤条件：卡组中存在攻击力1500以下、恶魔族、调整、且可以加入手卡的卡。
function c52589809.thfilter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- ②的发动目标：检查卡组是否有符合条件的卡；若有则登记操作信息，表示处理时将卡组中的卡加入手牌。
function c52589809.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时的合法性检查（chk==0）：卡组中必须存在至少1张满足thfilter的卡才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c52589809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本连锁将把1张卡从卡组加入手牌（targets为nil表示处理时再选择，count为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的卡加入手牌，并让对方确认。
function c52589809.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让tp从卡组中选择1张满足thfilter的卡（必选1张）。
	local g=Duel.SelectMatchingCard(tp,c52589809.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
