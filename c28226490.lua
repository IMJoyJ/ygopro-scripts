--ティアラメンツ・カレイドハート
-- 效果：
-- 「珠泪哀歌族·雷诺哈特」＋水族怪兽×2
-- 这张卡不能作为融合素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合或者这张卡在场上存在的状态有水族怪兽被效果送去自己墓地的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从卡组把1张「珠泪哀歌族」卡送去墓地。
function c28226490.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册融合召唤手续：素材为「珠泪哀歌族·雷诺哈特」1只＋水族怪兽2只。
	aux.AddFusionProcCodeFun(c,73956664,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),2,true,true)
	-- 这张卡不能作为融合素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	-- ①：这张卡特殊召唤成功的场合或者这张卡在场上存在的状态有水族怪兽被效果送去自己墓地的场合，以对方场上1张卡为对象才能发动。那张卡回到持有者卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28226490,0))  --"对方卡回到持有者卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,28226490)
	e1:SetTarget(c28226490.tdtg)
	e1:SetOperation(c28226490.tdop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c28226490.tdcon)
	c:RegisterEffect(e2)
	-- ②：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤，从卡组把1张「珠泪哀歌族」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(28226490,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,28226491)
	e3:SetCondition(c28226490.spcond)
	e3:SetTarget(c28226490.sptg)
	e3:SetOperation(c28226490.spop)
	c:RegisterEffect(e3)
end
-- 判定一只怪兽是否属于被效果送去己方墓地的水族怪兽：该卡因效果送入墓地、控制者为己方、种族为水族。
function c28226490.cfilter(c,tp)
	return c:IsReason(REASON_EFFECT) and c:IsControler(tp) and c:IsRace(RACE_AQUA)
end
-- ①效果在第二种时点的触发条件：当有怪兽被送去墓地时，若事件组中存在至少1只满足cfilter的水族怪兽（即被效果送去己方墓地的水族怪兽），则条件成立。
function c28226490.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c28226490.cfilter,1,nil,tp)
end
-- ①效果的取对象目标处理：若在连锁处理中确认对象，则要求对象在对方场上且可回卡组；若为发动判定，则检查对方场上是否存在1张可回卡组的卡；满足后提示并选择对方场上1张卡作为对象，同时设置回卡组的操作信息。
function c28226490.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToDeck() and chkc:IsControler(1-tp) end
	-- 发动条件判定：确认对方场上是否存在至少1张能够返回卡组的卡，用于选择对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从对方场上选择1张可返回卡组的卡作为效果对象（取对象），并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次处理的操作信息：包含回卡组类别，对象为所选择的卡，数量为1，用于给其他连锁效果提供判定信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果的处理：取得对象卡，若该卡仍与效果关联，则以效果原因将其返回持有者卡组并洗牌。
function c28226490.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已选择的那张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因返回其持有者卡组，并置于卡组中随机位置后洗牌（SEQ_DECKSHUFFLE）。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的发动条件：判断这张卡被送去墓地时的原因是否为“效果”。
function c28226490.spcond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 筛选卡组中同时满足“属于珠泪哀歌族系列”（set 0x181）且“可以被送去墓地”的卡。
function c28226490.tgfilter(c)
	return c:IsSetCard(0x181) and c:IsAbleToGrave()
end
-- ②效果的发动条件判定：检查自己场上有特殊召唤的空位、这张卡能够被特殊召唤，并且卡组中有可以送去墓地的「珠泪哀歌族」卡；满足全部条件才可发动。
function c28226490.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己主要怪兽区是否还有空位可以特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在至少1张满足tgfilter（属于「珠泪哀歌族」且能送去墓地）的卡。
		and Duel.IsExistingMatchingCard(c28226490.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果包含特殊召唤类别，对象为本卡，数量为1，表示计划把这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：本次效果还包含从卡组把卡送去墓地的类别；数量为1，送墓地者为己方，区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若这张卡仍与连锁关联且成功特殊召唤，则从卡组选择1张「珠泪哀歌族」卡送去墓地；特殊召唤失败则不处理堆墓。
function c28226490.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁关联后，以正面表示将其特殊召唤到自己场上；若特殊召唤成功则继续执行后续堆墓。
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 显示选择提示：请选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从己方卡组选择1张满足tgfilter的「珠泪哀歌族」卡准备送去墓地。
		local g=Duel.SelectMatchingCard(tp,c28226490.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的卡以效果原因直接送入墓地。
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
