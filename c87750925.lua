--Disguise, the Copycat Hero
-- 效果：
-- 自己场上或墓地有装备魔法卡存在的场合：可以把这张卡从手卡特殊召唤。
-- 这张卡召唤·特殊召唤的场合：可以从卡组把1张「咒怨仿品·圣剑」加入手卡。
-- 这张卡有装备卡装备中的场合：可以以场上1只持有等级的调整以外的战士族怪兽为对象；这张卡的等级和卡名直到回合结束时变成和那只怪兽相同。
-- 「效仿英杰 伪装者」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 初始化函数，注册卡片效果
function s.initial_effect(c)
	-- 在卡片中注册其相关卡片「咒怨仿品·圣剑」的卡号
	aux.AddCodeList(c,23249029)
	-- 自己场上或墓地有装备魔法卡存在的场合：可以把这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡召唤·特殊召唤的场合：可以从卡组把1张「咒怨仿品·圣剑」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡有装备卡装备中的场合：可以以场上1只持有等级的调整以外的战士族怪兽为对象；这张卡的等级和卡名直到回合结束时变成和那只怪兽相同。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"改变卡名等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.lvcon)
	e4:SetTarget(s.lvtg)
	e4:SetOperation(s.lvop)
	c:RegisterEffect(e4)
end
-- 过滤条件：表侧表示的装备魔法卡
function s.cfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsFaceupEx()
end
-- 特殊召唤效果的发动条件函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上或墓地是否存在装备魔法卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤效果的发动准备与合法性检查
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中的「咒怨仿品·圣剑」
function s.thfilter(c)
	return c:IsCode(23249029) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检查
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「咒怨仿品·圣剑」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张「咒怨仿品·圣剑」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 改变卡名等级效果的发动条件：自身有装备卡装备中
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipCount()>0
end
-- 过滤条件：场上表侧表示、持有等级、非调整的战士族怪兽，且等级或卡名与自身不同
function s.lvfilter(c,lv,ec)
	return c:IsFaceup() and c:IsLevelAbove(1) and not c:IsType(TYPE_TUNER) and c:IsRace(RACE_WARRIOR)
		and (not c:IsLevel(lv) or not c:IsCode(ec:GetCode()))
end
-- 改变卡名等级效果的发动准备与取对象处理
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lv=c:GetLevel()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc,lv,c) end
	-- 检查场上是否存在可作为对象的满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,lv,c) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的怪兽作为效果的对象
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c,lv,c)
end
-- 改变卡名等级效果的执行函数
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToChain() and c:IsFaceup() and c:IsRelateToChain() then
		-- 这张卡的等级直到回合结束时变成和那只怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(tc:GetLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 这张卡的卡名直到回合结束时变成和那只怪兽相同。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_CODE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(tc:GetCode())
		c:RegisterEffect(e2)
	end
end
