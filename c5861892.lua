--アルカナフォースEX－THE LIGHT RULER
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表让这张卡得到以下效果。
-- ●表：这张卡战斗破坏对方怪兽送去墓地时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
-- ●里：这张卡为对象的怪兽的效果·魔法·陷阱卡发动时发动。这张卡的攻击力下降1000，那个发动无效并破坏。
function c5861892.initial_effect(c)
	c:EnableReviveLimit()
	-- 把自己场上3只怪兽送去墓地的场合才能特殊召唤。
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
	-- 注册特殊召唤成功时进行1次投掷硬币判定正反面的通用效果。
	aux.EnableArcanaCoin(c,EVENT_SPSUMMON_SUCCESS)
	-- ●表：这张卡战斗破坏对方怪兽送去墓地时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
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
	-- ●里：这张卡为对象的怪兽的效果·魔法·陷阱卡发动时发动。这张卡的攻击力下降1000，那个发动无效并破坏。
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
-- 特殊召唤Cost过滤条件：检查卡片是否可以送去墓地。
function c5861892.spfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 特殊召唤条件检查：检查自己场上是否存在3只可作为Cost送去墓地且送去墓地后能腾出空余怪兽区域的怪兽。
function c5861892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取自己场上所有可作为Cost送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查选择3只怪兽送去墓地后是否能腾出足够怪兽区空位以特殊召唤此卡。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 特殊召唤Cost选择处理：在自己场上选择3只符合条件的怪兽送去墓地，并保存选择结果。
function c5861892.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有可作为Cost送去墓地的怪兽。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 显示提示信息：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从符合条件的怪兽中选择3只作为送去墓地的Cost。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤Cost执行：将选择的3只怪兽送去墓地。
function c5861892.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽作为特殊召唤的Cost送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 表侧（正位）效果发动条件：当前判定为表侧效果、自身仍在战斗中且战斗破坏的对方怪兽已被送去墓地。
function c5861892.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle()
		and c:GetBattleTarget():IsLocation(LOCATION_GRAVE)
end
-- 表侧（正位）效果的发动准备与选择目标：在自己墓地选择1张卡作为对象。
function c5861892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查自己墓地是否存在至少1张可以加入手牌的卡。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示提示信息：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张可以加入手牌的卡作为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将选中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 表侧（正位）效果处理：将选中的墓地卡片加入手牌并向对方确认。
function c5861892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 里侧（逆位）效果发动条件：当前判定为里侧效果，且连锁发动的怪兽效果或魔法·陷阱卡的发动以该卡为对象。
function c5861892.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取触发连锁的效果选择的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0 and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
-- 里侧（逆位）效果发动准备：设置使发动无效和破坏的操作信息。
function c5861892.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(5861892)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(5861892,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置效果处理信息：将触发效果的发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置效果处理信息：破坏触发效果的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 里侧（逆位）效果处理：自身攻击力下降1000，并将目标效果的发动无效并破坏。
function c5861892.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否表侧表示、攻击力是否不小于1000、是否仍与效果相关以及连锁顺序是否正确。
	if c:IsFacedown() or c:GetAttack()<1000 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 then
		return
	end
	-- 这张卡的攻击力下降1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 使该效果的发动无效，并检查被无效的卡是否仍与效果相关。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 将发动被无效的卡破坏。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
