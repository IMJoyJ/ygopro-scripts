--捕食植物セラセニアント
-- 效果：
-- 「捕食植物 瓶子草蚁」的③的效果1回合只能使用1次。
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
-- ③：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把「捕食植物 瓶子草蚁」以外的1张「捕食」卡加入手卡。
function c53819028.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53819028,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53819028.spcon)
	e1:SetTarget(c53819028.sptg)
	e1:SetOperation(c53819028.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53819028,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(c53819028.destg)
	e2:SetOperation(c53819028.desop)
	c:RegisterEffect(e2)
	-- 「捕食植物 瓶子草蚁」的③的效果1回合只能使用1次。③：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把「捕食植物 瓶子草蚁」以外的1张「捕食」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53819028,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,53819028)
	e3:SetTarget(c53819028.thtg)
	e3:SetOperation(c53819028.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c53819028.thcon)
	c:RegisterEffect(e4)
end
-- 效果①的发动条件：对方怪兽的直接攻击宣言时，即攻击怪兽的控制者为对方且攻击目标不存在。
function c53819028.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方怪兽的直接攻击宣言：攻击者控制者不是己方且攻击目标为空。
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 效果①的发动目标检查：确认自己场上有空余的怪兽区域，且这张卡可以被特殊召唤。
function c53819028.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将进行特殊召唤（对象为此卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：若此卡仍与效果关联，将其表侧攻击表示特殊召唤到自己的怪兽区。
function c53819028.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 由己方将此卡以表侧攻击表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的目标选择：确定与这张卡战斗的对方怪兽（若这张卡是攻击者则取攻击目标，否则取攻击者），并确认它仍与战斗关联。
function c53819028.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击者是此卡自身，则将战斗对象改为攻击目标（即对方被攻击的怪兽）。
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsRelateToBattle() end
	-- 设置操作信息：本效果将破坏目标怪兽（数量1）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 效果②的处理：若该怪兽仍与战斗关联且控制者为对方，将其破坏。
function c53819028.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 若攻击者是此卡自身，则将战斗对象改为攻击目标。
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 以效果破坏该对方怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③用于‘被效果送去墓地’场合的追加条件：此卡是被效果送入墓地，且之前位于场上。
function c53819028.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 检索过滤器：满足‘捕食’字段、可以从卡组加入手卡、且卡名不是「捕食植物 瓶子草蚁」的卡。
function c53819028.thfilter(c)
	return c:IsSetCard(0xf3) and c:IsAbleToHand() and not c:IsCode(53819028)
end
-- 效果③的发动的目标检查：确认卡组中存在1张符合条件的「捕食」卡。
function c53819028.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足thfilter条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c53819028.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本效果将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的处理：从卡组选择1张符合条件的「捕食」卡加入手卡，并让对方确认。
function c53819028.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示从卡组选择要加入手卡的卡片的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足thfilter条件的卡（自己选择）。
	local g=Duel.SelectMatchingCard(tp,c53819028.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手卡（默认加入持有者手卡，即自己），原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
