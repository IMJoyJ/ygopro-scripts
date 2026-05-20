--マジシャンズ・ロッド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤时才能发动。把有「黑魔术师」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡在墓地存在的状态，自己在对方回合把魔法·陷阱卡的效果发动的场合，把自己场上1只魔法师族怪兽解放才能发动。这张卡加入手卡。
function c7084129.initial_effect(c)
	-- 在卡片关联列表中注册「黑魔术师」（卡号：46986414），用于后续检测卡片效果文本中是否记述了该卡名。
	aux.AddCodeList(c,46986414)
	-- ①：这张卡召唤时才能发动。把有「黑魔术师」的卡名记述的1张魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7084129,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,7084129)
	e1:SetTarget(c7084129.thtg)
	e1:SetOperation(c7084129.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己在对方回合把魔法·陷阱卡的效果发动的场合，把自己场上1只魔法师族怪兽解放才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(7084129,1))  --"墓地的这张卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,7084130)
	e3:SetCondition(c7084129.condition)
	e3:SetCost(c7084129.cost)
	e3:SetTarget(c7084129.target)
	e3:SetOperation(c7084129.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：筛选卡组中记述了「黑魔术师」卡名且可以加入手牌的魔法·陷阱卡。
function c7084129.thfilter(c)
	-- 检查卡片是否记述了「黑魔术师」卡名、是否为魔法或陷阱卡，以及是否可以加入手牌。
	return aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的发动准备与目标确认函数。
function c7084129.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张满足检索条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c7084129.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理函数。
function c7084129.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡。
	local g=Duel.SelectMatchingCard(tp,c7084129.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判断函数。
function c7084129.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己发动了魔法·陷阱卡的效果。
	return Duel.GetTurnPlayer()~=tp and rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动代价（Cost）处理函数。
function c7084129.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1只可解放的魔法师族怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_SPELLCASTER) end
	-- 让玩家选择自己场上1只魔法师族怪兽作为解放对象。
	local sg=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_SPELLCASTER)
	-- 解放选中的怪兽作为发动代价。
	Duel.Release(sg,REASON_COST)
end
-- 效果②的发动准备与目标确认函数。
function c7084129.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理的操作信息：将墓地的这张卡（自身）加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理函数。
function c7084129.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡因效果加入手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
