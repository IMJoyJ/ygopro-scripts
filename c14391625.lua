--ヴィサス＝サンサーラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「维萨斯-斯塔弗罗斯特」使用。
-- ②：以自己的场上·墓地·除外状态的「维萨斯」怪兽任意数量为对象才能发动。那些「维萨斯」怪兽回到卡组，这张卡从手卡特殊召唤。这张卡的攻击力上升这个效果回去的种类×400。
-- ③：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
function c14391625.initial_effect(c)
	-- 使该卡在场上或墓地时视为「维萨斯-斯塔弗罗斯特」使用
	aux.EnableChangeCode(c,56099748,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：以自己的场上·墓地·除外状态的「维萨斯」怪兽任意数量为对象才能发动。那些「维萨斯」怪兽回到卡组，这张卡从手卡特殊召唤。这张卡的攻击力上升这个效果回去的种类×400。
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
-- 定义用于筛选符合条件的「维萨斯」怪兽的过滤函数
function c14391625.retfilter(c,e)
	return c:IsSetCard(0x198) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
		and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 定义效果的发动处理函数，用于设置效果的目标和操作信息
function c14391625.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED) and c14391625.retfilter(chkc,e) end
	local c=e:GetHandler()
	-- 获取玩家场上、墓地、除外区中所有符合条件的「维萨斯」怪兽
	local g=Duel.GetMatchingGroup(c14391625.retfilter,tp,LOCATION_MZONE+LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e)
	-- 判断是否满足发动条件：手卡特殊召唤条件 + 选择的怪兽数量满足要求
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:CheckSubGroup(aux.mzctcheck,1,#g,tp) end
	-- 提示玩家选择要送回卡组的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	-- 从符合条件的怪兽中选择满足条件的子集
	local tg=g:SelectSubGroup(tp,aux.mzctcheck,false,1,#g,tp)
	-- 设置选中的怪兽为效果的对象
	Duel.SetTargetCard(tg)
	-- 设置操作信息：将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,tg,#tg,0,0)
	-- 设置操作信息：将自身从手卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 定义效果的处理函数，用于执行效果的后续操作
function c14391625.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中被选为对象的卡，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将选中的怪兽送回卡组并洗牌
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 计算因送回卡组的怪兽数量而获得的攻击力提升值
	local atk=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA):GetClassCount(Card.GetCode)*400
	-- 若攻击力提升值大于0且自身仍在场上，则将自身特殊召唤
	if atk>0 and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 给自身增加攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 定义用于判断是否可以将自身当作非调整怪兽使用的函数
function c14391625.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
