--コンタクト・ゲート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己墓地把「新空间侠」怪兽2种类各1只除外才能发动。从自己的手卡·卡组·墓地选2只「新空间侠」怪兽特殊召唤（同名卡最多1张）。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
-- ②：自己场上的表侧表示的需以「元素英雄 新宇侠」为融合素材的融合怪兽回到额外卡组的场合，把墓地的这张卡除外才能发动。选除外的1只自己的「新空间侠」怪兽特殊召唤。
function c41933425.initial_effect(c)
	-- 将卡号89943723（元素英雄 新宇侠）登记到这张卡的代码列表中，用于表示这张卡文本中记载了该卡名，以支持②效果中“需以「元素英雄 新宇侠」为融合素材的融合怪兽”的判定。
	aux.AddCodeList(c,89943723)
	-- 向这张卡注册系列字段0x3008（元素英雄），使其在涉及“元素英雄”字段关联时被正确识别，辅助②效果中“需以「元素英雄 新宇侠」为融合素材的融合怪兽”的判定。
	aux.AddSetNameMonsterList(c,0x3008)
	-- ①：从自己墓地把「新空间侠」怪兽2种类各1只除外才能发动。从自己的手卡·卡组·墓地选2只「新空间侠」怪兽特殊召唤（同名卡最多1张）。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,41933425+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c41933425.cost)
	e1:SetTarget(c41933425.target)
	e1:SetOperation(c41933425.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的表侧表示的需以「元素英雄 新宇侠」为融合素材的融合怪兽回到额外卡组的场合，把墓地的这张卡除外才能发动。选除外的1只自己的「新空间侠」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41933425,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c41933425.spcon)
	-- 为②效果设置发动代价：把墓地的这张卡除外（使用辅助函数aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c41933425.sptg)
	e2:SetOperation(c41933425.spop)
	c:RegisterEffect(e2)
