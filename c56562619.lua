--黒竜の忍者
-- 效果：
-- 这张卡不用「忍者」怪兽或者「忍法」卡的效果不能特殊召唤。
-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1只「忍者」怪兽和1张「忍法」卡送去墓地，以场上1只怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
-- ②：表侧表示的这张卡从场上离开的场合发动。这张卡的效果除外的怪兽尽可能在原本持有者的场上特殊召唤。
function c56562619.initial_effect(c)
	-- 这张卡不用「忍者」怪兽或者「忍法」卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c56562619.splimit)
	c:RegisterEffect(e1)
	-- ①：1回合1次，从手卡以及自己场上的表侧表示的卡之中把1只「忍者」怪兽和1张「忍法」卡送去墓地，以场上1只怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56562619,0))  --"卡片除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCost(c56562619.rmcost)
	e2:SetTarget(c56562619.rmtg)
	e2:SetOperation(c56562619.rmop)
	c:RegisterEffect(e2)
	-- ②：表侧表示的这张卡从场上离开的场合发动。这张卡的效果除外的怪兽尽可能在原本持有者的场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(56562619,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c56562619.spcon)
	e3:SetTarget(c56562619.sptg)
	e3:SetOperation(c56562619.spop)
	c:RegisterEffect(e3)
	-- 这张卡的效果除外的怪兽尽可能在原本持有者的场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(c56562619.clearop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e2:SetLabelObject(ng)
	e3:SetLabelObject(ng)
	e4:SetLabelObject(ng)
	e5:SetLabelObject(ng)
end
-- 限制特殊召唤的手段，仅允许通过「忍者」怪兽或「忍法」卡的效果进行特殊召唤。
function c56562619.splimit(e,se,sp,st)
	return (se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsSetCard(0x2b)) or se:GetHandler():IsSetCard(0x61)
end
-- 过滤手卡或场上表侧表示的、可作为cost送去墓地的「忍者」怪兽，且必须存在可配合的「忍法」卡和合法的除外对象。
function c56562619.cfilter1(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) and c:IsAbleToGraveAsCost()
		-- 检查手卡或场上是否存在除当前怪兽以外的、可作为cost送去墓地的「忍法」卡，且场上存在合法的除外对象。
		and Duel.IsExistingMatchingCard(c56562619.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,c)
end
-- 过滤手卡或场上表侧表示的、可作为cost送去墓地的「忍法」卡，且场上必须存在合法的除外对象。
function c56562619.cfilter2(c,cc)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x61) and c:IsAbleToGraveAsCost()
		-- 检查场上是否存在除当前选择的cost卡以外的、可以被除外的怪兽作为效果对象。
		and Duel.IsExistingTarget(c56562619.rmfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,cc)
end
-- 过滤场上不等于当前选择的cost卡且可以被除外的怪兽。
function c56562619.rmfilter(c,cc)
	return c~=cc and c:IsAbleToRemove()
end
-- ①效果的发动代价：从手卡以及自己场上的表侧表示的卡之中把1只「忍者」怪兽和1张「忍法」卡送去墓地。
function c56562619.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查是否能支付将1只「忍者」怪兽和1张「忍法」卡送去墓地的发动代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c56562619.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的「忍者」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或自己场上的怪兽区选择1只满足条件的「忍者」怪兽。
	local g1=Duel.SelectMatchingCard(tp,c56562619.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local cc=g1:GetFirst()
	-- 提示玩家选择要送去墓地的「忍法」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从手卡或自己场上选择1张满足条件的「忍法」卡（不能与已选择的怪兽是同一张卡）。
	local g2=Duel.SelectMatchingCard(tp,c56562619.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,cc,cc)
	g1:Merge(g2)
	-- 将选择的「忍者」怪兽和「忍法」卡作为发动代价送去墓地。
	Duel.SendtoGrave(g1,REASON_COST)
end
-- ①效果的发动准备：以场上1只怪兽为对象，并设置除外操作信息。
function c56562619.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只可以被除外的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ①效果的处理：将作为对象的怪兽除外，并将其加入记录被除外怪兽的卡组（Group）中。
function c56562619.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与效果相关，则将其表侧表示除外，并确认其成功到达除外区。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		tc:RegisterFlagEffect(56562619,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():AddCard(tc)
	end
end
-- ②效果的发动条件：表侧表示的这张卡从场上离开。
function c56562619.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤带有本卡效果除外标记、且可以被特殊召唤到任意一方场上的怪兽。
function c56562619.spfilter(c,e,tp)
	return c:GetFlagEffect(56562619)~=0
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp))
end
-- 过滤带有本卡效果除外标记、且可以被特殊召唤到自己场上的原本持有者为自己的怪兽。
function c56562619.spfilter1(c,e,tp)
	return c:GetFlagEffect(56562619)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetOwner()==tp
