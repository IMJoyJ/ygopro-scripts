--アチチ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「辣辣妖@火灵天星」外的1只4星以下的「@火灵天星」怪兽从卡组加入手卡。
-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
function c15808381.initial_effect(c)
	-- 效果原文：①：这张卡召唤·特殊召唤的场合才能发动。除「辣辣妖@火灵天星」外的1只4星以下的「@火灵天星」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(15808381,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,15808381)
	e1:SetTarget(c15808381.thtg)
	e1:SetOperation(c15808381.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15808381,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,15808382)
	e3:SetCondition(c15808381.descon)
	-- 将此卡从游戏中除外作为cost的处理
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c15808381.destg)
	e3:SetOperation(c15808381.desop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的卡片组：4星以下、@火灵天星系列、怪兽卡、非本卡、可加入手牌
function c15808381.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and not c:IsCode(15808381) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁信息：准备从卡组检索1张卡加入手牌
function c15808381.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：检查自己卡组是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c15808381.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的连锁信息：准备从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：提示选择卡组中的卡并将其加入手牌
function c15808381.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c15808381.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足发动条件：确认攻击怪兽为电子界族
function c15808381.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽为对方控制，则获取攻击目标怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE)
end
-- 设置效果处理时的连锁信息：准备破坏指定的怪兽
function c15808381.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 设置效果处理时的连锁信息：准备破坏指定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 效果处理：破坏指定的怪兽
function c15808381.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 将指定的怪兽破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
