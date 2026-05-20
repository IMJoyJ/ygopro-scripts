--クリビー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把有「栗子球」的卡名记述的1张魔法·陷阱卡加入手卡。
-- ②：1回合1次，自己场上有其他的「栗子球」怪兽存在的场合，对方怪兽的攻击宣言时才能发动。这张卡以外的自己场上的全部怪兽的攻击力直到回合结束时变成0，那次攻击无效。
function c71036835.initial_effect(c)
	-- 在卡片中注册记述的卡片密码「栗子球」
	aux.AddCodeList(c,40640057)
	-- ①：这张卡或者自己的「栗子球」怪兽被战斗破坏时才能发动。从卡组把有「栗子球」的卡名记述的1张魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71036835,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,71036835)
	e1:SetTarget(c71036835.thtg)
	e1:SetOperation(c71036835.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c71036835.thcon)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己场上有其他的「栗子球」怪兽存在的场合，对方怪兽的攻击宣言时才能发动。这张卡以外的自己场上的全部怪兽的攻击力直到回合结束时变成0，那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71036835,1))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetCondition(c71036835.negcon)
	e3:SetOperation(c71036835.negop)
	c:RegisterEffect(e3)
end
-- 过滤条件：有「栗子球」卡名记述的魔法·陷阱卡且可以加入手卡
function c71036835.thfilter(c)
	-- 检查卡片是否记述了「栗子球」卡名、能加入手卡且是魔法或陷阱卡
	return aux.IsCodeListed(c,40640057) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①的发动准备与效果分类注册
function c71036835.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c71036835.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组将1张符合条件的卡加入手卡
function c71036835.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c71036835.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上被破坏的「栗子球」怪兽
function c71036835.cfilter(c,tp)
	return c:IsControler(tp) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0xa4)
end
-- 效果①作为场上诱发效果时的发动条件：检查被战斗破坏的怪兽中是否存在自己的「栗子球」怪兽
function c71036835.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c71036835.cfilter,1,nil,tp)
end
-- 过滤条件：自己场上表侧表示、攻击力在1以上且属于「栗子球」字段的怪兽
function c71036835.atfilter(c)
	return c:IsSetCard(0xa4) and c:IsFaceup() and c:IsAttackAbove(1)
end
-- 效果②的发动条件：非自身回合，且自己场上存在除这张卡以外的「栗子球」怪兽
function c71036835.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己场上是否存在至少1只除这张卡以外的「栗子球」怪兽
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(c71036835.atfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
-- 效果②的效果处理：将其他怪兽攻击力变0并无效攻击
function c71036835.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上除这张卡以外的所有表侧表示「栗子球」怪兽
	local g=Duel.GetMatchingGroup(c71036835.atfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if #g==0 then return end
	-- 遍历需要将攻击力变成0的怪兽组
	for tc in aux.Next(g) do
		-- 这张卡以外的自己场上的全部怪兽的攻击力直到回合结束时变成0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 使当前的攻击无效
	Duel.NegateAttack()
end