end
-- 过滤带有本卡效果除外标记、且可以被特殊召唤到对方场上的原本持有者为对方的怪兽。
function c56562619.spfilter2(c,e,tp)
	return c:GetFlagEffect(56562619)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and c:GetOwner()==1-tp
end
-- ②效果的发动准备：获取所有被本卡效果除外且满足特殊召唤条件的怪兽，并设置特殊召唤操作信息。
function c56562619.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetLabelObject():Filter(c56562619.spfilter,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤这些被除外的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- ②效果的处理：将被本卡效果除外的怪兽尽可能在原本持有者的场上特殊召唤（包含对「青眼精灵龙」等限制特召数量效果的兼容处理）。
function c56562619.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取对方场上可用的怪兽区域空格数（以自己来看的对方场上）。
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)
	local rg=e:GetLabelObject()
	if (ft1<=0 and ft2<=0) or rg:GetCount()<=0 then return end
	local sg=nil
	local sg1=rg:Filter(c56562619.spfilter1,nil,e,tp)
	local sg2=rg:Filter(c56562619.spfilter2,nil,e,tp)
	local gc1=sg1:GetCount()
	local gc2=sg2:GetCount()
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then
		-- 在「青眼精灵龙」效果适用中，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		if ft1<=0 and gc2>0 then
			-- 在「青眼精灵龙」效果适用且自己场上无空格时，提示玩家选择要特殊召唤的对方怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=sg2:Select(tp,1,1,nil)
		elseif ft2<=0 and gc1>0 then
			-- 在「青眼精灵龙」效果适用且对方场上无空格时，提示玩家选择要特殊召唤的自己怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=sg1:Select(tp,1,1,nil)
		elseif (gc1>0 and ft1>0) or (gc2>0 and ft2>0) then
			-- 在「青眼精灵龙」效果适用且双方场上都有空格时，提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=rg:FilterSelect(tp,c56562619.spfilter,1,1,nil,e,tp)
		end
		if sg~=nil then
			-- 在「青眼精灵龙」效果适用中，将选择的1只怪兽特殊召唤到其原本持有者的场上。
			Duel.SpecialSummon(sg,0,tp,sg:GetFirst():GetOwner(),false,false,POS_FACEUP)
		end
		rg:Clear()
		return
	end
	if gc1>0 and ft1>0 then
		if sg1:GetCount()>ft1 then
			-- 提示玩家选择要特殊召唤到自己场上的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg1=sg1:Select(tp,ft1,ft1,nil)
		end
		local sc=sg1:GetFirst()
		while sc do
			-- 将原本持有者为自己的怪兽逐步特殊召唤到自己场上。
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
			sc=sg1:GetNext()
		end
	end
	if gc2>0 and ft2>0 then
		if sg2:GetCount()>ft2 then
			-- 提示玩家选择要特殊召唤到对方场上的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg2=sg2:Select(tp,ft2,ft2,nil)
		end
		local sc=sg2:GetFirst()
		while sc do
			-- 将原本持有者为对方的怪兽逐步特殊召唤到对方场上。
			Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP)
			sc=sg2:GetNext()
		end
	end
	-- 完成所有怪兽的特殊召唤处理。
	Duel.SpecialSummonComplete()
	rg:Clear()
end
-- 召唤成功时，清空记录被除外怪兽的卡组（Group），防止跨生前状态继承除外记录。
function c56562619.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Clear()
end
