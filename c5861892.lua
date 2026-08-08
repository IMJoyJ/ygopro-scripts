--アルカナフォースEX－THE LIGHT RULER
-- 效果：
-- 这张卡不能通常召唤。把自己场上3只怪兽送去墓地的场合才能特殊召唤。
-- ①：这张卡特殊召唤的场合发动。进行1次投掷硬币，那个里表让这张卡得到以下效果。
-- ●表：这张卡战斗破坏对方怪兽送去墓地时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。
-- ●里：这张卡为对象的怪兽的效果·魔法·陷阱卡发动时发动。这张卡的攻击力下降1000，那个发动无效并破坏。
function c5861892.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤条件效果，要求将自己场上3只怪兽送去墓地才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c5861892.spcon)
	e1:SetTarget(c5861892.sptg)
	e1:SetOperation(c5861892.spop)
	c:RegisterEffect(e1)
	-- 不能通常召唤，只能通过特殊召唤条件进行特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 注册抛硬币判定正反面效果，根据正反面决定后续效果
	aux.EnableArcanaCoin(c,EVENT_SPSUMMON_SUCCESS)
	-- 战斗破坏对方怪兽送去墓地时发动的效果，将自己墓地1张卡加入手卡
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
	-- 受到对方怪兽的效果·魔法·陷阱卡发动时发动的效果，使自身攻击力下降1000并无效该发动且破坏
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
-- 过滤场上可以作为特殊召唤代价送去墓地的怪兽
function c5861892.spfilter(c)
	return c:IsAbleToGraveAsCost()
end
-- 检查场上是否有满足条件的3只怪兽可以作为特殊召唤的素材
function c5861892.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家场上所有可以送去墓地的怪兽组
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否能选出3只怪兽组成满足条件的子集
	return mg:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
-- 选择3只怪兽作为特殊召唤的素材并设置为效果对象
function c5861892.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有可以送去墓地的怪兽组
	local mg=Duel.GetMatchingGroup(c5861892.spfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从满足条件的怪兽中选择3只组成子集
	local sg=mg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤操作，将选中的怪兽送去墓地
function c5861892.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽组以特殊召唤原因送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 判断是否为正面效果触发条件，即抛硬币结果为正面且参与战斗的怪兽被破坏送入墓地
function c5861892.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==1 and c:IsRelateToBattle()
		and c:GetBattleTarget():IsLocation(LOCATION_GRAVE)
end
-- 设置选择目标的效果，选择自己墓地一张可加入手牌的卡
function c5861892.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 检查是否有满足条件的墓地卡可以作为目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标卡
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果，将选中的墓地卡加入手牌并确认对方可见
function c5861892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认所选卡的加入手牌动作
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 判断是否为反面效果触发条件，即抛硬币结果为反面且该效果针对自身发动
function c5861892.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡组信息
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(c) then return false end
	return c:GetFlagEffectLabel(FLAG_ID_ARCANA_COIN)==0 and (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER))
end
-- 设置操作信息，准备无效并破坏对方发动的效果
function c5861892.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(5861892)==0 end
	if c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		c:RegisterFlagEffect(5861892,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
	-- 设置操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 设置操作信息为破坏发动的卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果，使自身攻击力下降1000并无效对方发动的效果且破坏
function c5861892.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断是否满足执行效果的条件，包括自身正面朝上、攻击力不低于1000、处于连锁处理中等
	if c:IsFacedown() or c:GetAttack()<1000 or not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 then
		return
	end
	-- 创建一个使自身攻击力下降1000的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-1000)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 如果成功使对方发动无效，则破坏该发动的卡
		if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
			-- 破坏目标卡
			Duel.Destroy(eg,REASON_EFFECT)
		end
	end
end
