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
	-- 效果作用：设置该效果的发动条件为“这张卡送去墓地的回合不能发动”
	e2:SetCondition(aux.exccon)
	-- 效果作用：设置该效果的发动费用为“将此卡从墓地除外”
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c52589809.thtg)
	e2:SetOperation(c52589809.thop)
	c:RegisterEffect(e2)
end
-- 效果作用：定义满足条件的卡片过滤函数，用于判断场上是否存在攻击力1500以下的恶魔族调整
function c52589809.filter(c)
	return c:IsFaceup() and c:IsAttackBelow(1500) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER)
end
-- 效果作用：判断是否满足特殊召唤条件，即自己场上有攻击力1500以下的恶魔族调整存在且有空场
function c52589809.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 效果作用：检查自己场上是否有足够的怪兽区域（主怪兽区）
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：检查自己场上是否存在至少一张攻击力1500以下的恶魔族调整
		and Duel.IsExistingMatchingCard(c52589809.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用：创建并注册一个永续效果，禁止自己在该回合从额外卡组特殊召唤非同调怪兽
function c52589809.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- ①：自己场上有攻击力1500以下的恶魔族调整存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c52589809.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 效果作用：将效果e1注册到玩家tp的全局环境，使其生效
	Duel.RegisterEffect(e1,tp)
end
-- 效果作用：定义该效果的目标限制函数，禁止非同调怪兽从额外卡组特殊召唤
function c52589809.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果作用：定义检索目标过滤函数，用于筛选攻击力1500以下的恶魔族调整
function c52589809.thfilter(c)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 效果作用：设置效果处理时的操作信息，表示将从卡组检索一张恶魔族调整加入手牌
function c52589809.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查是否满足发动条件，即自己卡组中是否存在至少一张符合条件的恶魔族调整
	if chk==0 then return Duel.IsExistingMatchingCard(c52589809.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 效果作用：设置连锁操作信息，指定要处理的目标为卡组中的恶魔族调整
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行检索并加入手牌的操作，选择一张符合条件的恶魔族调整加入手牌
function c52589809.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 效果作用：从卡组中选择一张符合条件的恶魔族调整作为目标
	local g=Duel.SelectMatchingCard(tp,c52589809.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的卡片以效果原因送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 效果作用：向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
