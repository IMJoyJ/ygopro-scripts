--ダーク・ジェネラル フリード
-- 效果：
-- 这张卡不能特殊召唤。自己场上表侧表示存在的暗属性怪兽为对象的魔法卡的效果无效并破坏。只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星的暗属性怪兽加入手卡。
function c70676581.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 自己场上表侧表示存在的暗属性怪兽为对象的魔法卡的效果无效
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(c70676581.distg)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示存在的暗属性怪兽为对象的魔法卡的效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c70676581.disop)
	c:RegisterEffect(e3)
	-- 自己场上表侧表示存在的暗属性怪兽为对象的魔法卡的效果无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(c70676581.distg)
	c:RegisterEffect(e4)
	-- 只要这张卡在场上表侧表示存在，可以作为自己的抽卡阶段时进行通常抽卡的代替，从自己卡组把1只4星的暗属性怪兽加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(70676581,1))  --"检索"
	e5:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_PREDRAW)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c70676581.condition)
	e5:SetTarget(c70676581.target)
	e5:SetOperation(c70676581.operation)
	c:RegisterEffect(e5)
end
-- 过滤并确定作为对象的魔法卡是否指向自己场上表侧表示的暗属性怪兽
function c70676581.distg(e,c)
	if c:GetCardTargetCount()==0 or not c:IsType(TYPE_SPELL) then return false end
	return c:GetCardTarget():IsExists(c70676581.disfilter,1,nil,e:GetHandlerPlayer())
end
-- 过滤自己场上表侧表示的暗属性怪兽
function c70676581.disfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 在连锁处理时，使以自己场上表侧表示暗属性怪兽为对象的魔法卡效果无效并破坏
function c70676581.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	-- 获取当前连锁中作为对象的所有卡片
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then return end
	if g:IsExists(c70676581.disfilter,1,nil,tp) then
		-- 如果成功使该效果无效，且该卡在场上（或与效果相关联）
		if Duel.NegateEffect(ev,true) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏该魔法卡
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
	end
end
-- 代替抽卡效果的发动条件
function c70676581.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合
	return tp==Duel.GetTurnPlayer()
end
-- 过滤卡组中4星的暗属性且能加入手牌的怪兽
function c70676581.filter(c)
	return c:IsLevel(4) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 代替抽卡效果的发动准备与合法性检测
function c70676581.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前置阶段，确认玩家是否能进行通常抽卡，且卡组中存在符合条件的怪兽
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) and Duel.IsExistingMatchingCard(c70676581.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 代替抽卡效果的具体处理过程
function c70676581.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认玩家当前是否能进行通常抽卡，若不能则不处理
	if not aux.IsPlayerCanNormalDraw(tp) then return end
	-- 使玩家放弃本回合抽卡阶段的通常抽卡
	aux.GiveUpNormalDraw(e,tp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只符合过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c70676581.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()~=0 then
		-- 将选中的怪兽加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
