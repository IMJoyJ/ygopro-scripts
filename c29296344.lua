--ソーンヴァレル・ドラゴン
-- 效果：
-- 包含「弹丸」怪兽的龙族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。这个效果把连接怪兽破坏的场合，可以再把最多有那个连接标记数量的「弹丸」怪兽从自己的手卡·墓地特殊召唤（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不能把连接2以下的怪兽从额外卡组特殊召唤。
function c29296344.initial_effect(c)
	-- 为该卡注册连接召唤手续：用2只满足mfilter条件的怪兽作为素材，且素材组需满足lcheck（至少包含1只「弹丸」连接怪兽）。
	aux.AddLinkProcedure(c,c29296344.mfilter,2,2,c29296344.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：丢弃1张手卡，以场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。这个效果把连接怪兽破坏的场合，可以再把最多有那个连接标记数量的「弹丸」怪兽从自己的手卡·墓地特殊召唤（同名卡最多1张）。这个效果的发动后，直到回合结束时自己不能把连接2以下的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,29296344)
	e1:SetCost(c29296344.cost)
	e1:SetTarget(c29296344.target)
	e1:SetOperation(c29296344.operation)
	c:RegisterEffect(e1)
end
-- 定义连接素材的筛选条件：素材可以是龙族连接怪兽，也可以是拥有特定效果77189532的怪兽。
function c29296344.mfilter(c)
	return c:IsLinkRace(RACE_DRAGON) or c:IsHasEffect(77189532)
end
-- 检查连接素材组中是否存在至少1只「弹丸」连接怪兽（连接怪兽且属于弹丸字段）。
function c29296344.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x102)
end
-- 定义效果的发动代价：确认手牌中有可丢弃的卡，然后选择1张手卡丢弃作为发动代价。
function c29296344.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认自己手牌中至少有1张可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：让自己从手牌选择1张卡丢弃，丢弃原因包含代价和丢弃。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 设置效果发动时的对象选取流程：选择场上1只表侧表示怪兽作为对象，并登记破坏信息。
function c29296344.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认场上存在至少1只表侧表示怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1只场上表侧表示怪兽，并将其设为效果的对象。
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，登记将破坏这1只对象怪兽，供相关效果连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义特殊召唤候选的过滤条件：属于「弹丸」字段，且可以被效果特殊召唤。
function c29296344.spfilter(c,e,tp)
	return c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：破坏对象怪兽；若对象为连接怪兽且破坏成功，则从手卡·墓地特殊召唤最多其连接标记数量的「弹丸」怪兽（同名卡最多1张）；最后给自己附加不能从额外卡组特殊召唤连接2以下怪兽的自肃。
function c29296344.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时对象怪兽的实体卡（取回发动时选择的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 若对象仍与效果关联，且被成功效果破坏，并且该怪兽是连接怪兽，则进入后续特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and tc:IsType(TYPE_LINK) then
		-- 计算可特殊召唤的怪兽数量上限：取自己场上可用怪兽区空格数与对象连接标记数量中的较小值。
		local ct=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),tc:GetLink())
		if ct>0 then
			-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
			if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
			-- 获取自己手卡·墓地中满足「弹丸」字段且可被特殊召唤的怪兽群，并用NecroValleyFilter排除受王家长眠之谷影响的墓地卡。
			local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c29296344.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
			-- 若存在可选的特殊召唤候选，则询问玩家是否要进行「弹丸」怪兽的特殊召唤（选择是才继续）。
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(29296344,0)) then  --"是否特殊召唤「弹丸」怪兽？"
				-- 中断当前效果处理链，使后续特殊召唤作为独立动作处理，避免错过时点。
				Duel.BreakEffect()
				-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从候选中选择1至ct张「弹丸」怪兽，并保证所选卡片卡名互不相同（同名卡最多1张）。
				local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
				-- 将选中的「弹丸」怪兽以表侧表示特殊召唤到自己的怪兽区。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把连接2以下的怪兽从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(c29296344.splimit)
	-- 将自肃效果注册到当前玩家，使其在结束阶段前持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的判定条件：限制从额外卡组特殊召唤连接2以下的连接怪兽。
function c29296344.splimit(e,c,tp,sumtp,sumpos)
	return c:IsType(TYPE_LINK) and c:IsLinkBelow(2) and c:IsLocation(LOCATION_EXTRA)
end
