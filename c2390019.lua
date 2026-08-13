--おジャマ改造
-- 效果：
-- ①：把额外卡组1只机械族·光属性的融合怪兽给对方观看，把自己的手卡·场上·墓地的「扰乱」怪兽任意数量除外才能发动。从自己的手卡·卡组·墓地选除外的怪兽数量的在给人观看的怪兽有卡名记述的融合素材怪兽特殊召唤（同名卡最多1张）。
-- ②：把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
function c2390019.initial_effect(c)
	-- ①：把额外卡组1只机械族·光属性的融合怪兽给对方观看，把自己的手卡·场上·墓地的「扰乱」怪兽任意数量除外才能发动。从自己的手卡·卡组·墓地选除外的怪兽数量的在给人观看的怪兽有卡名记述的融合素材怪兽特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c2390019.cost)
	e1:SetTarget(c2390019.target)
	e1:SetOperation(c2390019.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的3只自己的「扰乱」怪兽为对象才能发动。那些怪兽加入卡组洗切。那之后，自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为②效果的发动代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c2390019.drtg)
	e2:SetOperation(c2390019.drop)
	c:RegisterEffect(e2)
end
-- 定义cfilter：筛选可作为cost除外的「扰乱」怪兽，要求属于「扰乱」系列、是怪兽卡且能被除外作为代价。
function c2390019.cfilter(c)
	return c:IsSetCard(0xf) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 定义spfilter：筛选可作为展示融合怪兽素材并被特殊召唤的怪兽。
function c2390019.spfilter(c,e,tp,fc)
	-- 具体条件是：该怪兽的卡名被展示的融合怪兽的素材列表所记述，且该怪兽满足当前效果的特殊召唤条件。
	return aux.IsMaterialListCode(fc,c:GetCode()) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义fselect：用于确认除外组cg是否可行，要求除外后我方怪兽区空格足够，且从可召唤素材组tg中能选出与除外数量相同且卡名互不相同的怪兽。
function c2390019.fselect(cg,tp,tg)
	-- 返回条件：Duel.GetMZoneCount(tp,cg,tp)>=#cg 表示在除外这些卡后仍有足够空格；tg:Filter(aux.TRUE,cg):CheckSubGroup(aux.dncheck,#cg,#cg) 表示tg中可选出卡名不重复的#cg张卡。
	return Duel.GetMZoneCount(tp,cg,tp)>=#cg and tg:Filter(aux.TRUE,cg):CheckSubGroup(aux.dncheck,#cg,#cg)
end
-- 定义ffilter：筛选额外卡组中机械族·光属性的融合怪兽，并根据可召唤素材数量和可除外数量计算可除外的最大数量（受青眼精灵龙影响时上限为1），再验证是否存在满足条件的除外子组。
function c2390019.ffilter(c,e,tp,cg)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)) then return false end
	-- 获取手卡·卡组·墓地中可作为当前展示融合怪兽素材且能被特殊召唤的怪兽集合。
	local tg=Duel.GetMatchingGroup(c2390019.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,c)
	local maxct=math.min(#tg,#cg,5)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then maxct=1 end
	return cg:CheckSubGroup(c2390019.fselect,1,maxct,tp,tg)
end
-- 定义①效果的cost函数：在cost检测时设置标记100，表示已进入过cost阶段，并允许发动。
function c2390019.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- 定义①效果的target函数：展示符合条件的额外融合怪兽，选择并除外「扰乱」怪兽，记录数量，并设置特殊召唤的操作信息。
function c2390019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·场上·墓地中满足cfilter（可作为代价除外的「扰乱」怪兽）的卡片集合。
	local cg=Duel.GetMatchingGroup(c2390019.cfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查额外卡组是否存在至少1张满足ffilter条件的融合怪兽，以保证可以展示。
		return Duel.IsExistingMatchingCard(c2390019.ffilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,cg)
	end
	-- 提示玩家选择要给对方确认的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从额外卡组选择1张符合条件的融合怪兽，并取得其对象。
	local fc=Duel.SelectMatchingCard(tp,c2390019.ffilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,cg):GetFirst()
	-- 将选择的融合怪兽给对方玩家确认。
	Duel.ConfirmCards(1-tp,fc)
	e:SetLabelObject(fc)
	-- 获取手卡·卡组·墓地中所有可作为fc素材并被特殊召唤的怪兽集合。
	local tg=Duel.GetMatchingGroup(c2390019.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,fc)
	local maxct=math.min(#tg,#cg,5)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then maxct=1 end
	-- 提示玩家选择要除外的「扰乱」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g=cg:SelectSubGroup(tp,c2390019.fselect,false,1,maxct,tp,tg)
	-- 将选中的「扰乱」怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 获取实际除外的怪兽数量。
	local ct=Duel.GetOperatedGroup():GetCount()
	e:SetLabel(ct)
	-- 设置操作信息：预计从手卡·卡组·墓地特殊召唤ct只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,ct,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 定义①效果处理函数：根据怪兽区空格和可召唤素材组，选择ct张卡名互不相同的怪兽特殊召唤。
function c2390019.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方怪兽区可用空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	local ct=e:GetLabel()
	if ft<ct then return end
	local fc=e:GetLabelObject()
	-- 获取当前可特殊召唤的素材怪兽组，并用王家长眠之谷过滤器排除受其影响的怪兽。
	local mg=Duel.GetMatchingGroup(aux.NecroValleyFilter(c2390019.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,fc)
	if mg:GetClassCount(Card.GetCode)<ct then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从素材组中选择ct张卡名互不相同的怪兽。
	local g=mg:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	-- 将选中的怪兽以表侧表示特殊召唤到我方场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end
-- 定义tdfilter：筛选可以返回卡组的「扰乱」怪兽，要求表侧表示、是怪兽卡、属于「扰乱」系列并能返回卡组。
function c2390019.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
		and c:IsSetCard(0xf) and c:IsAbleToDeck()
end
-- 定义②效果的target函数：检查自己能否抽1张卡，且除外区存在3只符合条件的自己的「扰乱」怪兽可作为对象；同时验证指定对象。
function c2390019.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c2390019.tdfilter(chkc) end
	-- 在合法性检查时确认自己可以抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 确认除外区存在至少3只满足tdfilter条件的自己的「扰乱」怪兽可被选择为对象。
		and Duel.IsExistingTarget(c2390019.tdfilter,tp,LOCATION_REMOVED,0,3,nil) end
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从除外区选择3只自己的「扰乱」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c2390019.tdfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	-- 设置操作信息：将对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置操作信息：自己将抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义②效果处理函数：将对象怪兽返回卡组洗切，然后若返回成功则抽1张卡。
function c2390019.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象（目标）卡组，并过滤出仍然与效果相关的卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将目标卡返回持有者卡组并标记需要洗切。
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取刚才实际被送回卡组的卡组。
	local g=Duel.GetOperatedGroup()
	-- 如果实际返回的卡中有进入卡组的卡，则洗切我方卡组。
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct>0 then
		-- 中断当前效果处理，使后续抽卡作为新的效果处理错开时点。
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
