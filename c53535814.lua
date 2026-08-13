--氷結界の浄玻璃
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要自己场上有其他的「冰结界」怪兽存在，每次对方支付基本分来让卡的效果发动让对方失去500基本分。
-- ②：以自己墓地的「冰结界」怪兽以及对方墓地的卡各最多2张为对象才能发动。那些卡回到卡组。
-- ③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
function c53535814.initial_effect(c)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，每次对方支付基本分来让卡的效果发动让对方失去500基本分。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_PAY_LPCOST)
	e0:SetRange(LOCATION_MZONE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c53535814.regop)
	c:RegisterEffect(e0)
	-- ①：只要自己场上有其他的「冰结界」怪兽存在，每次对方支付基本分来让卡的效果发动让对方失去500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c53535814.llpop)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：以自己墓地的「冰结界」怪兽以及对方墓地的卡各最多2张为对象才能发动。那些卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53535814,0))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,53535814)
	e2:SetTarget(c53535814.tdtg)
	e2:SetOperation(c53535814.tdop)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。③：自己场上有「冰结界」怪兽存在的场合，把墓地的这张卡除外，以场上1只攻击表示怪兽为对象才能发动。那只怪兽变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53535814,1))
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,53535815)
	-- 设置③效果的发动代价为把墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetCondition(c53535814.poscon)
	e3:SetTarget(c53535814.postg)
	e3:SetOperation(c53535814.posop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡为表侧表示且属于「冰结界」字段，用于判断场上是否存在「冰结界」怪兽。
function c53535814.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x2f)
end
-- ①效果的触发标记操作：当对方支付基本分来发动卡的效果时，若己方场上有其他表侧表示的「冰结界」怪兽，则给本卡记录一个标记，供连锁处理结束时判定扣血。
function c53535814.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and re:IsActivated()
		-- 并且己方场上存在至少1张其他表侧表示的「冰结界」怪兽（排除本卡自身）。
		and Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,c) then
		c:RegisterFlagEffect(53535814,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
	end
end
-- ①效果的扣血操作：在连锁处理结束时，若本卡带有上次支付的标记且己方场上仍有其他表侧表示的「冰结界」怪兽，则向对方展示本卡并使对方失去500基本分。
function c53535814.llpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ep==1-tp and c:GetFlagEffect(53535814)>0
		-- 并且处理时己方场上仍然存在至少1张其他表侧表示的「冰结界」怪兽。
		and Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,c) then
		-- 向全场玩家展示本卡，提示冰结界的净玻璃的效果正在适用。
		Duel.Hint(HINT_CARD,0,53535814)
		-- 将对方玩家的基本分减少500。
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-500)
	end
end
-- 过滤条件：自己墓地的「冰结界」怪兽且可以返回卡组，用于②效果选择自己墓地的对象。
function c53535814.tdfilter(c)
	return c:IsSetCard(0x2f) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ②效果的发动条件与取对象：检查自己墓地存在至少1只冰结界怪兽、对方墓地存在至少1张可回卡组的卡，然后分别选择1~2张作为对象。
function c53535814.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 发动时确认自己墓地存在至少1只可回卡组的「冰结界」怪兽，可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c53535814.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 并且对方墓地存在至少1张可以返回卡组的卡，可以作为对象。
		and Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil) end
	-- 显示选择提示，让玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择1~2张「冰结界」怪兽作为效果对象。
	local g1=Duel.SelectTarget(tp,c53535814.tdfilter,tp,LOCATION_GRAVE,0,1,2,nil)
	-- 显示选择提示，让玩家选择对方墓地要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方墓地选择1~2张可以返回卡组的卡作为效果对象。
	local g2=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,2,nil)
	g1:Merge(g2)
	-- 将已选对象合并后，设置本次连锁的操作信息为“回卡组”，数量为对象总数。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g1,g1:GetCount(),0,0)
end
-- ②效果处理：将效果对象中仍与效果相关的卡返回持有者卡组。
function c53535814.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得本效果的对象卡，并过滤出仍与效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 将过滤后的对象卡返回其持有者卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ③效果的发动条件判断：自己场上有「冰结界」怪兽存在才能发动。
function c53535814.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在表侧表示的「冰结界」怪兽（本卡在墓地，无需排除自身）。
	return Duel.IsExistingMatchingCard(c53535814.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：通常是攻击表示且可以变更表示形式的怪兽，用于③效果选择对象。
function c53535814.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- ③效果的取对象函数：确认场上存在可变更表示形式的攻击表示怪兽，并选择1只作为对象。
function c53535814.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c53535814.posfilter(chkc) end
	-- 发动时确认场上存在至少1只攻击表示且可变更表示形式的怪兽，可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c53535814.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，让玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 从双方场上选择1只攻击表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c53535814.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为“改变表示形式”，对象为所选怪兽。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ③效果处理：将对象怪兽变成表侧守备表示。
function c53535814.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式变更为表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end
