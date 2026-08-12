--フルール・ド・バロネス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：只在这张卡在场上表侧表示存在才有1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
-- ③：双方的准备阶段，以自己墓地1只9星以下的怪兽为对象才能发动。这张卡回到持有者的额外卡组，作为对象的怪兽特殊召唤。
function c84815190.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84815190,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c84815190.destg)
	e1:SetOperation(c84815190.desop)
	c:RegisterEffect(e1)
	-- ②：只在这张卡在场上表侧表示存在才有1次，魔法·陷阱·怪兽的效果发动时才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84815190,1))
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,84815190)
	e2:SetCondition(c84815190.discon)
	e2:SetTarget(c84815190.distg)
	e2:SetOperation(c84815190.disop)
	c:RegisterEffect(e2)
	-- ③：双方的准备阶段，以自己墓地1只9星以下的怪兽为对象才能发动。这张卡回到持有者的额外卡组，作为对象的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(84815190,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOEXTRA)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c84815190.sptg)
	e3:SetOperation(c84815190.spop)
	c:RegisterEffect(e3)
end
-- 效果①（破坏）的发动准备阶段，检查并选择场上的1张卡作为对象，并设置破坏操作信息
function c84815190.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在可以作为效果对象的卡片
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“破坏选中的卡片”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果①（破坏）的效果处理函数，破坏作为对象的卡
function c84815190.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将作为对象的卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果②（无效并破坏）的发动条件判断函数
function c84815190.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自身未被战斗破坏，且当前连锁的效果发动可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 效果②（无效并破坏）的发动准备阶段，注册“已发动过”的标记，并设置无效与破坏的操作信息
function c84815190.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(84815190,3))  --"已发动过效果"
	-- 设置效果处理信息为“使该效果的发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息为“破坏该发动效果的卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果②（无效并破坏）的效果处理函数
function c84815190.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效该效果的发动，并确认该卡在连锁中关系仍成立
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 因效果将该发动效果的卡片破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤自己墓地中等级9以下且可以特殊召唤的怪兽
function c84815190.spfilter(c,e,tp)
	return c:IsLevelBelow(9) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（回额外特召墓地怪兽）的发动准备阶段，检查并选择墓地中的怪兽作为对象，设置特召和回额外卡组的操作信息
function c84815190.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c84815190.spfilter(chkc,e,tp) end
	-- 检查自身离开场上后，是否有可用的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查自己墓地是否存在满足条件的、可作为对象的怪兽
		and Duel.IsExistingTarget(c84815190.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and e:GetHandler():IsAbleToExtra() end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c84815190.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为“特殊召唤选中的怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息为“将自身送回额外卡组”
	Duel.SetOperationInfo(0,CATEGORY_TOEXTRA,e:GetHandler(),1,0,0)
end
-- 效果③（回额外特召墓地怪兽）的效果处理函数
function c84815190.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的要特殊召唤的墓地怪兽对象
	local tc=Duel.GetFirstTarget()
	-- 确认自身和目标怪兽与效果的关系，将自身送回额外卡组，并确认自身已成功回到额外卡组
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
