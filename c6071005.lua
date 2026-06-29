--ウィッチクラフト・マルカ
local s,id,o=GetID()
-- 注册解放自身检索魔女术场地或永续魔法、以及从墓地诱发特召并解放对方场上怪兽的两个效果
function s.initial_effect(c)
	-- ①：把手卡·场上的这张卡解放才能发动。从卡组把1张「魔女术」场地魔法卡或「魔女术」永续魔法卡加入手手卡
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的表侧表示的「魔女术」怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤，解放对方场上1只怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_RELEASE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动代价（Cost）：解放手卡·场上的此卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放本卡本身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：卡组中是「魔女术」字段的场地魔法或永续魔法，且可以加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 效果①的Target函数：检查卡组是否存在可检索的「魔女术」场地或永续魔法卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「魔女术」场地或永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前效果的操作信息为从卡组回收1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的Operation函数：从卡组将1张满足条件的「魔女术」场地或永续魔法卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「魔女术」场地或永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认所加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：表侧表示存在于自己怪兽区、由于对方的效果而离开场上的「魔女术」怪兽
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x128) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 效果②的Condition条件函数：检查因对方效果离场的怪兽中是否存在自己场上的「魔女术」怪兽，且不包含本卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 效果②的Target函数：检查自己场上是否有空怪兽区域、本卡是否能特殊召唤、以及对方场上是否存在可解放的怪兽，并设置特殊召唤和解放的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且对方场上是否存在至少1只可以被效果解放的怪兽
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置当前效果的操作信息为将自己特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置当前效果的操作信息为解放对方场上的怪兽
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果②的Operation函数：将自身特殊召唤，若特殊召唤成功则注册离场时除外的限制，并选择对方场上1只怪兽解放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择对方场上要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择对方场上1只可被解放的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，建立“那之后”的时点
			Duel.BreakEffect()
			-- 在场上亮出被选择的怪兽以示确认
			Duel.HintSelection(g)
			-- 因效果将选中的对方怪兽解放
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
