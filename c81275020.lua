--SRベイゴマックス
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功时才能发动。从卡组把「疾行机人 贝陀螺集合体」以外的1只「疾行机人」怪兽加入手卡。
function c81275020.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c81275020.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功时才能发动。从卡组把「疾行机人 贝陀螺集合体」以外的1只「疾行机人」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81275020,0))  --"加入手牌"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1,81275020)
	e2:SetTarget(c81275020.thtg)
	e2:SetOperation(c81275020.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的条件函数：检查自己场上是否存在怪兽以及是否有可用的怪兽区域
function c81275020.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽区怪兽数量是否为0（即自己场上没有怪兽存在）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 并且检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤函数：选择卡名属于「疾行机人」且非「疾行机人 贝陀螺集合体」的怪兽，且该卡能加入手卡
function c81275020.thfilter(c)
	return c:IsSetCard(0x2016) and not c:IsCode(81275020) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动目标函数：检查卡组中是否存在符合条件的卡，并设置将卡加入手卡的操作信息
function c81275020.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动条件（chk==0）：检查自己卡组是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81275020.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：在连锁中注册“从自己卡组将1张卡加入手卡”的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：从卡组选择1张符合条件的卡加入手卡并向对方展示
function c81275020.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81275020.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
