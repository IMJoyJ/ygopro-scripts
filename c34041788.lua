--エンディミオン皇国
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，把1只「圣月之皇太子 雷古勒斯」或者有那个卡名记述的怪兽从卡组加入手卡。对方场上有怪兽存在的场合，可以再从手卡把1只魔法师族怪兽特殊召唤。
-- ②：自己场上的卡被战斗·效果破坏的场合，可以作为代替把自己的手卡·场上（表侧表示）1只「圣月之皇太子 雷古勒斯」破坏。
local s,id,o=GetID()
-- 初始化效果注册：给这张卡登记卡名记载信息；创建并注册①的发动效果（检索+特殊召唤）和②的代替破坏效果（永续·场地型代破效果）。
function s.initial_effect(c)
	-- 将卡号96228804（圣月之皇太子 雷古勒斯）登记为这张卡效果文本中记载的卡，使辅助函数aux.IsCodeListed能正确判断卡名记述。
	aux.AddCodeList(c,96228804)
	-- ①效果：作为魔法卡发动时的效果处理，检索「圣月之皇太子 雷古勒斯」或记载其卡名的怪兽加入手卡，且对方场上有怪兽时可以从手卡特殊召唤1只魔法师族怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②效果：自己场上的卡将被战斗·效果破坏时，可以作为代替把手卡·场上表侧表示的「圣月之皇太子 雷古勒斯」破坏的代替破坏效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.desreptg)
	e2:SetValue(s.desrepval)
	e2:SetOperation(s.desrepop)
	c:RegisterEffect(e2)
end
-- 检索过滤器：判断卡组中的怪兽是否为「圣月之皇太子 雷古勒斯」，或为卡名记述了该卡的怪兽，并且能够加入手卡。
function s.thfilter(c)
	-- 检索条件：卡是96228804，或（是怪兽且效果文本记载了96228804），且当前可加入手卡。
	return (c:IsCode(96228804) or aux.IsCodeListed(c,96228804) and c:IsType(TYPE_MONSTER)) and c:IsAbleToHand()
end
-- ①效果的发动条件与操作信息：发动前确认卡组存在满足检索条件的卡；发动时向系统登记“从卡组将1张卡加入手卡”的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：检查己方卡组是否存在至少1张满足s.thfilter条件的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：声明本次效果包含将1张卡从卡组加入手卡（CATEGORY_TOHAND），用于后续连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤过滤器：选择手卡中魔法师族、并且能够被当前效果特殊召唤的怪兽。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果处理：从卡组检索符合条件的怪兽加入手卡并向对方展示；若自己主怪兽区有空位、对方场上有怪兽、手卡有可特殊召唤的魔法师族怪兽且玩家选择发动，则将手卡那只魔法师族怪兽特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：让玩家从卡组中选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入持有者手卡（原因是效果处理）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示自己加入手卡的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
		-- 检查己方主要怪兽区是否有空位，用于决定能否执行特殊召唤。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查对方场上是否存在至少1只怪兽，满足“对方场上有怪兽存在的场合”这一追加条件。
			and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
			-- 检查己方手卡是否存在至少1只满足s.spfilter的魔法师族怪兽可供特殊召唤。
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
			-- 询问玩家是否发动追加效果：从手卡特殊召唤魔法师族怪兽。
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否特殊召唤？"
			-- 中断当前效果链，使后续特殊召唤处理视为不同时处理，避免错过时点。
			Duel.BreakEffect()
			-- 弹出选择提示：让玩家从手卡选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡选择1只满足s.spfilter的魔法师族怪兽。
			local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			-- 特殊召唤后洗切手卡（因手卡被展示过且发生了移动，重置手卡顺序）。
			Duel.ShuffleHand(tp)
			-- 将选择的怪兽以表侧表示特殊召唤到己方场上，不检查召唤条件、不检查苏生限制。
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 代破触发器：判断“将被破坏的卡”是否为自己场上且因战斗或效果被破坏、且不是已被代破处理过的卡，用于触发②的代替破坏条件。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField()
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 代破素材过滤器：选择自己场上（表侧表示）或手卡的「圣月之皇太子 雷古勒斯」，要求该卡可以被破坏且尚未被破坏确定。
function s.desfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE+LOCATION_HAND) and c:IsCode(96228804)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED)
end
-- ②代替破坏效果的满足判断：存在自己场上因战斗/效果将被破坏的卡，且存在可以代替破坏的「圣月之皇太子 雷古勒斯」；然后询问玩家是否发动代替破坏。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		-- 追加判断：场上/手卡存在可选的「圣月之皇太子 雷古勒斯」作为代替破坏的素材。
		and Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 让玩家选择是否发动这张卡的②代替破坏效果（提示文字使用描述id 96）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 弹出选择提示：让玩家选择要代替破坏的「圣月之皇太子 雷古勒斯」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己场上（表侧表示）或手卡选择1张「圣月之皇太子 雷古勒斯」作为代替破坏的卡，并将其记录到效果标签中。
		local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE+LOCATION_HAND,0,1,1,nil,e,tp)
		e:SetLabelObject(g:GetFirst())
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	end
	return false
end
-- 代替破坏判定值函数：当有卡片将要被破坏时，检查该卡是否满足“自己场上且因战斗/效果要被破坏”的条件，返回真则由这张卡代替破坏。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏处理：展示这张卡的发动动画，将标记为破坏确定的代替素材解除标记，并实际破坏该素材。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示本卡（34041788）的发动动画，用于代替破坏时的不入连锁提示。
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果+代替破坏的理由破坏所选代替素材，完成代替破坏的处理。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end
