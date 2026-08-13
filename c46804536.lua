--BK キング・デンプシー
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组选1只4星以下的战士族·炎属性怪兽或者1张「燃烧拳」魔法·陷阱卡加入手卡或送去墓地。
-- ②：自己·对方回合可以发动。自己场上1个超量素材取除，以下效果适用。
-- ●这个回合中对方不能把自己场上的「燃烧拳击手」怪兽作为效果的对象。
function c46804536.initial_effect(c)
	-- 设置这张卡的超量召唤手续：用2只4星怪兽作为超量素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 对应①效果：这张卡特殊召唤的场合才能发动。从卡组选1只4星以下的战士族·炎属性怪兽或者1张「燃烧拳」魔法·陷阱卡加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46804536,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,46804536)
	e1:SetTarget(c46804536.thtg)
	e1:SetOperation(c46804536.thop)
	c:RegisterEffect(e1)
	-- 对应②效果：自己·对方回合可以发动。自己场上1个超量素材取除，以下效果适用。●这个回合中对方不能把自己场上的「燃烧拳击手」怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46804536,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46804537)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetTarget(c46804536.tgtg)
	e2:SetOperation(c46804536.tgop)
	c:RegisterEffect(e2)
end
-- 筛选条件：选择卡组中1只4星以下的战士族·炎属性怪兽，或1张「燃烧拳」魔法·陷阱卡，且该卡能够加入手卡或能够送去墓地。
function c46804536.thfilter(c)
	return (c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_FIRE)
		or c:IsSetCard(0x2084) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的发动条件：检查自己卡组中是否存在至少1张满足thfilter条件的卡片。
function c46804536.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性判定：若chk==0，则要求卡组中存在至少1张符合检索/送墓条件的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c46804536.thfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理：从自己卡组选择1张符合条件的卡片，若该卡既能加入手卡又能送去墓地则由玩家选择其中一项；若只能加入手卡则加入手卡，否则送去墓地。
function c46804536.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出提示，要求玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己卡组中选出1张满足thfilter条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c46804536.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end
	-- 判断选择到的卡片：若能加入手卡且（不能送去墓地或玩家选择加入手卡），则执行加入手卡分支；否则执行送去墓地分支。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡片以效果原因加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡片以效果原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：检查自己场上是否有至少1个超量素材可以因效果取除。
function c46804536.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点合法性判定：若chk==0，则要求自己场上存在可取除的超量素材，否则不能发动。
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) end
end
-- ②效果的处理：取除自己场上1个超量素材，成功后给己方场上所有「燃烧拳击手」怪兽附加‘不能成为对方效果对象’的保护效果，持续到回合结束。
function c46804536.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际取除自己场上1个超量素材；取除成功时才继续适用后续的保护效果。
	if Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)~=0 then
		-- 对应●效果：这个回合中对方不能把自己场上的「燃烧拳击手」怪兽作为效果的对象。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 指定受到保护的卡：己方场上所有「燃烧拳击手」字段的怪兽。
		e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1084))
		e1:SetValue(c46804536.tgval)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将该‘不能成为效果对象’的领域效果注册到场上，使其持续生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定发起效果的对象是否为对方玩家（若效果的发动方是当前效果拥有者的对手，则返回true），从而使对方不能选择己方「燃烧拳击手」怪兽作为效果对象。
function c46804536.tgval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
