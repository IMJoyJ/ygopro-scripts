--絢嵐たるエルダム
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「绚岚之达维」以外的1只「绚岚」怪兽或1张「旋风」加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 在卡片中注册其相关卡片密码「旋风」
	aux.AddCodeList(c,5318639)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己墓地有「旋风」存在的场合或者对方场上没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把「绚岚之达维」以外的1只「绚岚」怪兽或1张「旋风」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 特殊召唤条件的判断函数
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查自身怪兽区域是否有空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查对方场上是否没有魔法·陷阱卡
		and (not Duel.IsExistingMatchingCard(Card.IsType,c:GetControler(),0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自己墓地是否存在「旋风」
		or Duel.IsExistingMatchingCard(Card.IsCode,c:GetControler(),LOCATION_GRAVE,0,1,nil,5318639))
end
-- 过滤卡组中「绚岚之达维」以外的「绚岚」怪兽或「旋风」的过滤函数
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsSetCard(0x1d1) and c:IsType(TYPE_MONSTER) or c:IsCode(5318639)) and c:IsAbleToHand()
end
-- 检索效果的发动准备与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时检查卡组中是否存在可检索的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送系统提示，提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
