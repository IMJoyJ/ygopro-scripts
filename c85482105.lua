--Speedroid Darumaknocker
local s,id,o=GetID()
-- 初始化卡片效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：从卡组把这张卡名以外的1只「疾行机人」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从场上送去墓地的场合才能发动。从卡组把1张「疾行机人」魔法·陷阱卡加入手卡。自己场上有「幻透翼」怪兽存在的场合，可以再选场上1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除自身外的「疾行机人」怪兽
function s.spcfilter(c)
	return c:IsSetCard(0x2016) and c:IsAbleToGraveAsCost() and not c:IsCode(id)
end
-- ①效果的代价：从卡组把除自身外的1只「疾行机人」怪兽送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在除自身外的「疾行机人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只「疾行机人」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spcfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选择的怪兽送去墓地作为代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的目标：检查怪兽区空位并特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查主怪兽区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：特殊召唤自身并施加风属性特招限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将自身表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是风属性怪兽不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册只能特殊召唤风属性怪兽的限制
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制：非风属性怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WIND)
end
-- ②效果的发动条件：从场上送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中的「疾行机人」魔法·陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x2016) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标：检查卡组是否存在「疾行机人」魔陷
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在「疾行机人」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤场上表侧表示的「幻透翼」怪兽
function s.cfilter(c)
	return c:IsSetCard(0xff) and c:IsFaceup()
end
-- ②效果的处理：将「疾行机人」魔陷加入手牌，可再破坏场上1只怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「疾行机人」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
		-- 检查场上是否存在「幻透翼」怪兽
		if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
			-- 玩家选择是否破坏场上1只怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			-- 动作连接，前后效果不同时处理
			Duel.BreakEffect()
			-- 提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 选择场上1只怪兽
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
			if sg:GetCount()>0 then
				-- 显示选中的怪兽
				Duel.HintSelection(sg)
				-- 破坏选中的怪兽
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end
