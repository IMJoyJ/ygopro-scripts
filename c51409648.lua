--撃鉄竜リンドブルム
-- 效果：
-- 「阿不思的落胤」＋兽族·兽战士族·鸟兽族怪兽
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：融合·同调·超量·连接怪兽的效果发动时才能发动。那个效果无效。那之后，可以让场上1只怪兽回到手卡。
-- ②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「阿不思的落胤」为对象才能发动。那只怪兽和这张卡之内的1只特殊召唤，另1只除外。
local s,id,o=GetID()
-- 初始化该卡的效果注册：启用苏生限制（只能用融合召唤方式从额外卡组特殊召唤），添加融合素材要求；注册①的无效并回手效果（e1）和②的墓地特召/除外效果（e2），二者分别通过id和id+o实现1回合各1次。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以1只卡号为68468459的「阿不思的落胤」和1只兽族·兽战士族·鸟兽族怪兽作为融合素材。
	aux.AddFusionProcCodeFun(c,68468459,aux.FilterBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),1,true,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：融合·同调·超量·连接怪兽的效果发动时才能发动。那个效果无效。那之后，可以让场上1只怪兽回到手卡。
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
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方回合，这张卡在墓地存在的场合，以自己墓地1只「阿不思的落胤」为对象才能发动。那只怪兽和这张卡之内的1只特殊召唤，另1只除外。
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
-- ①效果的发动条件：对方发动的效果必须是怪兽效果，且该效果来源于融合·同调·超量·连接怪兽，同时该连锁效果可以被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
		-- 追加判定该连锁（ev）的效果能够被无效，若不能无效则不满足①的发动条件。
		and Duel.IsChainDisablable(ev)
end
-- ①目标设定：本效果不取对象，chk==0时直接允许发动；随后将当前连锁的eg登记为下次处理要无效的效果来源（操作信息）。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将操作信息设为“无效当前连锁的eg所代表的效果”，数量为1，供连锁结算和相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- ①效果处理：先取得场上所有能回手的怪兽；然后无效对应连锁。若无效成功且存在可回手怪兽，再询问玩家是否回手；玩家选择后，中断效果时点并把选中的怪兽送回手卡。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有能够加入手卡的怪兽，作为可回手对象的选择候选集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 先使当前连锁的效果无效；如果无效成功且存在可回手怪兽，则让玩家选择是否要执行‘回手’的后续处理。
	if Duel.NegateEffect(ev) and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选1只怪兽回到手卡？"
		-- 向玩家显示“请选择要返回手牌的卡”的选择提示，并写入选卡缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 中断当前效果处理，使接下来的回手处理与前面的无效处理视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的卡送回持有者手卡，处理原因为效果。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件函数：仅在当前回合玩家不是这张卡的控制者（即对方回合）时，才可以从墓地发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是tp，即满足‘对方回合’的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ②的候选对象过滤器：目标必须是「阿不思的落胤」，且目标与本卡组成的集合中存在‘一张可特殊召唤、另一张可除外’的组合，保证二选一操作合法。
function s.filter(c,ec,e,tp)
	if not c:IsCode(68468459) then return false end
	local g=Group.FromCards(c,ec)
	return g:IsExists(s.ofilter,1,nil,g,e,tp)
end
-- 判断集合g中的某张卡c能够被当前效果特殊召唤，并且集合中还存在另一张可以除外的卡；两者缺一不可。
function s.ofilter(c,g,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:IsExists(Card.IsAbleToRemove,1,c)
end
-- ②目标判定：选取对象阶段只接受自己墓地中满足s.filter的「阿不思的落胤」；在发动前检查阶段则确认主怪兽区有空位且墓地存在合法对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,c,e,tp) end
	-- 检查自己场上是否存在可用的主怪兽区空格，以保证后续能够进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足s.filter的「阿不思的落胤」可供选择为对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,c,e,tp) end
	-- 向玩家显示“请选择要操作的卡”的选择提示，并写入选卡缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从自己墓地选择1张满足s.filter的「阿不思的落胤」作为效果对象，并将其登记为当前连锁的目标。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,c,e,tp)
	-- 登记除外类操作信息：将选中的目标组g作为效果处理时可能被除外的候选（具体除外哪张在处理时择定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 登记特殊召唤类操作信息：将选中的目标组g作为效果处理时可能被特殊召唤的候选（若处理时选择特召本卡，则实际特召的是本卡而非g）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：确认有空格后，将连锁对象「阿不思的落胤」与本卡组成仍与效果关联的集合，由玩家选择其中1只表侧特殊召唤，成功后把另一只除外。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次确认主怪兽区有空格，若没有空格则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取出当前连锁的目标卡（「阿不思的落胤」）并与效果持有者（这张卡）合并，过滤出仍与本次效果存在关联的卡，得到候选集合fg。
	local fg=(Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)+e:GetHandler()):Filter(Card.IsRelateToEffect,nil,e)
	if fg:GetCount()~=2 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，并写入选卡缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=fg:FilterSelect(tp,s.ofilter,1,1,nil,fg,e,tp)
	-- 从候选集合中选择1只可被特殊召唤的卡表侧表示特殊召唤；若特召成功，则将另一张卡除外。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)>0 then Duel.Remove(fg-sg,POS_FACEUP,REASON_EFFECT) end
end
