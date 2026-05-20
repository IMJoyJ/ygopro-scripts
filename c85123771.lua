--ゴブリン降下部隊
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡攻击表示特殊召唤的场合，以对方场上1只效果怪兽为对象才能发动。这张卡变成守备表示。作为对象的怪兽的效果在这张卡表侧守备表示存在期间无效化。
-- ②：这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，丢弃1张手卡才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（特殊召唤时改变表示形式并无效对方怪兽）和②效果（对方特殊召唤怪兽时墓地回收）
function s.initial_effect(c)
	-- ①：这张卡从手卡攻击表示特殊召唤的场合，以对方场上1只效果怪兽为对象才能发动。这张卡变成守备表示。作为对象的怪兽的效果在这张卡表侧守备表示存在期间无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"无效怪兽"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方场上有怪兽特殊召唤的场合，丢弃1张手卡才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤对方场上未被无效的效果怪兽
function s.disfilter(c)
	return c:IsType(TYPE_EFFECT) and not c:IsDisabled()
end
-- 检查①效果的发动条件：自身从手卡以表侧攻击表示特殊召唤成功
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsAttackPos() and c:IsPreviousLocation(LOCATION_HAND)
end
-- ①效果的发动准备：检查并选择对方场上1只效果怪兽作为对象
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查已选择的对象是否仍在场上、由对方控制且符合无效化条件
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 检查对方场上是否存在至少1只符合条件的可选效果怪兽
	if chk==0 then return Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要无效的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择对方场上1只效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息，表示该效果包含无效卡片的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果的处理：将自身变为守备表示，并使作为对象的怪兽效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() or not c:IsCanChangePosition() then return end
	-- 将自身变为表侧守备表示
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)
	-- 获取之前选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsDefensePos() and c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and not tc:IsImmuneToEffect(e) then
		c:SetCardTarget(tc)
		-- 作为对象的怪兽的效果在这张卡表侧守备表示存在期间无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetCondition(s.rcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e2)
		end
	end
	-- 作为对象的怪兽的效果在这张卡表侧守备表示存在期间无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetCondition(s.recon)
	e2:SetOperation(s.reop)
	c:RegisterEffect(e2)
end
-- 检查自身是否依然保持对目标怪兽的靶向关系（用于维持无效状态）
function s.rcon(e)
	return e:GetOwner():IsHasCardTarget(e:GetHandler())
end
-- 检查自身是否从守备表示变为了表侧攻击表示
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_DEFENSE) and c:IsFaceup() and c:IsAttackPos()
end
-- 解除自身对目标怪兽的靶向关系，从而恢复其效果
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	Card.CancelCardTarget(c,tc)
end
-- 检查②效果的发动条件：对方场上有怪兽特殊召唤
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- ②效果的发动代价：丢弃1张手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要丢弃的手卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的发动准备：检查自身是否能加入手卡并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置连锁处理信息，表示该效果包含将自身加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果的处理：将墓地的这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其加入手卡
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
