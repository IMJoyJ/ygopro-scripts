--彼岸の悪鬼 スカラマリオン
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把「彼岸的恶鬼 斯卡尔米利奥内」以外的1只恶魔族·暗属性·3星怪兽加入手卡。
function c84764038.initial_effect(c)
	-- ②：自己场上有「彼岸」怪兽以外的怪兽存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c84764038.sdcon)
	c:RegisterEffect(e1)
	-- ①：自己场上没有魔法·陷阱卡存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84764038,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,84764038)
	e2:SetCondition(c84764038.sscon)
	e2:SetTarget(c84764038.sstg)
	e2:SetOperation(c84764038.ssop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的回合
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetOperation(c84764038.regop)
	c:RegisterEffect(e3)
	-- ③：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把「彼岸的恶鬼 斯卡尔米利奥内」以外的1只恶魔族·暗属性·3星怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(84764038,1))  --"卡组检索"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCountLimit(1,84764038)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCondition(c84764038.thcon)
	e4:SetTarget(c84764038.thtg)
	e4:SetOperation(c84764038.thop)
	c:RegisterEffect(e4)
end
-- 过滤条件：里侧表示或者不是「彼岸」系列的怪兽
function c84764038.sdfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0xb1)
end
-- 自毁效果的发动条件：自己场上存在里侧表示怪兽或「彼岸」以外的怪兽
function c84764038.sdcon(e)
	-- 检查自己场上是否存在满足里侧表示或非「彼岸」怪兽条件的卡
	return Duel.IsExistingMatchingCard(c84764038.sdfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c84764038.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 手卡特殊召唤效果的发动条件：自己场上没有魔法·陷阱卡存在
function c84764038.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在魔法·陷阱卡
	return not Duel.IsExistingMatchingCard(c84764038.filter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 手卡特殊召唤效果的发动检测函数
function c84764038.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否有空余的怪兽区域，且自身可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 手卡特殊召唤效果的执行函数
function c84764038.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 送去墓地时的效果注册函数：给自身注册一个在回合结束前有效的标记
function c84764038.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(84764038,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 过滤条件：卡组中除「彼岸的恶鬼 斯卡尔米利奥内」以外的3星·暗属性·恶魔族怪兽，且能加入手牌
function c84764038.thfilter(c)
	return c:IsLevel(3) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_FIEND)
		and not c:IsCode(84764038) and c:IsAbleToHand()
end
-- 检索效果的发动条件：这张卡在本回合被送去过墓地（检查是否带有注册标记）
function c84764038.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(84764038)>0
end
-- 检索效果的发动检测函数
function c84764038.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查卡组中是否存在满足检索条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84764038.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function c84764038.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择加入手牌卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,c84764038.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
