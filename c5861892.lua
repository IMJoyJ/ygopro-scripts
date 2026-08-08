--アルカナフォースEX－THE LIGHT RULER
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表让这张卡得到以下效果。
-- ●表：这张卡战斗破坏对方怪兽送去墓地时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
-- ●里：这张卡为对象的怪兽的效果·魔法·陷阱卡发动时发动。这张卡的攻击力下降1000，那个发动无效并破坏。
function c5861892.initial_effect(c)
	c:EnableReviveLimit()
	-- 创建效果e1，设置其类型为场上效果，代码为特殊召唤流程，属性为不可无效和不可复制。该效果在手牌区域生效，条件是c5861892.spcon函数返回真值，目标是c5861892.sptg函数，操作是c5861892.spop函数。最后将效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5861892.spcon)
	e1:SetTarget(c5861892.sptg)
	e1:SetOperation(c5861892.spop)
	c:RegisterEffect(e1)
	-- 创建效果e2，设置其属性为不可无效和不可复制，类型为单张效果，代码为特殊召唤条件。然后将该效果注册到卡片c。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 为“秘仪之力”系列怪兽注册抛硬币判定正反面效果的通用触发流程，事件是特殊召唤成功。
	aux.EnableArcanaCoin(c,EVENT_SPSUMMON_SUCCESS)
	-- 创建效果e3，设置描述信息（从aux.Stringid获取），类别为回手牌效果，类型为单张且诱发选发效果，属性为可取对象。代码为战斗破坏怪兽送去墓地时触发，条件是c5861892.thcon函数返回真值，目标是c5861892.thtg函数，操作是c5861892.thop函数。最后将效果注册到卡片c。
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
	-- 创建效果e4，设置描述信息（从aux.Stringid获取），类别为无效和破坏效果，类型为快速效果，代码为连锁触发时生效，属性为伤害计算阶段有效。范围是怪兽区域，条件是c5861892.negcon函数返回真值，目标是c5861892.negtg函数，操作是c5861892.negop函数。最后将效果注册到卡片c。
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
-- 定义过滤函数spfilter，用于判断一张卡是否可以作为送去墓地的素材。
function c5861892.spfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 定义特殊召唤条件函数spcon，检查场上是否存在至少3只可作为送去墓地素材的怪兽。
function c5861892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取满足spfilter条件的怪兽组。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查mg中是否有足够数量（3张）的怪兽可以送去墓地。
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 定义特殊召唤目标函数sptg，选择要送去墓地的怪兽。
function c5861892.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足spfilter条件的怪兽组。
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从mg中选择3张怪兽作为subgroup。
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 定义特殊召唤操作函数spop，将选定的怪兽送去墓地。
function c5861892.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将sg中的卡片送去墓地。
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 定义触发条件函数thcon，检查是否为硬币正面、与战斗相关且目标怪兽在墓地。
function c5861892.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle()
		and c:GetBattleTarget():IsLocation(LOCATION_GRAVE)
end
-- 定义回手牌目标函数thtg，选择要加入手牌的卡片。
function c5861892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查chkc是否是可加入手牌的墓地中的卡片。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地中选择一张卡作为目标。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示将选定的卡片加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 定义回手牌操作函数thop，将选定的卡片加入手牌并确认。
function c5861892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认已加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 定义无效/破坏条件函数negcon，检查是否为取对象效果、目标包含自身且硬币反面。
function c5861892.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取连锁中的目标卡组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0 and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
-- 定义无效/破坏目标函数negtg，设置操作信息并注册flag效果。
function c5861892.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(5861892)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(5861892,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置操作信息，表示要使连锁发动无效。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息，表示要破坏连锁对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 定义无效/破坏操作函数negop，根据条件进行攻击力下降、无效和破坏处理。
function c5861892.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否反面显示、攻击力是否小于1000、是否与效果相关以及当前连锁是否为触发连锁的下一个。
	if c:IsFacedown() or c:GetAttack()<1000 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 then
		return
	end
	-- 创建单张效果e1，设置重置条件，代码为更新攻击力，值为-1000。将该效果注册到卡片c。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 如果无效化成功且目标与效果相关则执行。
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 以REASON_EFFECT原因破坏连锁对象。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
