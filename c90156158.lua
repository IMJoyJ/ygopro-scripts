--セイクリッドの超新生
-- 效果：
-- 选择自己墓地2只名字带有「星圣」的怪兽加入手卡。这张卡发动的回合，自己不能进行战斗阶段。
function c90156158.initial_effect(c)
	-- 选择自己墓地2只名字带有「星圣」的怪兽加入手卡。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c90156158.cost)
	e1:SetTarget(c90156158.target)
	e1:SetOperation(c90156158.activate)
	c:RegisterEffect(e1)
end
-- 发动的代价与限制：检查是否满足发动条件，并注册本回合不能进行战斗阶段的誓约效果
function c90156158.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，确认当前不是主要阶段2（若已进入主要阶段2则代表本回合已进行过战斗阶段，不能发动此卡）
	if chk==0 then return Duel.GetCurrentPhase()~=PHASE_MAIN2 end
	-- 选择自己墓地2只名字带有「星圣」的怪兽加入手卡。这张卡发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册本回合不能进行战斗阶段的誓约效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤条件：用于筛选自己墓地中名字带有「星圣」且可以加入手卡的怪兽
function c90156158.filter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的目标选择：确认墓地中存在符合条件的卡，并选择2张作为效果对象
function c90156158.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c90156158.filter(chkc) end
	-- 在发动准备阶段，确认自己墓地中是否存在至少2只符合条件的「星圣」怪兽
	if chk==0 then return Duel.IsExistingTarget(c90156158.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家发送提示信息，要求选择加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地2只符合条件的「星圣」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c90156158.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果处理信息，声明此效果包含将2张目标卡片加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果的实际处理：将选中的对象怪兽加入手卡并给对方确认
function c90156158.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 因效果处理将仍符合条件的对象卡片加入持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,sg)
	end
end
