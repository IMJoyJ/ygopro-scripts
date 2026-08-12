--刀神－不知火
-- 效果：
-- 不死族调整＋调整以外的不死族怪兽1只以上
-- 自己对「刀神-不知火」1回合只能有1次特殊召唤。
-- ①：1回合1次，以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到卡组，持有那个攻击力以下的攻击力的对方场上的怪兽全部变成守备表示。这个效果在对方回合也能发动。
-- ②：这张卡被除外的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的攻击力下降500。
function c57288064.initial_effect(c)
	c:SetSPSummonOnce(57288064)
	-- 添加同调召唤手续：需要不死族调整 + 1只以上调整以外的不死族怪兽
	aux.AddSynchroProcedure(c,c57288064.synfilter,aux.NonTuner(c57288064.synfilter),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以除外的1只自己的不死族怪兽为对象才能发动。那只怪兽回到卡组，持有那个攻击力以下的攻击力的对方场上的怪兽全部变成守备表示。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57288064,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c57288064.postg)
	e1:SetOperation(c57288064.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的场合，以对方场上1只怪兽为对象才能发动。那只怪兽的攻击力下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57288064,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_REMOVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetTarget(c57288064.target)
	e2:SetOperation(c57288064.operation)
	c:RegisterEffect(e2)
end
-- 过滤同调素材：必须是不死族怪兽
function c57288064.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 过滤作为效果①对象的不死族怪兽：必须是除外区表侧表示、是不死族、攻击力大于等于0、能回到卡组，且对方场上存在至少1只持有其攻击力以下攻击力的表侧攻击表示怪兽
function c57288064.filter(c,tp)
	local atk=c:GetAttack()
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE) and atk>=0 and c:IsAbleToDeck()
		-- 检查对方场上是否存在至少1只满足过滤条件（持有该怪兽攻击力以下攻击力且能改变表示形式）的怪兽
		and Duel.IsExistingMatchingCard(c57288064.posfilter,tp,0,LOCATION_MZONE,1,nil,atk)
end
-- 过滤要改变表示形式的对方怪兽：必须是表侧攻击表示、可以改变表示形式，且攻击力在指定数值以下
function c57288064.posfilter(c,atk)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition() and c:IsAttackBelow(atk)
end
-- 效果①的发动准备（Target阶段）：检查合法对象、提示玩家选择、将选择的卡作为效果对象并设置操作信息（回卡组）
function c57288064.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c57288064.filter(chkc,tp) end
	-- 检查自己除外区是否存在至少1只满足条件的可作为对象的不死族怪兽
	if chk==0 then return Duel.IsExistingTarget(c57288064.filter,tp,LOCATION_REMOVED,0,1,nil,tp) end
	-- 给玩家发送提示信息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 玩家选择1只除外区的满足条件的不死族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57288064.filter,tp,LOCATION_REMOVED,0,1,1,nil,tp)
	-- 设置当前连锁的操作信息：将选择的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果①的处理（Operation阶段）：将作为对象的怪兽送回卡组，若成功，则将对方场上持有该怪兽攻击力以下攻击力的怪兽全部变成守备表示
function c57288064.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适应此效果，并将其送回卡组洗牌，若成功返回卡组则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 获取对方场上所有满足条件（表侧攻击表示、攻击力在返回卡组怪兽的攻击力以下）的怪兽
		local g=Duel.GetMatchingGroup(c57288064.posfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttack())
		-- 将获取到的对方怪兽全部变成表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
-- 效果②的发动准备（Target阶段）：检查对方场上是否存在表侧表示怪兽、提示玩家选择并将其作为效果对象
function c57288064.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果②的处理（Operation阶段）：使作为对象的对方怪兽攻击力下降500
function c57288064.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的对方怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力下降500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-500)
		tc:RegisterEffect(e1)
	end
end
