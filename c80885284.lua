--ゴーストリック・キョンシー
-- 效果：
-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。这张卡1回合只有1次可以变成里侧守备表示。此外，这张卡反转时，可以把持有自己场上的名字带有「鬼计」的怪兽数量以下的等级的1只名字带有「鬼计」的怪兽从卡组加入手卡。「鬼计僵尸」的这个效果1回合只能使用1次。
function c80885284.initial_effect(c)
	-- 自己场上有名字带有「鬼计」的怪兽存在的场合才能让这张卡表侧表示召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(c80885284.sumcon)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次可以变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(80885284,0))  --"变成里侧守备"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c80885284.postg)
	e2:SetOperation(c80885284.posop)
	c:RegisterEffect(e2)
	-- 此外，这张卡反转时，可以把持有自己场上的名字带有「鬼计」的怪兽数量以下的等级的1只名字带有「鬼计」的怪兽从卡组加入手卡。「鬼计僵尸」的这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80885284,1))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetCountLimit(1,80885284)
	e3:SetTarget(c80885284.thtg)
	e3:SetOperation(c80885284.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示的「鬼计」怪兽
function c80885284.sfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8d)
end
-- 召唤限制效果的启用条件（自己场上不存在表侧表示的「鬼计」怪兽时，不能表侧表示召唤）
function c80885284.sumcon(e)
	-- 检查自己场上是否存在表侧表示的「鬼计」怪兽，若不存在则返回true（触发不能召唤的限制）
	return not Duel.IsExistingMatchingCard(c80885284.sfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 变成里侧守备表示效果的发动准备（检查是否能变里侧、注册1回合1次Flag、设置操作信息）
function c80885284.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(80885284)==0 end
	c:RegisterFlagEffect(80885284,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：改变1张卡（自身）的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 变成里侧守备表示效果的执行（若自身仍在场且表侧表示，则变为里侧守备表示）
function c80885284.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤条件：等级在指定数值以下、且可以加入手牌的「鬼计」怪兽
function c80885284.thfilter(c,lv)
	return c:IsLevelBelow(lv) and c:IsSetCard(0x8d) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动准备（检查卡组中是否存在满足等级限制的「鬼计」怪兽，并设置操作信息）
function c80885284.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上表侧表示的「鬼计」怪兽数量
		local count=Duel.GetMatchingGroupCount(c80885284.sfilter,tp,LOCATION_MZONE,0,nil)
		-- 检查卡组中是否存在等级在当前「鬼计」怪兽数量以下的「鬼计」怪兽
		return Duel.IsExistingMatchingCard(c80885284.thfilter,tp,LOCATION_DECK,0,1,nil,count)
	end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行（计算场上「鬼计」怪兽数量，从卡组选择1只相应等级以下的「鬼计」怪兽加入手牌并给对方确认）
function c80885284.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 重新计算自己场上表侧表示的「鬼计」怪兽数量
	local count=Duel.GetMatchingGroupCount(c80885284.sfilter,tp,LOCATION_MZONE,0,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张等级在场上「鬼计」怪兽数量以下的「鬼计」怪兽
	local g=Duel.SelectMatchingCard(tp,c80885284.thfilter,tp,LOCATION_DECK,0,1,1,nil,count)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
