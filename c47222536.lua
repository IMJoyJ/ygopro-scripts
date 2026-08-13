--黒の魔導陣
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡确认。可以从那之中把1只「黑魔术师」或者1张有那个卡名记述的魔法·陷阱卡给对方观看并加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
-- ②：自己场上有「黑魔术师」召唤·特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
function c47222536.initial_effect(c)
	-- 将黑魔术师（46986414）登记为这张卡的效果文本中记载的卡名，供后续检索“有那个卡名记述的魔法·陷阱卡”时判断。
	aux.AddCodeList(c,46986414)
	-- 这个卡名的①②的效果1回合各能使用1次。①：作为这张卡的发动时的效果处理，从自己卡组上面把3张卡确认。可以从那之中把1只「黑魔术师」或者1张有那个卡名记述的魔法·陷阱卡给对方观看并加入手卡。剩下的卡用喜欢的顺序回到卡组上面。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,47222536)
	e1:SetTarget(c47222536.target)
	e1:SetOperation(c47222536.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己场上有「黑魔术师」召唤·特殊召唤的场合，以对方场上1张卡为对象才能发动。那张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47222536,1))  --"对方场上1张卡除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,47222537)
	e2:SetCondition(c47222536.rmcon)
	e2:SetTarget(c47222536.rmtg)
	e2:SetOperation(c47222536.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义①效果的发动条件函数：在效果发动时检查自己卡组是否至少有3张卡，否则无法发动（因为需要确认卡组顶3张）。
function c47222536.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，确认自己卡组数量大于2（即至少3张），这是发动①效果的前提条件。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- 定义①效果中可加入手卡的卡片的筛选函数：符合条件的卡为「黑魔术师」本身，或者效果文本中记载了「黑魔术师」卡名的魔法·陷阱卡，并且该卡能够加入手卡。
function c47222536.filter(c)
	-- 筛选条件具体为：卡片是黑魔术师（46986414），或者是效果文本中记载了黑魔术师卡名的魔法·陷阱卡，且该卡当前没有被“不能加入手卡”的效果限制。
	return (aux.IsCodeListed(c,46986414) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(46986414)) and c:IsAbleToHand()
end
-- 定义①效果处理函数：确认卡组顶3张，若其中有符合条件的卡且玩家选择加入手卡，则选1张加入手卡并向对方展示，剩余卡由玩家按喜欢的顺序放回卡组顶；若选择不加或没有符合条件的卡，则将3张卡按喜欢的顺序放回卡组顶。
function c47222536.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己卡组数量不少于3张，不足则终止处理（防御性检查）。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	-- 获取自己卡组最上方的3张卡作为一组卡片，用于确认和选择。
	local g=Duel.GetDecktopGroup(tp,3)
	-- 让发动玩家确认这3张卡的卡面内容。
	Duel.ConfirmCards(tp,g)
	-- 检查这3张卡中是否存在符合条件的卡，并且玩家选择“是”（是否把1张卡加入手卡），满足则进入加入手卡的处理。
	if g:IsExists(c47222536.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(47222536,0)) then  --"是否把1张卡加入手卡？"
		-- 显示选择提示“请选择要加入手牌的卡”，引导玩家选择要加入手卡的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:FilterSelect(tp,c47222536.filter,1,1,nil)
		-- 禁止系统自动检查卡组洗切，因为后续会手动放回卡组顶并调整顺序，避免触发不必要的洗切。
		Duel.DisableShuffleCheck()
		-- 将选中的那张卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切自己手卡，以隐藏手卡顺序信息（加入手卡后不影响持有者，但需要随机化手牌顺序）。
		Duel.ShuffleHand(tp)
		-- 让玩家将自己卡组剩余的最上方2张卡按喜欢的顺序放回卡组顶（先选择的卡在上），对应“剩下的卡用喜欢的顺序回到卡组上面”。
		Duel.SortDecktop(tp,tp,2)
	-- 当没有选择加入手卡或不存在符合条件的卡时，将3张卡全部按喜欢的顺序放回卡组顶。
	else Duel.SortDecktop(tp,tp,3) end
end
-- 定义②效果触发条件中“自己场上有黑魔术师”的判定函数：要求怪兽表侧表示、卡号为黑魔术师、控制者为自己。
function c47222536.cfilter(c,tp)
	return c:IsFaceup() and c:IsCode(46986414) and c:IsControler(tp)
end
-- 定义②效果的发动条件：在召唤/特殊召唤成功时，若召唤成功的怪兽中存在表侧表示且自己控制的「黑魔术师」，则满足发动条件。
function c47222536.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47222536.cfilter,1,nil,tp)
end
-- 定义②效果的取对象和发动合法性处理：从对方场上选择1张可以被除外的卡作为对象，并设置除外相关的操作信息。
function c47222536.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToRemove() end
	-- ②效果发动合法性检查：对方场上有至少1张可以被除外的卡，才能发动该取对象效果。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示“请选择要除外的卡”，引导玩家选择对象卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方场上选择1张可以被除外的卡，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息，宣布将对选择的对象卡进行除外（数量1），供其他卡的效果连锁判断使用。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 定义②效果处理函数：将取对象所指定的对方场上的那张卡除外。
function c47222536.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象卡（对方场上被选择的那张卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以表侧表示形式、效果原因除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
