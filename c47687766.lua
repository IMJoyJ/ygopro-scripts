--ギアギアングラー
-- 效果：
-- ①：这张卡召唤成功时才能发动。从卡组把「齿轮齿轮钻地人」以外的1只机械族·地属性·4星怪兽加入手卡。这个回合，自己不能攻击宣言，不是机械族怪兽不能特殊召唤。
function c47687766.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「齿轮齿轮钻地人」以外的1只机械族·地属性·4星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47687766,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c47687766.target)
	e1:SetOperation(c47687766.operation)
	c:RegisterEffect(e1)
end
-- 定义检索过滤条件：等级为4、机械族、地属性、卡名不是「齿轮齿轮钻地人」自身、且能够加入手卡的怪兽。
function c47687766.filter(c)
	return c:IsLevel(4) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsCode(47687766) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：检查卡组是否存在符合条件的怪兽，并设置将1张卡加入手牌的操作信息。
function c47687766.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件判定：卡组中存在至少1张满足过滤条件的机械族·地属性·4星怪兽（除自身）时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c47687766.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理将进行1张卡从卡组加入手牌的检索，目标位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的怪兽加入手牌并让对方确认，然后给自己附加本回合不能攻击宣言、不是机械族怪兽不能特殊召唤的限制。
function c47687766.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选取1张满足过滤条件的机械族·地属性·4星怪兽（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c47687766.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己不能攻击宣言”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- 不是机械族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c47687766.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“不是机械族怪兽不能特殊召唤”的永续效果注册给当前玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 自肃判定条件：被特殊召唤的怪兽种族不是机械族时，禁止该特殊召唤。
function c47687766.splimit(e,c)
	return c:GetRace()~=RACE_MACHINE
end
