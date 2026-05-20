--アルカナフォースEX－THE LIGHT RULER
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的3只怪兽送去墓地的场合才能特殊召唤。这张卡特殊召唤成功时，进行1次投掷硬币得到以下效果。
-- ●表：战斗破坏对方怪兽送去墓地时，可以从自己墓地把1张卡加入手卡。
-- ●里：这张卡为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。每次这个效果把卡的发动无效，这张卡的攻击力下降1000。
function c5861892.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己场上存在的3只怪兽送去墓地的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5861892.spcon)
	e1:SetTarget(c5861892.sptg)
	e1:SetOperation(c5861892.spop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 注册特殊召唤成功时进行投掷硬币的效果。
	aux.EnableArcanaCoin(c,EVENT_SPSUMMON_SUCCESS)
	-- ●表：战斗破坏对方怪兽送去墓地时，可以从自己墓地把1张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5861892,1))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c5861892.thcon)
	e3:SetTarget(c5861892.thtg)
	e3:SetOperation(c5861892.thop)
	c:RegisterEffect(e3)
	-- ●里：这张卡为对象的效果怪兽的效果·魔法·陷阱卡的发动无效并破坏。每次这个效果把卡的发动无效，这张卡的攻击力下降1000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(5861892,2))  --"无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_F)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c5861892.negcon)
	e4:SetTarget(c5861892.negtg)
	e4:SetOperation(c5861892.negop)
	c:RegisterEffect(e4)
end
-- 过滤能作为特殊召唤手续送去墓地的怪兽。
function c5861892.spfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件的判定函数，检查场上是否有3只可送去墓地的怪兽。
function c5861892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可以送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查这些怪兽中是否存在3只，且将它们送去墓地后能留出足够的怪兽区域空位。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤的手续处理，选择并记录要送去墓地的3只怪兽。
function c5861892.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可以送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择3只送去墓地后能留出足够怪兽区域空位的怪兽。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的手续，将选中的怪兽送去墓地。
function c5861892.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽作为特殊召唤的手续送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查硬币投掷结果是否为表（正面），且自身战斗破坏了怪兽并送去墓地。
function c5861892.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle()
		and c:GetBattleTarget():IsLocation(LOCATION_GRAVE)
end
-- 效果发动时的目标选择，确认墓地有可加入手牌的卡并进行取对象。
function c5861892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查自己墓地是否存在可以加入手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张可以加入手牌的卡作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果的处理为将选中的卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理，将选中的墓地卡片加入手牌并给对方确认。
function c5861892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 检查硬币投掷结果是否为里（反面），且当前连锁的效果是否以这张卡为对象。
function c5861892.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被选为对象的卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0 and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
-- 效果发动时的处理，设置无效与破坏的操作信息。
function c5861892.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(5861892)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(5861892,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置连锁信息，表示该效果的处理为使发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置连锁信息，表示该效果的处理为破坏该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理，使发动无效并破坏，随后降低自身1000点攻击力。
function c5861892.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否表侧表示、攻击力是否在1000以上、是否与效果相关，以及当前连锁是否紧跟在要无效的效果之后。
	if c:IsFacedown() or c:GetAttack()<1000 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 then
		return
	end
	-- 尝试使该效果的发动无效，若成功则继续处理。
	if Duel.NegateActivation(ev) then
		if re:GetHandler():IsRelateToEffect(re) then
			-- 破坏被无效发动的卡片。
			Duel.Destroy(re:GetHandler(),REASON_EFFECT)
		end
		-- 每次这个效果把卡的发动无效，这张卡的攻击力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		c:RegisterEffect(e1)
	end
end
