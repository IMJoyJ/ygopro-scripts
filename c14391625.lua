--ヴィサス＝サンサーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「维萨斯-斯塔弗罗斯特」使用。
-- ②：以自己的场上·墓地·除外状态的「维萨斯」怪兽任意数量为对象才能发动。那些「维萨斯」怪兽回到卡组，这张卡从手卡特殊召唤。这张卡的攻击力上升这个效果回去的种类×400。
-- ③：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c14391625.initial_effect(c)
	-- 为这张卡注册在场上·墓地时卡名当作「维萨斯-斯塔弗罗斯特」（卡号56099748）使用的效果，对应①效果。
	aux.EnableChangeCode(c,56099748,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：以自己的场上·墓地·除外状态的「维萨斯」怪兽任意数量为对象才能发动。那些「维萨斯」怪兽回到卡组，这张卡从手卡特殊召唤。这张卡的攻击力上升这个效果回去的种类×400。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14391625,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,14391625)
	e1:SetTarget(c14391625.sptg)
	e1:SetOperation(c14391625.spop)
	c:RegisterEffect(e1)
	-- ③：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_NONTUNER)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c14391625.tnval)
	c:RegisterEffect(e2)
end
-- 定义「维萨斯」怪兽的筛选条件：属于「维萨斯」系列、是怪兽、表侧表示（或在非场上区域）、可以返回卡组、且能成为效果对象。
function c14391625.retfilter(c,e)
	return c:IsSetCard(0x198) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- ②的发动时点处理：从自己场上·墓地·除外状态筛选符合条件的「维萨斯」怪兽，检查此卡可特殊召唤且选择素材后仍有空位；然后让玩家选择任意数量作为对象，并设置返回卡组与特殊召唤的操作信息。
function c14391625.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED) and c14391625.retfilter(chkc,e) end
	local c=e:GetHandler()
	-- 获取自己场上·墓地·除外状态中满足retfilter条件的所有「维萨斯」怪兽，作为可选择对象的候选集合。
	local g=Duel.GetMatchingGroup(c14391625.retfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 发动合法性检查：此卡必须能被特殊召唤，且候选集合中存在至少1张卡，并且选择任意数量返回卡组后自己场上仍有可用的怪兽区空格。
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:CheckSubGroup(aux.mzctcheck,1,#g,tp) end
	-- 向玩家显示选择提示，提示内容为“请选择要返回卡组的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从候选集合中选择1至全部数量的「维萨斯」怪兽，并通过aux.mzctcheck保证选择后仍有怪兽区空位；返回选中的卡组tg。
	local tg=g:SelectSubGroup(tp,aux.mzctcheck,false,1,#g,tp)
	-- 将选中的卡组tg登记为当前连锁的对象，供效果处理时使用。
	Duel.SetTargetCard(tg)
	-- 登记操作信息：本次效果将把tg这些卡返回卡组（数量为#tg），用于卡组返回相关时点检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	-- 登记操作信息：本次效果还包含将此卡（c）特殊召唤（数量1），用于特殊召唤相关检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②的实际处理：将仍与效果相关的对象卡返回持有者卡组并洗切；计算实际返回的卡的卡名种类数×400作为攻击力上升值；若此卡仍可特殊召唤则将其表侧表示特殊召唤，并赋予其攻击力上升效果。
function c14391625.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取出发动时选择的对象，并过滤掉已与效果失去联系的卡（确保仍可处理）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些对象卡以效果原因返回持有者卡组，并使用洗切顺序（若回主卡组则洗牌）。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被送回卡组/额外卡组的卡，统计不同卡名种类数，乘以400得到本次效果应上升的攻击力。
	local atk=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA):GetClassCount(Card.GetCode)*400
	-- 若攻击力上升值大于0、此卡仍与效果关联，且成功将此卡从手卡以表侧攻击表示特殊召唤到自己场上，则继续执行加攻处理。
	if atk>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这张卡的攻击力上升这个效果回去的种类×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③的判断函数：当此卡作为同调素材时，仅当此卡的控制者与另一只同调素材怪兽的控制者相同，才将此卡视为调整以外的怪兽（EFFECT_NONTUNER生效）。
function c14391625.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
