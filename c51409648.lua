--撃鉄竜リンドブルム
-- 效果：
-- 「阿不思的落胤」＋兽族·兽战士族·鸟兽族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：融合·同调·超量·连接怪兽的效果发动时才能发动。那个效果无效。那之后，可以让场上1只怪兽回到手卡。
-- ②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「阿不思的落胤」为对象才能发动。那只怪兽和这张卡之内的1只特殊召唤，另1只除外。
local s,id,o=GetID()
-- 初始化卡片效果，设置融合召唤条件并注册两个诱发即时效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号68468459的怪兽与1只满足种族为兽族·兽战士族·鸟兽族的怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),1,true,true)
	-- 效果①：融合·同调·超量·连接怪兽的效果发动时才能发动。那个效果无效。那之后，可以让场上1只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 效果②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「阿不思的落胤」为对象才能发动。那只怪兽和这张卡之内的1只特殊召唤，另1只除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方怪兽卡的效果发动时且该效果的发动者是融合·同调·超量·连接怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		-- 检查连锁是否可以被无效
		and Duel.IsChainDisablable(ev)
end
-- 效果①的发动时处理：设置操作信息为使效果无效
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的处理：使连锁效果无效，并可选择让场上1只怪兽回到手卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有能回到手卡的怪兽
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断是否成功使效果无效、是否有可选怪兽、玩家是否选择让怪兽回手
	if Duel.NegateEffect(ev) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选1只怪兽回到手卡？"
		-- 提示玩家选择要返回手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，防止错时点
		Duel.BreakEffect()
		-- 将选定的怪兽送入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：在对方回合且此卡在墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选符合条件的墓地「阿不思的落胤」怪兽
function s.filter(c,ec,e,tp)
	if not c:IsCode(68468459) then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(s.ofilter,1,nil,g,e,tp)
end
-- 判断该怪兽是否可以特殊召唤并能除外其他怪兽
function s.ofilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToRemove,1,c)
end
-- 效果②的发动时处理：设置目标选择和操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,c,e,tp) end
	-- 检查是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在符合条件的目标怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
	-- 设置操作信息为除外目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的处理：特殊召唤1只怪兽并除外另一只
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取连锁中被选择的目标卡和此卡组成的组，并筛选与效果相关的卡
	local fg=(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)+e:GetHandler()):Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=fg:FilterSelect(tp,s.ofilter,1,1,nil,fg,e,tp)
	-- 若成功特殊召唤，则将剩余卡除外
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then Duel.Remove(fg-sg,POS_FACEUP,REASON_EFFECT) end
end
