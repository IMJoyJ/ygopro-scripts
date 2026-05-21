--真炎王 ポニクス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：原本属性是炎属性的自己怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「炎王」魔法·陷阱卡加入手卡。
-- ③：这张卡被破坏送去墓地的场合，下次的准备阶段发动。墓地的这张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数，注册卡片的所有效果
function s.initial_effect(c)
	-- ①：原本属性是炎属性的自己怪兽被战斗·效果破坏的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「炎王」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
	-- ③：这张卡被破坏送去墓地的场合，下次的准备阶段发动。墓地的这张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetOperation(s.threg)
	c:RegisterEffect(e4)
	-- ③：这张卡被破坏送去墓地的场合，下次的准备阶段发动。墓地的这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetRange(LOCATION_GRAVE)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCountLimit(1,id+o*2)
	e5:SetCondition(s.thcon1)
	e5:SetTarget(s.thtg1)
	e5:SetOperation(s.thop1)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 过滤条件：原本属性是炎属性、在自己场上（非魔陷区）被战斗或效果破坏的怪兽
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp) and not c:IsPreviousLocation(LOCATION_SZONE)
		and (c:IsPreviousLocation(LOCATION_MZONE) or c:GetOriginalType()&TYPE_MONSTER~=0)
		and c:GetOriginalAttribute()==ATTRIBUTE_FIRE and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ①号效果的发动条件：检查被破坏的卡中是否存在满足过滤条件的怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ①号效果的发动检测与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的效果处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中可以加入手牌的「炎王」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x81) and c:IsAbleToHand() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②号效果的发动检测与操作信息设置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测阶段，检查自己卡组中是否存在至少1张满足条件的「炎王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置加入手牌的操作信息，表示从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的效果处理：从卡组将1张「炎王」魔法·陷阱卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「炎王」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if #g~=0 then
		-- 将选择的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③号效果的辅助注册：当这张卡被破坏送去墓地时，记录当前回合数并注册时效标记
function s.threg(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 判断当前是否已经是准备阶段
		if Duel.GetCurrentPhase()==PHASE_STANDBY then
			-- 将当前的回合数记录在效果的Label中，用于后续判断是否是“下次”准备阶段
			e:SetLabel(Duel.GetTurnCount())
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,2)
		else
			e:SetLabel(0)
			c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY,0,1)
		end
	end
end
-- ③号效果的发动条件：当前回合数不等于被破坏时的回合数，且卡片带有被破坏送墓的标记
function s.thcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合数是否与被破坏时的回合数不同，且自身仍持有被破坏送墓的标记
	return e:GetLabelObject():GetLabel()~=Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(id)>0
end
-- ③号效果的发动检测与操作信息设置
function s.thtg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手牌的操作信息，将墓地的自身作为回收对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③号效果的效果处理：将墓地的自身加入手牌
function s.thop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡因效果加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
