--ウィッチクラフト・マルカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡·场上的这张卡解放才能发动。从卡组把1张「魔女术」场地·永续魔法卡加入手卡。
-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「魔女术」怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤，对方场上1只怪兽解放。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册两个效果：e1为手卡·场上发动的起动效果（检索，解放这张卡为Cost，检索卡组「魔女术」场地·永续魔法卡，1回合1次）；e2为墓地存在的诱发选发效果（特殊召唤+解放，场合型，离场时触发，1回合1次）
function s.initial_effect(c)
	-- ①：把手卡·场上的这张卡解放才能发动。从卡组把1张「魔女术」场地·永续魔法卡加入手卡。（这个卡名的①的效果1回合只能使用1次）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己场上的表侧表示的「魔女术」怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤，对方场上1只怪兽解放。（这个卡名的②的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
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
-- 效果的发动Cost：先检查这张卡能否被解放，然后将这张卡解放
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 把手卡·场上的这张卡解放才能发动（将这张卡作为Cost解放）
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 检索过滤条件：「魔女术」（系列字段0x128）的场地·永续魔法卡且可以加入手卡
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 发动条件检查：确认卡组存在至少1张满足条件的卡，并设置效果处理的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「魔女术」场地·永续魔法卡（发动前提）
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将从卡组把1张卡加入手卡（用于星尘龙等效果的连锁检测）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组检索1张「魔女术」场地·永续魔法卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组把1张「魔女术」场地·永续魔法卡加入手卡（让玩家从卡组选择1张满足条件的卡）
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入持有者手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的那张卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 触发条件过滤：离场前是自己场上表侧表示的「魔女术」怪兽，且因对方的效果从场上离开
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x128) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 发动条件：离场卡中存在满足条件的卡（且离场的不含这张卡自身），即自己场上的表侧表示的「魔女术」怪兽因对方的效果从场上离开
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 发动目标检查：自己主要怪兽区有空位、这张卡可以特殊召唤、且对方场上存在1只可被效果解放的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在至少1只可以被效果解放的怪兽
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置操作信息：将这张卡特殊召唤（对象确定，为这张卡自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：将对方场上1只怪兽解放（对象处理时才确定，预计处理对方场上1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理：将这张卡特殊召唤，赋予其「从场上离开的场合除外」的效果，然后选择对方场上1只怪兽解放
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡与此连锁关联、不受王家长眠之谷影响，然后将这张卡以表侧表示特殊召唤到自己场上
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这张卡特殊召唤，对方场上1只怪兽解放。这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 让对方场上1只怪兽解放（从对方场上选择1只可被效果解放的怪兽）
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理，使解放与特殊召唤视为不同时处理（避免错时点问题）
			Duel.BreakEffect()
			-- 显示所选怪兽被指定的动画并记录其为被选对象
			Duel.HintSelection(g)
			-- 将选择的对方场上怪兽以效果原因解放
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
