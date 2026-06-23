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
	-- ②：从自己的手卡·场上把1只怪兽送去墓地才能发动。原本种族和送去墓地的怪兽不同的1只「铁兽」怪兽从卡组加入手卡。
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
-- 过滤并限制非兽族·兽战士族·鸟兽族的怪兽不能从额外卡组特殊召唤
function c25908748.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
-- 检查玩家手牌或场上的怪兽是否满足送去墓地的条件并确保卡组中有符合条件的铁兽怪兽
function c25908748.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在种族与送去墓地怪兽不同的铁兽怪兽
		and Duel.IsExistingMatchingCard(c25908748.srfilter,tp,LOCATION_DECK,0,1,nil,c:GetOriginalRace())
end
-- 筛选卡组中种族与指定种族不同的铁兽怪兽
function c25908748.srfilter(c,race)
	return c:IsSetCard(0x14d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:GetOriginalRace()~=race
end
-- 设置效果发动的标记以供后续判断
function c25908748.srcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 判断是否满足发动条件并选择送去墓地的怪兽，然后将该怪兽送去墓地
function c25908748.srtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 判断手牌或场上是否存在可以送去墓地的怪兽
		return Duel.IsExistingMatchingCard(c25908748.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp)
	end
	-- 选择并确认要送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,c25908748.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	e:SetLabel(g:GetFirst():GetOriginalRace())
	-- 将选中的怪兽送去墓地作为效果的代价
	Duel.SendtoGrave(g,REASON_COST)
	-- 设置连锁操作信息，表示将要从卡组检索并加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 根据之前记录的种族选择卡组中符合条件的铁兽怪兽并加入手牌
function c25908748.srop(e,tp,eg,ep,ev,re,r,rp)
	local race=e:GetLabel()
	if race==0 then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中符合条件的铁兽怪兽
	local g=Duel.SelectMatchingCard(tp,c25908748.srfilter,tp,LOCATION_DECK,0,1,1,nil,race)
	if g:GetCount()>0 then
		-- 将选中的铁兽怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断该卡是否被对方效果破坏且满足发动条件
function c25908748.limcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsReason(REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_SZONE)
		-- 判断是否处于可以发动效果的时点（即对方回合且能进行战斗操作）
		and Duel.GetTurnPlayer()==1-tp and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 创建并注册一个使对方在本回合不能攻击宣言的效果
function c25908748.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合对方不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到游戏环境中
	Duel.RegisterEffect(e1,tp)
end
