--王神鳥シムルグ
-- 效果：
-- 包含鸟兽族怪兽的怪兽2只以上
-- 这个卡名的③的效果1回合只能使用1次。这张卡不能作为连接素材。
-- ①：这张卡以及这张卡所连接区的鸟兽族怪兽不会成为对方的效果的对象。
-- ②：这张卡被战斗破坏的场合，可以作为代替把自己场上1张「斯摩夫」卡破坏。
-- ③：自己·对方的结束阶段才能发动。把持有没有使用的自己·对方的魔法与陷阱区域数量以下的等级的1只鸟兽族怪兽从手卡·卡组特殊召唤。
function c72330894.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2到3只怪兽作为素材，且必须满足lcheck过滤条件（包含鸟兽族怪兽）。
	aux.AddLinkProcedure(c,nil,2,3,c72330894.lcheck)
	-- 这张卡不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡以及这张卡所连接区的鸟兽族怪兽不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c72330894.etlimit)
	-- 设置不能成为效果对象的效果来源为对方（即不会成为对方效果的对象）。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗破坏的场合，可以作为代替把自己场上1张「斯摩夫」卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c72330894.desreptg)
	e3:SetOperation(c72330894.desrepop)
	c:RegisterEffect(e3)
	-- ③：自己·对方的结束阶段才能发动。把持没有使用的自己·对方的魔法与陷阱区域数量以下的等级的1只鸟兽族怪兽从手卡·卡组特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(72330894,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,72330894)
	e4:SetTarget(c72330894.sptg)
	e4:SetOperation(c72330894.spop)
	c:RegisterEffect(e4)
end
-- 连接素材的过滤条件：素材组中必须存在至少1只鸟兽族怪兽。
function c72330894.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_WINDBEAST)
end
-- 过滤不能成为对象的目标：自身，或者处于自身连接区且表侧表示的鸟兽族怪兽。
function c72330894.etlimit(e,c)
	return c==e:GetHandler() or (c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and e:GetHandler():GetLinkedGroup():IsContains(c))
end
-- 过滤可用于代替破坏的卡：自己场上表侧表示、属于「斯摩夫」字段、且可以被效果破坏的卡（排除已确定被破坏的卡）。
function c72330894.desfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0x12d) and c:IsDestructable(e)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- 代替破坏效果的发动条件：自身因战斗被破坏，且场上存在可代替破坏的「斯摩夫」卡。
function c72330894.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在至少1张满足代替破坏过滤条件的「斯摩夫」卡。
		and Duel.IsExistingMatchingCard(c72330894.desfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	-- 询问玩家是否发动代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择用于代替破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家选择自己场上1张满足过滤条件的「斯摩夫」卡。
		local g=Duel.SelectMatchingCard(tp,c72330894.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏效果的具体处理：将选中的代替卡破坏。
function c72330894.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了「王神鸟 斯摩夫」的代替破坏效果。
	Duel.Hint(HINT_CARD,0,72330894)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 破坏选中的代替卡，以此代替自身的战斗破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
-- 过滤可特殊召唤的怪兽：等级在指定数值以下、可以特殊召唤的鸟兽族怪兽。
function c72330894.spfilter(c,e,tp,lv)
	return c:IsRace(RACE_WINDBEAST) and c:IsLevelBelow(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤魔法与陷阱区域的卡（排除额外怪兽区域等，只计算常规魔陷格0-4）。
function c72330894.seqfilter(c)
	return c:GetSequence()<5
end
-- 获取双方场上未使用的魔法与陷阱区域的总数。
function c72330894.getct()
	-- 计算双方未使用的魔陷格数量（双方魔陷格总数10减去已使用的魔陷格数量）。
	return 5*2-Duel.GetMatchingGroupCount(c72330894.seqfilter,0,LOCATION_SZONE,LOCATION_SZONE,nil)
end
-- 特殊召唤效果的发动准备：检查是否有可用怪兽区域、未使用的魔陷格数量是否大于0，以及手卡或卡组中是否存在可特殊召唤的鸟兽族怪兽。
function c72330894.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=c72330894.getct()
		-- 检查未使用的魔陷格数量是否大于0，且自己场上是否有可用的怪兽区域。
		return ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查自己的手卡或卡组中是否存在等级在未使用魔陷格数量以下的鸟兽族怪兽。
			and Duel.IsExistingMatchingCard(c72330894.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp,ct)
	end
	-- 设置连锁处理的操作信息，表示将从手卡或卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 特殊召唤效果的具体处理：从手卡或卡组选择1只满足条件的鸟兽族怪兽特殊召唤。
function c72330894.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local ct=c72330894.getct()
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只等级在未使用魔陷格数量以下的鸟兽族怪兽。
	local g=Duel.SelectMatchingCard(tp,c72330894.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,ct)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
