--魔鏡導士サイコ・バウンダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把1只「人造人-念力震慑者」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
-- ②：这张卡以外的自己怪兽被对方怪兽攻击的伤害计算前才能发动。攻击怪兽和这张卡破坏。
function c65471349.initial_effect(c)
	-- 注册卡片效果中记载了「人造人-念力震慑者」的事实
	aux.AddCodeList(c,77585513)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。把1只「人造人-念力震慑者」或者1张有那个卡名记述的魔法·陷阱卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65471349,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,65471349)
	e1:SetTarget(c65471349.thtg)
	e1:SetOperation(c65471349.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡以外的自己怪兽被对方怪兽攻击的伤害计算前才能发动。攻击怪兽和这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65471349,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,65471350)
	e3:SetCondition(c65471349.descon)
	e3:SetTarget(c65471349.destg)
	e3:SetOperation(c65471349.desop)
	c:RegisterEffect(e3)
end
-- 检索卡片的过滤条件函数
function c65471349.thfilter(c)
	-- 过滤出卡名为「人造人-念力震慑者」的怪兽，或者记载有该卡名的魔法·陷阱卡，且该卡能加入手卡
	return (c:IsCode(77585513) or aux.IsCodeListed(c,77585513) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- ①效果的发动准备，检查卡组中是否存在可检索的卡并设置操作信息
function c65471349.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果的检测阶段，检查自己卡组是否存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65471349.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理的操作信息，表示该效果会将自己卡组的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理，执行检索并加入手卡的操作
function c65471349.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c65471349.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果的发动条件函数，判断是否为自己场上除这张卡以外的怪兽被对方怪兽攻击的伤害计算前
function c65471349.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽
	local ac=Duel.GetAttacker()
	-- 获取当前被攻击的怪兽
	local bc=Duel.GetAttackTarget()
	return bc and bc:IsControler(tp) and bc~=c and ac:IsControler(1-tp)
end
-- ②效果的发动准备，设置破坏的操作信息
function c65471349.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽
	local dc=Duel.GetAttacker()
	local g=Group.FromCards(c,dc)
	if chk==0 then return true end
	-- 设置效果处理的操作信息，表示该效果会破坏这2张卡（攻击怪兽和这张卡）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- ②效果的效果处理，执行破坏攻击怪兽和这张卡的操作
function c65471349.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行攻击的怪兽
	local dc=Duel.GetAttacker()
	if c:IsRelateToEffect(e) and dc:IsRelateToBattle() then
		local g=Group.FromCards(c,dc)
		-- 将攻击怪兽和这张卡因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
