--BF－上弦のピナーカ
-- 效果：
-- 「黑羽-上弦之灭弓鸟」的效果1回合只能使用1次。把这张卡作为同调素材的场合，不是「黑羽」怪兽的同调召唤不能使用。
-- ①：这张卡从场上送去墓地的回合的结束阶段才能发动。从卡组把「黑羽-上弦之灭弓鸟」以外的1只「黑羽」怪兽加入手卡。
function c55610595.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是「黑羽」怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c55610595.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡从场上送去墓地的回合的结束阶段才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c55610595.regop)
	c:RegisterEffect(e2)
end
-- 同调素材限制的过滤函数，限制不能用于「黑羽」怪兽以外的同调召唤
function c55610595.synlimit(e,c)
	if not c then return false end
	return not c:IsSetCard(0x33)
end
-- 当这张卡从场上送去墓地时，注册一个在结束阶段可以发动的检索效果
function c55610595.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) then
		-- ①：这张卡从场上送去墓地的回合的结束阶段才能发动。从卡组把「黑羽-上弦之灭弓鸟」以外的1只「黑羽」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetCountLimit(1,55610595)
		e1:SetTarget(c55610595.thtg)
		e1:SetOperation(c55610595.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤卡组中除「黑羽-上弦之灭弓鸟」以外的「黑羽」怪兽，且该卡可以加入手卡
function c55610595.filter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and not c:IsCode(55610595) and c:IsAbleToHand()
end
-- 检索效果的发动条件判断与操作信息设置
function c55610595.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c55610595.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会将卡组中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理：从卡组选择1张满足条件的卡加入手卡并给对方确认
function c55610595.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c55610595.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
