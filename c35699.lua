--SPYRAL－ボルテックス
-- 效果：
-- 这张卡不能通常召唤。把自己墓地3张「秘旋谍」卡除外的场合才能特殊召唤。
-- ①：1回合1次，以自己场上1张「秘旋谍」卡和对方场上最多2张卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合发动。自己场上的卡全部破坏，从自己的手卡·卡组·墓地选1只「秘旋谍-花公子」特殊召唤。
function c35699.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e0)
	-- 把自己墓地3张「秘旋谍」卡除外的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c35699.sprcon)
	e1:SetTarget(c35699.sprtg)
	e1:SetOperation(c35699.sprop)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以自己场上1张「秘旋谍」卡和对方场上最多2张卡为对象才能发动。那些卡破坏。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35699,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c35699.destg)
	e2:SetOperation(c35699.desop)
	c:RegisterEffect(e2)
	-- ②：场上的这张卡被战斗·效果破坏送去墓地的场合发动。自己场上的卡全部破坏，从自己的手卡·卡组·墓地选1只「秘旋谍-花公子」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35699,1))
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c35699.spcon)
	e3:SetTarget(c35699.sptg)
	e3:SetOperation(c35699.spop)
	c:RegisterEffect(e3)
end
-- 过滤出墓地中满足『秘旋谍』字段且可作为除外代价的卡。
function c35699.sprfilter(c)
	return c:IsSetCard(0xee) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则条件：自己主要怪兽区有空位，且墓地存在3张可作为代价除外的「秘旋谍」卡。
function c35699.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上主要怪兽区是否有可用空格。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在至少3张符合条件的「秘旋谍」卡（可作为除外代价）。
		and Duel.IsExistingMatchingCard(c35699.sprfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 作为特殊召唤手续，让玩家从墓地选择3张「秘旋谍」卡作为除外代价；选择成功则保存并继续处理。
function c35699.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取墓地中所有可作为除外代价的「秘旋谍」卡集合。
	local g=Duel.GetMatchingGroup(c35699.sprfilter,tp,LOCATION_GRAVE,0,nil)
	-- 弹出提示，要求玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤手续的处理：将之前选择的3张墓地卡除外，完成特殊召唤的代价。
function c35699.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的墓地「秘旋谍」卡表侧表示除外，作为特殊召唤的代价。
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤自己场上表侧表示且属于「秘旋谍」字段的卡，作为①效果的对象候选。
function c35699.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- ①效果的发动条件与取对象处理：确认自己场上有1张表侧「秘旋谍」卡、对方场上有至少1张卡可取对象，然后进入选卡处理。
function c35699.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在1张表侧「秘旋谍」卡可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c35699.desfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在至少1张卡可以作为对象（且最多选2张）。
		and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上选择1张表侧「秘旋谍」卡作为破坏对象。
	local g1=Duel.SelectTarget(tp,c35699.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 弹出提示，要求玩家选择要破坏的卡（对方场上的对象）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1~2张卡作为破坏对象。
	local g2=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,2,nil)
	g1:Merge(g2)
	-- 将已选的所有对象卡登记为本次连锁的破坏效果信息，数量为对象总数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- ①效果的解决处理：取得连锁对象，过滤仍与效果相关的卡并予以破坏。
function c35699.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()>0 then
		-- 将仍然与效果相关的对象卡破坏。
		Duel.Destroy(tg,REASON_EFFECT)
	end
end
-- ②效果的发动条件：这张卡因战斗或效果被破坏并送去墓地，且破坏前位于场上。
function c35699.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 特殊召唤的卡过滤：选择「秘旋谍-花公子」，且该卡可以被玩家用该效果特殊召唤。
function c35699.spfilter(c,e,tp)
	return c:IsCode(41091257) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时登记操作信息：预定破坏自己场上全部卡，并预定从手卡·卡组·墓地特殊召唤1只「秘旋谍-花公子」。
function c35699.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上当前存在的全部卡。
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	if chk==0 then return true end
	-- 登记破坏操作信息：破坏自己场上全部卡，数量为当前张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 登记特殊召唤操作信息：从手卡·卡组·墓地特殊召唤1只「秘旋谍-花公子」。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的解决处理：破坏自己场上全部卡，若破坏成功且场上存在空位，则选1只「秘旋谍-花公子」特殊召唤。
function c35699.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上当前存在的全部卡。
	local dg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,0)
	-- 如果自己场上有卡且破坏成功（破坏操作已执行），则继续特招处理。
	if dg:GetCount()>0 and Duel.Destroy(dg,REASON_EFFECT)>0 then
		-- 检查自己场上主要怪兽区是否有空位，无空位则不再进行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 弹出提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地选择1只符合条件的「秘旋谍-花公子」（且不受王家长眠之谷影响）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35699.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「秘旋谍-花公子」表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
