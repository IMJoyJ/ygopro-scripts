--鉄獣の戦線
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
-- ②：从自己的手卡·场上把1只怪兽送去墓地才能发动。原本种族和送去墓地的怪兽不同的1只「铁兽」怪兽从卡组加入手卡。
-- ③：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。这个回合对方不能攻击宣言。
function c25908748.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c25908748.splimit)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：从自己的手卡·场上把1只怪兽送去墓地才能发动。原本种族和送去墓地的怪兽不同的1只「铁兽」怪兽从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25908748,0))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,25908748)
	e3:SetCost(c25908748.srcost)
	e3:SetTarget(c25908748.srtg)
	e3:SetOperation(c25908748.srop)
	c:RegisterEffect(e3)
	-- ③：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。这个回合对方不能攻击宣言。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(25908748,1))
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c25908748.limcon)
	e4:SetOperation(c25908748.limop)
	c:RegisterEffect(e4)
end
-- 判定特殊召唤的怪兽是否来自额外卡组且种族不属于兽族·兽战士族·鸟兽族，是则禁止该特殊召唤（①的自肃条件）。
function c25908748.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 筛选从手牌·场上送去墓地的1只怪兽：必须是怪兽且可作为代价送去墓地，并且卡组中存在原本种族与之不同的「铁兽」怪兽可检索。
function c25908748.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在原本种族与候选代价怪兽不同的「铁兽」怪兽，以确保检索目标存在。
		and Duel.IsExistingMatchingCard(c25908748.srfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace())
end
-- 筛选检索目标：卡组中的「铁兽」怪兽，且是怪兽、可以加入手牌、原本种族与已送墓的代价怪兽不同。
function c25908748.srfilter(c,race)
	return c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:GetOriginalRace()~=race
end
-- 代价判定：此处仅设置标记表示已进入发动流程并允许发动（实际送墓代价在target阶段处理）。
function c25908748.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 发动时选择并支付代价：确认存在符合条件的代价怪兽后，从手牌·场上选1只怪兽送去墓地，记录其原本种族，并设置效果将检索卡组中的「铁兽」怪兽加入手牌。
function c25908748.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查是否存在可以作为代价的怪兽（满足cfilter），即能否支付②的代价。
		return Duel.IsExistingMatchingCard(c25908748.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	end
	-- 选择一张手牌·场上满足条件的怪兽作为②的代价。
	local g=Duel.SelectMatchingCard(tp,c25908748.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetOriginalRace())
	-- 将选择的怪兽送去墓地，作为②的发动代价。
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置操作信息：本次效果处理将把1张卡从卡组加入手牌（检索），供系统检测发动条件。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时按记录的原本种族，从卡组选择1只符合条件的「铁兽」怪兽加入手牌，并向对方展示。
function c25908748.srop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	if race==0 then return end
	-- 给玩家显示‘请选择要加入手牌的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只原本种族与代价怪兽不同的「铁兽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c25908748.srfilter,tp,LOCATION_DECK,0,1,1,nil,race)
	if g:GetCount()>0 then
		-- 将选择的「铁兽」怪兽加入持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次检索加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判定③的发动条件：此卡在魔法与陷阱区域被对方的效果破坏，且破坏时控制权为自己，同时当前为对方回合且处于战斗阶段或可进入战斗阶段。
function c25908748.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		-- 追加条件：当前为对方回合且处于战斗阶段/可进入战斗阶段，确保‘对方不能攻击宣言’有意义。
		and Duel.GetTurnPlayer()==1-tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：给对方玩家附加‘不能进行攻击宣言’的限制，持续到回合结束。
function c25908748.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘对方不能攻击宣言’的效果实际注册到决斗中，作用于对方玩家。
	Duel.RegisterEffect(e1,tp)
end
