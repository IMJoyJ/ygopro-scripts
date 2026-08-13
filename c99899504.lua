--スカル・フレイム
-- 效果：
-- 1回合1次，可以从手卡把1只「燃烧骷髅头」特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。此外，可以作为自己的抽卡阶段时进行通常抽卡的代替，把自己墓地存在的1只「燃烧骷髅头」加入手卡。
function c99899504.initial_effect(c)
	-- 对应效果原文：“1回合1次，可以从手卡把1只「燃烧骷髅头」特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。”
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99899504,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c99899504.spcon)
	e1:SetTarget(c99899504.sptg)
	e1:SetOperation(c99899504.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“此外，可以作为自己的抽卡阶段时进行通常抽卡的代替，把自己墓地存在的1只「燃烧骷髅头」加入手卡。”
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99899504,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c99899504.thcon)
	e2:SetTarget(c99899504.thtg)
	e2:SetOperation(c99899504.thop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：本回合自己尚未进入过战斗阶段（不能在已进行过战斗阶段后发动）。
function c99899504.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断本回合自己进入战斗阶段的次数是否为0。
	return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0
end
-- 选择过滤器：手牌中的「燃烧骷髅头」（卡号26293219）且可以被特殊召唤（无视召唤条件）。
function c99899504.spfilter(c,e,tp)
	return c:IsCode(26293219) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动的合法性检查：自己场上有可用怪兽区域，且手牌中存在可特殊召唤的「燃烧骷髅头」。
function c99899504.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只符合spfilter的「燃烧骷髅头」。
		and Duel.IsExistingMatchingCard(c99899504.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息：本次效果包含特殊召唤，预定从手卡特殊召唤1只怪兽（处理时选卡）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	-- 对应效果原文：“1回合1次，可以从手卡把1只「燃烧骷髅头」特殊召唤。这个效果发动的回合，自己不能进行战斗阶段。此外，可以作为自己的抽卡阶段时进行通常抽卡的代替，把自己墓地存在的1只「燃烧骷髅头」加入手卡。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“这个效果发动的回合自己不能进行战斗阶段”的誓约效果注册给自己，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤处理：确认场上仍有可用区域后，从手牌选择1只「燃烧骷髅头」以表侧表示特殊召唤。
function c99899504.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上已没有可用的怪兽区域，则中止特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中筛选出1张符合spfilter的「燃烧骷髅头」（卡号26293219且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c99899504.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「燃烧骷髅头」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 抽卡代替效果的发动条件：自己为回合玩家，且卡组中仍有卡。
function c99899504.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合（抽卡阶段）且卡组数量大于0。
	return tp==Duel.GetTurnPlayer() and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
end
-- 选择过滤器：自己墓地中的「燃烧骷髅头」（卡号26293219）且能够加入手卡。
function c99899504.thfilter(c)
	return c:IsCode(26293219) and c:IsAbleToHand()
end
-- 抽卡代替效果的目标与设定：选取墓地1只「燃烧骷髅头」为对象，并将本回合自己的通常抽卡数量改为0以代替抽卡。
function c99899504.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c99899504.thfilter(chkc) end
	-- 发动合法性检查：自己墓地存在至少1只符合条件的「燃烧骷髅头」可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99899504.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 取得自己的规则通常抽卡次数。
	local dt=Duel.GetDrawCount(tp)
	if dt~=0 then
		e:SetLabel(1)
		-- 向玩家显示“请选择要加入手牌的卡”的选卡提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己墓地选择1只符合条件的「燃烧骷髅头」并设为当前连锁的对象。
		local g=Duel.SelectTarget(tp,c99899504.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 设置效果处理信息：本次效果包含将对象加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		-- 对应效果原文：“此外，可以作为自己的抽卡阶段时进行通常抽卡的代替，把自己墓地存在的1只「燃烧骷髅头」加入手卡。”
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		-- 将“自己抽卡阶段的通常抽卡数量变为0”的效果注册给自己，持续到抽卡阶段结束。
		Duel.RegisterEffect(e1,tp)
	else e:SetLabel(0) end
end
-- 抽卡代替效果处理：若已满足代替条件且对象仍存在于墓地，则将其加入手牌并让对手确认。
function c99899504.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁选择的「燃烧骷髅头」对象。
	local tc=Duel.GetFirstTarget()
	if e:GetLabel()==1 and tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认这张被加入手卡的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
