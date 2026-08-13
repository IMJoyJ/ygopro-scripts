--究極宝玉陣
-- 效果：
-- ①：自己的「宝玉兽」怪兽被战斗破坏时，从手卡·卡组以及自己场上的表侧表示的卡之中把「宝玉兽」卡7种类各1张送去墓地才能发动。把1只「究极宝玉神」融合怪兽当作融合召唤从额外卡组特殊召唤。
-- ②：自己场上的表侧表示的「究极宝玉神」怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。选自己墓地的「宝玉兽」怪兽任意数量当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
function c36328300.initial_effect(c)
	-- ①：自己的「宝玉兽」怪兽被战斗破坏时，从手卡·卡组以及自己场上的表侧表示的卡之中把「宝玉兽」卡7种类各1张送去墓地才能发动。把1只「究极宝玉神」融合怪兽当作融合召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c36328300.condition)
	e1:SetCost(c36328300.cost)
	e1:SetTarget(c36328300.target)
	e1:SetOperation(c36328300.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的「究极宝玉神」怪兽因对方的效果从场上离开的场合，把墓地的这张卡除外才能发动。选自己墓地的「宝玉兽」怪兽任意数量当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c36328300.plcon)
	-- 为第二个效果设置发动代价：把墓地中的这张卡除外（aux.bfgcost为通用除外自身代价函数）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c36328300.pltg)
	e2:SetOperation(c36328300.plop)
	c:RegisterEffect(e2)
end
-- 定义①效果触发判定用的过滤条件：被战斗破坏的怪兽原本是「宝玉兽」怪兽，且破坏前控制权属于自己。
function c36328300.confilter(c,tp)
	return c:IsPreviousSetCard(0x1034) and c:IsPreviousControler(tp)
end
-- ①效果的发动条件：本次被战斗破坏的怪兽集合中存在满足confilter（我方「宝玉兽」怪兽）的卡。
function c36328300.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36328300.confilter,1,nil,tp)
end
-- 定义作为cost的卡牌过滤条件：是「宝玉兽」卡，并且是表侧表示或不在场上（即手牌·卡组的卡），且可以作为代价送去墓地。
function c36328300.cfilter(c)
	return c:IsSetCard(0x1034) and (c:IsFaceup() or not c:IsOnField()) and c:IsAbleToGraveAsCost()
end
-- 定义额外区域判定用的过滤条件：若选择这张卡作为素材，则这张卡离场后自己仍有可用的额外怪兽区域来融合召唤。
function c36328300.exfilter(c,tp)
	-- 返回指定卡离场后是否仍有额外怪兽区域空格（用于额外卡组融合怪兽出场）。
	return Duel.GetLocationCountFromEx(tp,tp,c,TYPE_FUSION)>0
end
-- 定义在SelectSubGroup中使用的辅助检查：选出的整组素材离场后仍能保证额外怪兽区域可用。
function c36328300.gselect(g,tp)
	-- 返回选出的整组卡片离场后是否仍有额外怪兽区域空格。
	return Duel.GetLocationCountFromEx(tp,tp,g,TYPE_FUSION)>0
end
-- ①效果的发动代价：从手牌·卡组以及自己场上的表侧表示卡中，选择7种类各1张「宝玉兽」卡送去墓地；同时需保证素材送墓后仍能进行融合召唤。
function c36328300.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得所有符合条件的「宝玉兽」卡作为候选：来自自己手牌、卡组以及场上表侧表示的卡（场上只取表侧，非场上无表侧限制）。
	local g=Duel.GetMatchingGroup(c36328300.cfilter,tp,LOCATION_ONFIELD+LOCATION_HAND+LOCATION_DECK,0,nil)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=7
		-- cost可行性追加条件：当前已有额外怪兽区空格，或存在某张候选素材离场后能腾出额外怪兽区空格，确保7张素材送墓后仍有位置融合召唤。
		and (Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)>0 or g:IsExists(c36328300.exfilter,1,nil,tp)) end
	-- 提示发动者选择要送去墓地的卡（显示「请选择要送去墓地的卡」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 将SelectSubGroup的附加检查设为dncheck，以确保选出的7张卡卡名互不相同（对应7种类各1张）。
	aux.GCheckAdditional=aux.dncheck
	local rg=g:SelectSubGroup(tp,c36328300.gselect,false,7,7,tp)
	-- 选择结束后清除附加检查函数，避免影响后续其他选择。
	aux.GCheckAdditional=nil
	-- 将选出的7张「宝玉兽」卡以代价形式送入墓地。
	Duel.SendtoGrave(rg,REASON_COST)
