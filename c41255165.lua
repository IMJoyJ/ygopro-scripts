--ペンギン忍者
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡反转的场合，以对方场上最多2张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
-- ②：以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
function c41255165.initial_effect(c)
	-- ①：这张卡反转的场合，以对方场上最多2张魔法·陷阱卡为对象才能发动。那些卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41255165,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetTarget(c41255165.target)
	e1:SetOperation(c41255165.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己场上1只「企鹅」怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41255165,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,41255165)
	e2:SetTarget(c41255165.postg)
	e2:SetOperation(c41255165.posop)
	c:RegisterEffect(e2)
end
-- 定义①效果的对象筛选函数：可作为对象的卡必须是魔法·陷阱卡，并且能被效果加入手卡。
function c41255165.thfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果的发动时处理：若指定对象则校验该对象是否合法；在确认发动时检查场上是否存在可选对象；然后提示玩家选择对方场上1~2张魔法·陷阱卡作为对象，并设置回手牌的操作信息。
function c41255165.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and c41255165.thfilter(chkc) end
	-- 效果发动条件的合法性检查：确认对方场上至少存在1张可以回手牌的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c41255165.thfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出选择提示，让玩家从符合条件的卡片中选出要返回手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家从对方场上选择1~2张满足thfilter的魔法·陷阱卡，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c41255165.thfilter,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 将当前连锁的操作信息设置为“回手牌”类别，对象为已选卡片，数量为已选数量，方便其他卡进行连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①效果处理时：取得连锁记录的对象卡，过滤出仍与该效果相关的卡，然后将它们全部送回持有者手卡。
function c41255165.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁发动时记录的对象卡片组（即对方场上被选中的魔法·陷阱卡）。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if tg then
		local sg=tg:Filter(Card.IsRelateToEffect,nil,e)
		-- 将过滤后仍有效的对象卡以“效果”为原因送回持有者手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 定义②效果的对象筛选函数：对象必须是自己场上表侧表示的「企鹅」怪兽，且可以变成里侧守备表示。
function c41255165.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x5a) and c:IsCanTurnSet()
end
-- ②效果的发动时处理：校验对象合法性，确认自己场上存在可选怪兽；提示玩家选择1只符合条件的「企鹅」怪兽作为对象，并设置变更表示形式的操作信息。
function c41255165.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c41255165.filter(chkc) end
	-- 效果发动条件的合法性检查：确认自己场上至少存在1只表侧表示的「企鹅」怪兽且可以变成里侧表示，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c41255165.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出选择提示，让玩家从符合条件的怪兽中选出要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家从自己场上选择1只满足filter的「企鹅」怪兽，并将其登记为本连锁的对象。
	local g=Duel.SelectTarget(tp,c41255165.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 将当前连锁的操作信息设置为“变更表示形式”类别，对象数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果处理时：取得对象怪兽，若它仍与效果相关且在自己场上表侧表示，则将其变成里侧守备表示。
function c41255165.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽（因为只取1只，所以取得第一只目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将对象怪兽的表示形式更改为里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
