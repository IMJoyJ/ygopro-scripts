--ティンクル・セイクリッド
-- 效果：
-- 「闪烁星圣」的②的效果1回合只能使用1次。
-- ①：以自己场上1只「星圣」怪兽为对象才能发动。那只怪兽的等级上升1星或者2星。
-- ②：这张卡在墓地存在的场合，把自己墓地1只「星圣」怪兽除外才能发动。墓地的这张卡加入手卡。
function c35544402.initial_effect(c)
	-- ①：以自己场上1只「星圣」怪兽为对象才能发动。那只怪兽的等级上升1星或者2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35544402,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c35544402.target)
	e1:SetOperation(c35544402.operation)
	c:RegisterEffect(e1)
	-- 「闪烁星圣」的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，把自己墓地1只「星圣」怪兽除外才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35544402,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35544402)
	e2:SetCost(c35544402.thcost)
	e2:SetTarget(c35544402.thtg)
	e2:SetOperation(c35544402.thop)
	c:RegisterEffect(e2)
end
-- ①效果的取对象筛选：选择自己场上表侧表示、属于「星圣」系列且等级大于0的怪兽。
function c35544402.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:GetLevel()>0
end
-- ①效果的发动条件判定与取对象处理：确认自己场上有满足条件的「星圣」怪兽，并选择其中1只作为对象。
function c35544402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35544402.filter(chkc) end
	-- 发动时判定：自己场上有满足条件的「星圣」怪兽存在，才能发动。
	if chk==0 then return Duel.IsExistingTarget(c35544402.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 给操作者显示“请选择表侧表示的卡”的提示，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从自己场上选择1只表侧表示且满足条件的「星圣」怪兽作为①效果的对象。
	Duel.SelectTarget(tp,c35544402.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果发动后的处理：获取对象怪兽，并让玩家选择使其等级上升1星或2星，最后给对象赋予等级上升的效果。
function c35544402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的等级上升1星或者2星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 让玩家选择等级上升1星还是2星；选择0则上升1星，否则上升2星。
		if Duel.SelectOption(tp,aux.Stringid(35544402,2),aux.Stringid(35544402,3))==0 then  --"等级上升1星/等级上升2星"
			e1:SetValue(1)
		else e1:SetValue(2) end
		tc:RegisterEffect(e1)
	end
end
-- ②效果代价的筛选：选择自己墓地中属于「星圣」系列、是怪兽且可以作为代价除外的卡。
function c35544402.thfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的发动代价处理：从自己墓地选择1只「星圣」怪兽除外作为发动代价。
function c35544402.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价判定：自己墓地存在1只符合条件的「星圣」怪兽才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c35544402.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给操作者显示“请选择要除外的卡”的提示，用于选择代价。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足条件的「星圣」怪兽作为②效果发动的代价。
	local g=Duel.SelectMatchingCard(tp,c35544402.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的「星圣」怪兽以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的发动目标判定：这张卡在墓地且可以被加入手卡；同时设置回手牌的操作信息。
function c35544402.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理时将墓地的这张卡加入手卡的操作信息（回手牌分类）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍在墓地且与效果关联，则将其加入手卡，并让对方确认。
function c35544402.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 让对方确认加入手卡的这张卡。
		Duel.ConfirmCards(1-tp,c)
	end
end