end
-- 定义要特殊召唤的融合怪兽过滤条件：融合怪兽、属于「究极宝玉神」字段、能够以融合召唤方式被效果特殊召唤，且满足融合素材条件。
function c36328300.filter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x2034) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial()
end
-- ①效果的目标：检查额外卡组是否存在满足条件的「究极宝玉神」融合怪兽可特殊召唤，检查融合素材限制；可行则登记特殊召唤操作信息。
function c36328300.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标阶段检查：场上不存在「必须作为融合素材」等限制导致无法进行融合召唤的卡。
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL)
		-- 目标阶段检查：额外卡组存在至少1只符合条件的「究极宝玉神」融合怪兽，才能发动。
		and Duel.IsExistingMatchingCard(c36328300.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 登记本次效果将进行的特殊召唤操作：数量1、来源额外卡组、分类为特殊召唤（融合召唤），供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：从额外卡组选择1只符合条件的「究极宝玉神」融合怪兽，当作融合召唤特殊召唤；清除素材信息后以融合召唤方式表侧特殊召唤，并进行融合召唤成功后的处理。
function c36328300.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认：额外怪兽区仍有空格且无融合素材限制，否则不处理。
	if Duel.GetLocationCountFromEx(tp,tp,nil,TYPE_FUSION)<=0 or not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_FMATERIAL) then return end
	-- 提示发动者选择要特殊召唤的卡（显示「请选择要特殊召唤的卡」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter条件的「究极宝玉神」融合怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c36328300.filter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		tc:SetMaterial(nil)
		-- 将选择的对象以融合召唤方式（SUMMON_TYPE_FUSION）表侧表示特殊召唤到自己的怪兽区域；nocheck/nolimit为false表示仍需检查常规召唤条件与苏生限制。
		Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
-- 定义②效果触发判定用过滤条件：离场的怪兽必须是「究极宝玉神」怪兽、离场前控制者为自己、表侧表示、因对方玩家效果并且以效果原因从自己的主要怪兽区离场。
function c36328300.plcfilter(c,tp)
	return c:IsPreviousSetCard(0x2034) and c:IsPreviousControler(tp)
		and c:IsPreviousPosition(POS_FACEUP) and c:GetReasonPlayer()==1-tp
		and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- ②效果的发动条件：本次离场事件中存在满足plcfilter的怪兽，即自己场上表侧表示的「究极宝玉神」怪兽因对方的效果离场。
function c36328300.plcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36328300.plcfilter,1,nil,tp)
end
-- 定义②效果处理时选择墓地的「宝玉兽」怪兽的过滤条件：是「宝玉兽」字段的怪兽卡，且不是禁止卡（可放置到魔法陷阱区）。
function c36328300.plfilter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②效果的目标：确认魔法陷阱区有空位且墓地存在至少1张符合条件的「宝玉兽」怪兽，然后登记从墓地移走卡的操作信息。
function c36328300.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标阶段检查：自己的魔法陷阱区域存在可用空位，用于表侧放置变作永续魔法的「宝玉兽」怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 目标阶段检查：墓地存在至少1张可作为放置对象、符合条件的「宝玉兽」怪兽。
		and Duel.IsExistingMatchingCard(c36328300.plfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 登记本次效果将把墓地中的卡移动到其他区域（CATEGORY_LEAVE_GRAVE），用于连锁判定和效果互动。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果处理：从自己墓地选择任意数量（最多为魔法陷阱区空位数）的「宝玉兽」怪兽，表侧表示放置在魔法陷阱区域，并为每张卡附加‘当作永续魔法卡使用’的类型改变效果。
function c36328300.plop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己魔法陷阱区域的当前可用空格数，用于限制选择放置的数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	-- 提示发动者选择要放置到场上的卡（显示「请选择要放置到场上的卡」）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己墓地选择1至ft张符合条件的「宝玉兽」怪兽，ft为魔陷区空位数。
	local g=Duel.SelectMatchingCard(tp,c36328300.plfilter,tp,LOCATION_GRAVE,0,1,ft,nil)
	if g:GetCount()>0 then
		local tc=g:GetFirst()
		while tc do
			-- 将选中的「宝玉兽」怪兽卡移动到自己的魔法陷阱区域，表侧表示放置，并立刻适用该卡的效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			-- 「宝玉兽」怪兽当作永续魔法卡使用。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetCode(EFFECT_CHANGE_TYPE)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
			e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
