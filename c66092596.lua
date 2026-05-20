--竜呼双搏
-- 效果：
-- 这个卡名的卡在1回合只能发动1张，这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把以下怪兽之内1只加入手卡。
-- ●「真龙」怪兽
-- ●「龙剑士」灵摆怪兽
-- ●「龙魔王」灵摆怪兽
-- ②：自己场上的表侧表示的「真龙」怪兽被战斗·效果破坏送去墓地的场合，以那之内的1只为对象才能发动。那只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数：包含①效果（卡片发动时的效果处理）和②效果（被破坏的「真龙」怪兽当作永续魔法放置）。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把以下怪兽之内1只加入手卡。●「真龙」怪兽●「龙剑士」灵摆怪兽●「龙魔王」灵摆怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 为这张卡注册一个合并的延迟事件监听器，用于检测怪兽被破坏的时点。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_DESTROYED)
	-- 这个卡名的②的效果1回合只能使用1次。②：自己场上的表侧表示的「真龙」怪兽被战斗·效果破坏送去墓地的场合，以那之内的1只为对象才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"放置效果"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(custom_code)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中满足条件的卡：属于「真龙」怪兽，或者属于「龙剑士」或「龙魔王」的灵摆怪兽，且能加入手卡。
function s.thfilter(c)
	return (c:IsSetCard(0xf9) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0xda,0xc7) and c:IsType(TYPE_PENDULUM)) and c:IsAbleToHand()
end
-- ①效果的发动时效果处理：可以从卡组选择1只满足条件的怪兽加入手卡并给对方确认。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的怪兽。
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的卡，则询问玩家是否发动该检索效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否把怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入玩家手牌。
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤因战斗或效果破坏并送去墓地的、原本在自己场上表侧表示存在的「真龙」怪兽。
function s.cfilter(c,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
		and c:IsPreviousSetCard(0xf9) and c:IsSetCard(0xf9) and c:IsType(TYPE_MONSTER)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ②效果的发动条件：自己场上表侧表示的「真龙」怪兽被战斗·效果破坏送去墓地的场合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤可以作为效果对象放置到魔法与陷阱区域的墓地怪兽（需检查魔陷区空位数、是否被禁止放置等）。
function s.tgfilter(c,e,tp)
	local r=LOCATION_REASON_TOFIELD
	if not c:IsControler(tp) then
		if not c:IsAbleToChangeControler() then return false end
		r=LOCATION_REASON_CONTROL
	end
	-- 检查魔法与陷阱区域是否有空位，且该卡未被禁止放置在场上，且在场上具有唯一性。
	return Duel.GetLocationCount(tp,LOCATION_SZONE,tp,r)>0 and not c:IsForbidden() and c:CheckUniqueOnField(tp)
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_GRAVE)
end
-- ②效果的对象选择：从被破坏送墓的怪兽中选择1只作为效果对象。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=eg:Filter(s.cfilter,nil,tp):Filter(s.tgfilter,nil,e,tp)
	if chkc then return mg:IsContains(chkc) end
	if chk==0 then return mg:GetCount()>0 end
	local g=mg
	if mg:GetCount()>1 then
		-- 提示玩家选择效果的对象。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
		g=mg:Select(tp,1,1,nil)
	end
	-- 将选中的怪兽卡设为当前连锁的效果对象。
	Duel.SetTargetCard(g)
end
-- ②效果的效果处理：将作为对象的怪兽在自己的魔法与陷阱区域表侧表示放置，并使其当作永续魔法卡使用。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与连锁相关、是否为怪兽卡，且不受「王家之谷-Necrovalley」的影响。
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and aux.NecroValleyFilter()(tc)
		-- 将该怪兽卡表侧表示移动（放置）到自己的魔法与陷阱区域。
		and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) then
		-- 那只怪兽当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