end
-- ①效果的代价过滤条件：检查墓地是否存在1只“新空间侠”怪兽可作为第一只除外对象，且该怪兽能作为代价除外，同时墓地还有其他不同名的“新空间侠”怪兽可组成第二只除外对象。
function c41933425.cfilter1(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 在cfilter1中追加检查：墓地中存在另一只满足cfilter2条件的“新空间侠”怪兽，保证能除外2种类各1只。
		and Duel.IsExistingMatchingCard(c41933425.cfilter2,tp,LOCATION_GRAVE,0,1,c,e,tp,c)
end
-- ①效果的第二只除外对象过滤条件：与第一只不同名；本身是“新空间侠”怪兽且可作为代价除外；并且在除外这两只后，手卡·卡组·墓地中仍存在至少2只不同名且可特殊召唤的“新空间侠”怪兽。
function c41933425.cfilter2(c,e,tp,tc)
	if c:IsCode(tc:GetCode()) then return false end
	local sg=Group.FromCards(tc,c)
	-- 在cfilter2中获取从手卡·卡组·墓地可特殊召唤的“新空间侠”怪兽组（排除已选为代价的两张卡），用于判断是否还有至少2个不同卡名可供特殊召唤。
	local g=Duel.GetMatchingGroup(c41933425.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,sg,e,tp)
	return c:IsSetCard(0x1f) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and g:GetClassCount(Card.GetCode)>1
end
-- 特殊召唤候选过滤：该卡是“新空间侠”怪兽，且能被当前效果特殊召唤（满足召唤条件且不受苏生限制）。
function c41933425.spfilter1(c,e,tp)
	return c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的代价执行：发动时先从墓地选择1只“新空间侠”怪兽，再选择另1只不同名的“新空间侠”怪兽，将两张卡合并后以表侧表示除外。
function c41933425.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查分支（chk==0）：确认墓地至少存在1只满足cfilter1的“新空间侠”怪兽，即存在可除外2种类各1只的代价组合。
	if chk==0 then return Duel.IsExistingMatchingCard(c41933425.cfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示“请选择要除外的卡”的提示框，引导玩家选择第一只要除外的“新空间侠”怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只满足cfilter1的“新空间侠”怪兽作为第一只除外代价。
	local g1=Duel.SelectMatchingCard(tp,c41933425.cfilter1,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 显示“请选择要除外的卡”的提示框，引导玩家选择第二只要除外的“新空间侠”怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只满足cfilter2的“新空间侠”怪兽作为第二只除外代价，cfilter2会确保与第一只不同名且后续有足够特召对象。
	local g2=Duel.SelectMatchingCard(tp,c41933425.cfilter2,tp,LOCATION_GRAVE,0,1,1,g1:GetFirst(),e,tp,g1:GetFirst())
	g1:Merge(g2)
	-- 将选好的两张“新空间侠”怪兽以表侧表示除外，完成代价。
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
-- ①效果的发动条件判定：玩家不受青眼精灵龙效果影响（否则不能同时特殊召唤2只以上）、自己主要怪兽区空位>1、且手卡·卡组·墓地中存在至少2只不同名且可特殊召唤的“新空间侠”怪兽。
function c41933425.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在target中取得当前可特殊召唤的“新空间侠”怪兽组，用于检查是否满足2只不同名。
	local g=Duel.GetMatchingGroup(c41933425.spfilter1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 进一步确认：主怪兽区空位>1，且可特殊召唤组中不同卡名种类数>1（保证能选出2只同名卡最多1张）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and g:GetClassCount(Card.GetCode)>1 end
	-- 设置操作信息：本效果将在处理时从手卡·卡组·墓地特殊召唤2只“新空间侠”怪兽，供连锁检测/替代效果参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- ①效果处理：先给己方附加“本回合不能从额外卡组特殊召唤非融合怪兽”的自肃；若玩家不受青眼精灵龙影响且主怪兽区有至少2个空位，则从手卡·卡组·墓地选择2只不同名的“新空间侠”怪兽表侧表示特殊召唤。
function c41933425.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己的手卡·卡组·墓地选2只「新空间侠」怪兽特殊召唤（同名卡最多1张）。这个效果发动过的回合，自己不是融合怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c41933425.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果e1注册给玩家tp，使其本回合不能从额外卡组特殊召唤非融合怪兽。
	Duel.RegisterEffect(e1,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) or Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	-- 获取可特殊召唤的“新空间侠”怪兽组，并通过aux.NecroValleyFilter过滤掉受王家长眠之谷影响无法从墓地特殊召唤的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c41933425.spfilter1),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetClassCount(Card.GetCode)>1 then
		-- 显示“请选择要特殊召唤的卡”的提示框，让玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从可特召组g中选择2张卡名互不相同的“新空间侠”怪兽（2张，同名最多1张）。
		local sg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
		-- 将选出的2只“新空间侠”怪兽表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 自肃效果的判定函数：被禁止特殊召唤的卡是非融合怪兽且位于额外卡组，即“不是融合怪兽不能从额外卡组特殊召唤”。
function c41933425.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的诱发过滤条件：回到额外卡组的卡必须是融合怪兽、且其融合素材包含“元素英雄 新宇侠”，并且是从自己场上表侧表示回到额外卡组的。
function c41933425.confilter(c,tp)
	-- 该条件行前半部分：判断回额外卡组的卡是融合怪兽、融合素材记载了元素英雄新宇侠、且之前位于主要怪兽区。
	return c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,89943723) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：当有满足confilter条件的融合怪兽回到额外卡组时，该效果可以发动。
function c41933425.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c41933425.confilter,1,nil,tp)
end
-- ②效果特殊召唤对象的过滤：除外的自己的“新空间侠”怪兽中，表侧表示且可被当前效果特殊召唤的卡。
function c41933425.spfilter2(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x1f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件判定：自己主要怪兽区有空位，且除外区存在至少1只满足spfilter2的“新空间侠”怪兽。
function c41933425.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有至少1个空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只可特殊召唤的自己的“新空间侠”怪兽。
		and Duel.IsExistingMatchingCard(c41933425.spfilter2,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息：本效果预计从除外区特殊召唤1只“新空间侠”怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- ②效果处理：若主怪兽区有空位，从自己的除外区选择1只“新空间侠”怪兽表侧表示特殊召唤。
function c41933425.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认主怪兽区是否有空位，若无则直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示框，用于选择除外区的特召对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区选择1只满足spfilter2的“新空间侠”怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c41933425.spfilter2,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的“新空间侠”怪兽表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
