--呪眼の死徒 サリエル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功时才能发动。从卡组把「咒眼之死徒 沙利叶」以外的1张「咒眼」卡加入手卡。
-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。这个效果在对方回合也能发动。
-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选自己场上1张卡破坏。
function c82466274.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「咒眼之死徒 沙利叶」以外的1张「咒眼」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82466274,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c82466274.thtg)
	e1:SetOperation(c82466274.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「太阴之咒眼」装备的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82466274,1))  --"对方1只怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,82466274)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCost(c82466274.descost1)
	e2:SetCondition(c82466274.descon1)
	e2:SetTarget(c82466274.destg1)
	e2:SetOperation(c82466274.desop1)
	c:RegisterEffect(e2)
	-- ③：这张卡的②的效果发动的场合，下次的准备阶段发动。选自己场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82466274,2))  --"自己1张卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c82466274.descon2)
	e3:SetTarget(c82466274.destg2)
	e3:SetOperation(c82466274.desop2)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「咒眼之死徒 沙利叶」以外的「咒眼」卡片且能加入手牌的过滤函数
function c82466274.thfilter(c)
	return c:IsSetCard(0x129) and not c:IsCode(82466274) and c:IsAbleToHand()
end
-- 效果①（检索卡组「咒眼」卡）的发动目标确认与操作信息设置函数
function c82466274.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c82466274.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索卡组「咒眼」卡）的效果处理函数
function c82466274.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡片
	local g=Duel.SelectMatchingCard(tp,c82466274.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动代价函数，用于给自身注册标记以记录效果发动时的回合数，以便效果③在下次准备阶段触发
function c82466274.descost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 判定当前是否为准备阶段
	if Duel.GetCurrentPhase()==PHASE_STANDBY then
		-- 若在准备阶段发动，则注册持续2个准备阶段的标记并记录当前回合数，以确保在“下次”准备阶段触发
		e:GetHandler():RegisterFlagEffect(82466274,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,2,Duel.GetTurnCount())
	else
		e:GetHandler():RegisterFlagEffect(82466274,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,EFFECT_FLAG_OATH,1,0)
	end
end
-- 效果②的发动条件函数，检查自身装备卡中是否存在「太阴之咒眼」
function c82466274.descon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsCode,1,nil,44133040)
end
-- 效果②（破坏对方特殊召唤的怪兽）的对象选择与操作信息设置函数
function c82466274.destg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
	-- 检查对方场上是否存在可以作为对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_SPECIAL)
	-- 设置连锁的操作信息，表示该效果会破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②（破坏对方特殊召唤的怪兽）的效果处理函数
function c82466274.desop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果③（下次准备阶段破坏自己场上1张卡）的发动条件函数，检查是否存在非本回合注册的标记
function c82466274.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tid=e:GetHandler():GetFlagEffectLabel(82466274)
	-- 确认标记存在且记录的回合数不是当前回合（即必须是“下次”准备阶段）
	return tid and tid~=Duel.GetTurnCount()
end
-- 效果③（破坏自己场上1张卡）的发动目标确认与操作信息设置函数
function c82466274.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取自己场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	-- 设置连锁的操作信息，表示该效果会破坏自己场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果③（破坏自己场上1张卡）的效果处理函数
function c82466274.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上的所有卡片
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 选中自己场上要破坏的卡片并显示选中动画
		Duel.HintSelection(sg)
		-- 将选中的自己场上的卡片因效果破坏
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
