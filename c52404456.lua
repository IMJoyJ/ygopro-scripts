--マドルチェ・メッセンジェラート
-- 效果：
-- ①：这张卡特殊召唤时才能发动。从卡组把1张「魔偶甜点」魔法·陷阱卡加入手卡。这个效果在自己场上有兽族「魔偶甜点」怪兽存在的场合才能发动和处理。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c52404456.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52404456,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c52404456.retcon)
	e1:SetTarget(c52404456.rettg)
	e1:SetOperation(c52404456.retop)
	c:RegisterEffect(e1)
	-- ①：这张卡特殊召唤时才能发动。从卡组把1张「魔偶甜点」魔法·陷阱卡加入手卡。这个效果在自己场上有兽族「魔偶甜点」怪兽存在的场合才能发动和处理。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52404456,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_ACTIVATE_CONDITION)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c52404456.shcon)
	e2:SetTarget(c52404456.shtg)
	e2:SetOperation(c52404456.shop)
	c:RegisterEffect(e2)
end
-- 判断②效果满足的场合：这张卡因对方造成的破坏（REASON_DESTROY）而送去墓地，且破坏原因玩家是对方（1-tp），并且破坏前控制权在我方（tp）——即我方场上的这张卡被对方破坏送去墓地时，②效果才满足发动条件。
function c52404456.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果（诱发必发）的Target函数：该效果不取对象，因此在chk==0阶段直接返回true表示可以发动；随后登记把这张卡自身送回卡组的操作信息，供后续连锁判定使用。
function c52404456.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将这张卡自身指定为要送回卡组的对象，数量为1，分类为CATEGORY_TODECK，使后续相关效果（如星尘龙、王家长眠之谷等）能检测到这次回卡组处理。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果处理时，检查这张卡是否仍与当前效果相关联（未因其它效果移动或离场）；若关联有效，则将其返回持有者卡组并洗牌，完成“这张卡回到卡组”的处理。
function c52404456.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）把这张卡送回持有者卡组，并使用SEQ_DECKSHUFFLE表示弹回卡组后需要洗牌。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤函数：判断一张卡是否可作为①效果条件所需的兽族「魔偶甜点」怪兽——它必须是表侧表示、卡名含有「魔偶甜点」字段（0x71）、且种族为兽族。
function c52404456.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsRace(RACE_BEAST)
end
-- ①效果的发动条件：自己场上的主要怪兽区（LOCATION_MZONE）存在至少1张满足cfilter且不是这张卡自身的兽族「魔偶甜点」怪兽，才允许发动检索效果。
function c52404456.shcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足cfilter且不是这张卡自身的表侧兽族「魔偶甜点」怪兽，这是①效果发动时必须满足的“自己场上有兽族「魔偶甜点」怪兽存在”条件。
	return Duel.IsExistingMatchingCard(c52404456.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 检索目标过滤函数：选择卡必须满足「魔偶甜点」字段、是魔法卡或陷阱卡、并且能够加入手卡（未受到“不能加入手卡”等效果限制）。
function c52404456.filter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的Target函数：在发动合法性检查（chk==0）时确认卡组中存在至少1张满足filter的检索目标；成立后登记从卡组把1张「魔偶甜点」魔法·陷阱卡加入手牌的操作信息。
function c52404456.shtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，检查卡组中是否存在至少1张符合条件的「魔偶甜点」魔法·陷阱卡；若不存在则不能发动①效果。
	if chk==0 then return Duel.IsExistingMatchingCard(c52404456.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：宣告本次效果将要从持有者卡组把1张卡加入手牌（CATEGORY_TOHAND+CATEGORY_SEARCH），具体卡片在效果处理时选择，数量为1，目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理流程：先再次确认自己场上仍有兽族「魔偶甜点」怪兽，然后让我方从卡组选择1张符合条件的「魔偶甜点」魔法·陷阱卡加入手牌，并向对方展示确认，完成检索。
function c52404456.shop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次检查自己场上是否存在满足cfilter的兽族「魔偶甜点」怪兽；若已经没有，则不执行检索处理，符合原文“才能发动和处理”中“处理”的条件限制。
	if not Duel.IsExistingMatchingCard(c52404456.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) then return end
	-- 弹出选择提示消息，提示我方选择要加入手牌的卡，消息内容为“请选择要加入手牌的卡”，用于后续Duel.SelectMatchingCard的交互说明。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让我方从卡组中选出1张满足filter的「魔偶甜点」魔法·陷阱卡（min=1,max=1），返回选中的卡组g，作为本次检索加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c52404456.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将检索选出的卡g加入其持有者的手牌，原因记为效果（REASON_EFFECT），实现“从卡组把1张「魔偶甜点」魔法·陷阱卡加入手卡”。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示这次检索加入手牌的卡g，使对方能够确认加入手牌的是哪一张「魔偶甜点」魔法·陷阱卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
