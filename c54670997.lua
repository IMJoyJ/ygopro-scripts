--GP－ベター・ラック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，以下效果可以适用。
-- ●从卡组把1只「黄金荣耀」怪兽加入手卡，自己失去那只怪兽的攻击力数值的基本分。
-- ②：从额外卡组特殊召唤的自己场上的表侧表示的「黄金荣耀」怪兽回到额外卡组的场合才能发动。自己抽1张。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡片发动时的效果处理）和②效果（怪兽回到额外卡组时抽卡）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，以下效果可以适用。●从卡组把1只「黄金荣耀」怪兽加入手卡，自己失去那只怪兽的攻击力数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：从额外卡组特殊召唤的自己场上的表侧表示的「黄金荣耀」怪兽回到额外卡组的场合才能发动。自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCondition(s.drcon)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可检索的「黄金荣耀」怪兽的条件。
function s.filter(c)
	return c:IsSetCard(0x192) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时效果处理，玩家可选择是否检索1只「黄金荣耀」怪兽并失去等同于其攻击力的生命值。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中所有满足条件的「黄金荣耀」怪兽。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中没有符合条件的怪兽，或玩家选择不适用该效果，则直接结束效果处理。
	if #g==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end  --"是否从卡组把1只「黄金荣耀」怪兽加入手卡？"
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 确认选中的卡片成功加入手牌。
	if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 then
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
		-- 获取玩家当前的生命值。
		local lp=Duel.GetLP(tp)
		-- 扣除玩家等同于该怪兽攻击力数值的生命值。
		Duel.SetLP(tp,lp-tc:GetAttack())
	end
end
-- 过滤触发②效果的卡片：从额外卡组特殊召唤的、原本由自己控制的、在怪兽区表侧表示存在的「黄金荣耀」怪兽回到额外卡组。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(0x192) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonLocation(LOCATION_EXTRA)
		and c:IsLocation(LOCATION_EXTRA) and c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 检查是否有满足条件的「黄金荣耀」怪兽回到了额外卡组，作为②效果的发动条件。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的发动准备与目标确认，检查玩家是否能抽卡，并设置抽卡参数和操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽1张卡的能力。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将当前效果的对象玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的对象参数（抽卡数量）设置为1。
	Duel.SetTargetParam(1)
	-- 设置连锁信息，表明此效果包含抽卡分类，预计由自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②效果的实际处理，获取目标玩家和抽卡数量并执行抽卡。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取之前在target中设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行效果抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
