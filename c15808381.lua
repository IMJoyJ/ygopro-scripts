--アチチ＠イグニスター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。除「辣辣妖@火灵天星」外的1只4星以下的「@火灵天星」怪兽从卡组加入手卡。
-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
function c15808381.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。除「辣辣妖@火灵天星」外的1只4星以下的「@火灵天星」怪兽从卡组加入手卡。
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
	-- ②：自己的电子界族怪兽进行战斗的伤害步骤开始时，把墓地的这张卡除外才能发动。那只自己怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(15808381,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,15808382)
	e3:SetCondition(c15808381.descon)
	-- 设置②效果的发动代价：把墓地的这张卡除外（由aux.bfgcost实现检查并除外）。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c15808381.destg)
	e3:SetOperation(c15808381.desop)
	c:RegisterEffect(e3)
end
-- 检索过滤条件：4星以下、@火灵天星系列怪兽、卡名不是「辣辣妖@火灵天星」且能加入手卡的卡。
function c15808381.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x135) and c:IsType(TYPE_MONSTER) and not c:IsCode(15808381) and c:IsAbleToHand()
end
-- ①效果的发动条件判定与操作信息设定：确认卡组存在符合条件的「@火灵天星」怪兽，并设定检索加入手卡的类别信息。
function c15808381.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认卡组中是否存在至少1张满足thfilter过滤条件的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c15808381.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次连锁的操作信息设定为：由tp玩家从卡组把1张卡加入手卡（供后续发动检测使用）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选1只符合条件的「@火灵天星」怪兽加入手卡，并让对方确认。
function c15808381.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给当前玩家显示“请选择要加入手牌的卡”的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组挑选1张满足thfilter过滤条件的怪兽卡（不取对象，处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c15808381.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的怪兽加入持有者手卡（REASON_EFFECT为效果原因）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件：战斗的伤害步骤开始时，我方场上有表侧表示的电子界族怪兽正在参与战斗（攻击方或攻击对象），并将该怪兽存入效果LabelObject备用。
function c15808381.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此次战斗的攻击怪兽赋值给tc。
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽是对方的，则改取攻击对象作为我方参与战斗的电子界族怪兽。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	e:SetLabelObject(tc)
	return tc and tc:IsFaceup() and tc:IsRace(RACE_CYBERSE)
end
-- ②效果的对象确认：获取descon记录的战斗怪兽作为破坏对象，并设定破坏的操作信息。
function c15808381.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 将本次连锁的操作信息设定为：破坏那只战斗怪兽（1张），供连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- ②效果处理：若记录的战斗怪兽仍与本次战斗相关且由我方控制，则将其破坏。
function c15808381.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetLabelObject()
	if bc:IsRelateToBattle() and bc:IsControler(tp) then
		-- 以效果原因破坏那只自己怪兽。
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
