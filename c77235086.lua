--サイバー・エンジェル－弁天－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本守备力数值的伤害。
-- ②：这张卡被解放的场合才能发动。从卡组把1只天使族·光属性怪兽加入手卡。
function c77235086.initial_effect(c)
	-- 记录该卡记载了「机械天使的仪式」的卡名
	aux.AddCodeList(c,39996157)
	c:EnableReviveLimit()
	-- ①：这张卡战斗破坏怪兽送去墓地的场合发动。给与对方那只怪兽的原本守备力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77235086,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测该卡是否战斗破坏了对方怪兽并送去墓地
	e1:SetCondition(aux.bdgcon)
	e1:SetTarget(c77235086.damtg)
	e1:SetOperation(c77235086.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡被解放的场合才能发动。从卡组把1只天使族·光属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(77235086,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_RELEASE)
	e2:SetTarget(c77235086.thtg)
	e2:SetOperation(c77235086.thop)
	c:RegisterEffect(e2)
end
-- 伤害效果的目标判断与操作信息设置
function c77235086.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetBattleTarget():GetDefense()
	if dam<0 then dam=0 end
	-- 设置伤害的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害的值为被破坏怪兽的守备力数值
	Duel.SetTargetParam(dam)
	-- 设置操作信息为：给与对方该守备力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 伤害效果的具体操作：给与对方被破坏怪兽的原本守备力数值 of 伤害
function c77235086.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的目标玩家与伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与对方玩家伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 过滤卡组中的光属性·天使族怪兽且能加入手卡
function c77235086.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 检索效果的目标判断与操作信息设置
function c77235086.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组是否存在至少1只符合检索条件的光属性·天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c77235086.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为：将卡组中的一张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体操作：从卡组将1只光属性·天使族怪兽加入手牌并展示
function c77235086.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c77235086.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示选中的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
