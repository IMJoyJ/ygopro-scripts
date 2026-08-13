--世壊挽歌
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从卡组把1只「吠陀」怪兽加入手卡。
-- ②：这张卡在墓地存在，场上有「维萨斯-斯塔弗罗斯特」存在的状态，自己场上的表侧表示的调整被战斗·效果破坏的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽加入手卡。
function c17462320.initial_effect(c)
	-- 将该卡记载的另一张卡「维萨斯-斯塔弗罗斯特」（卡号56099748）注册进代码列表，用于后续判定卡名关联。
	aux.AddCodeList(c,56099748)
	-- ①：从卡组把1只「吠陀」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17462320,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c17462320.target)
	e1:SetOperation(c17462320.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在，场上有「维萨斯-斯塔弗罗斯特」存在的状态，自己场上的表侧表示的调整被战斗·效果破坏的场合，把这张卡除外，以那之内的1只为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17462320,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,17462320)
	e2:SetCondition(c17462320.thcon)
	-- 设置②效果发动时需将墓地的这张卡除外作为发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c17462320.thtg)
	e2:SetOperation(c17462320.thop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤器：筛选卡组中为「吠陀」系列、怪兽卡且可以加入手卡的卡。
function c17462320.thfilter(c)
	return c:IsSetCard(0x19a) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果发动前的合法性与操作信息设定：确认卡组存在符合条件的「吠陀」怪兽，并声明将进行回手牌处理。
function c17462320.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查自己卡组是否存在至少1只可加入手卡的「吠陀」怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c17462320.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理的操作信息：将把1张卡从卡组加入持有者手卡，供后续效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时，从卡组选择1只「吠陀」怪兽加入手卡，并让对手确认。
function c17462320.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组中筛选并选择1只符合thfilter条件的「吠陀」怪兽。
	local g=Duel.SelectMatchingCard(tp,c17462320.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义场上监测过滤器：检查是否存在表侧表示的「维萨斯-斯塔弗罗斯特」（卡号56099748）。
function c17462320.filter(c)
	return c:IsCode(56099748) and c:IsFaceup()
end
-- 定义被破坏怪兽的判定条件：在被破坏前是自己场上表侧表示、位于怪兽区、是调整且不是衍生物，并且被战斗或效果破坏。
function c17462320.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_TUNER)~=0 and not c:IsType(TYPE_TOKEN)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动条件：场上存在「维萨斯-斯塔弗罗斯特」，本次被破坏的怪兽中存在满足条件的调整，且被破坏的怪兽中不包含墓地的这张「世坏挽歌」自身。
function c17462320.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」。
	return Duel.IsExistingMatchingCard(c17462320.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and eg:IsExists(c17462320.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 定义对象过滤器：被破坏的怪兽中可作为效果对象且可以加入手卡的卡。
function c17462320.tgfilter(c,e)
	return c:IsCanBeEffectTarget(e) and c:IsAbleToHand()
end
-- ②效果发动时，从满足条件的被破坏怪兽中选择1只作为对象（若只有1只则自动选取），并设置将对象加入手卡的操作信息。
function c17462320.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(c17462320.cfilter,nil,tp):Filter(c17462320.tgfilter,nil,e)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 显示选择提示，提示玩家选择效果对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选中的卡设置为当前连锁的效果对象。
	Duel.SetTargetCard(g)
	-- 设置效果处理信息：将1只对象卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理时，若对象卡仍与效果关联，则将其加入持有者手卡。
function c17462320.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果处理时选取的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
