--ウィッチクラフト・マルカ
local s,id,o=GetID()
-- 卡片效果的初始化注册
function s.initial_effect(c)
	-- ①：把手卡·怪兽区域的这张卡解放才能发动。从卡组把1张「魔女术」场地·永续魔法卡加入手卡。
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
	-- ②：这张卡在墓地存在的场合，自己场上的表侧表示「魔女术」怪兽因对方的效果从场上离开的场合才能发动。这张卡特殊召唤，选对方场上1只怪兽解放。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 检索效果的代价（Cost）执行函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 卡组中「魔女术」场地·永续魔法卡的过滤条件
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_SPELL) and c:IsType(TYPE_FIELD+TYPE_CONTINUOUS) and c:IsAbleToHand()
end
-- 检索效果的靶向/基本发动条件（Target）检测与操作信息注册
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「魔女术」场地·永续魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 注册“卡组检索加入手卡”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中1张「魔女术」场地·永续魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 触发离场效果的自己场上「魔女术」怪兽的过滤条件
function s.cfilter(c,tp,rp)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousControler(tp) and c:IsPreviousSetCard(0x128) and c:IsPreviousLocation(LOCATION_MZONE)
		and rp==1-tp and c:IsReason(REASON_EFFECT)
end
-- 特殊召唤效果的发动条件判定（自己场上表侧表示「魔女术」怪兽因对方效果离场，且离场怪兽不包含自身）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp,rp) and not eg:IsContains(e:GetHandler())
end
-- 特殊召唤与解放效果的靶向/基本发动条件检测与操作信息注册
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在可以通过效果解放的怪兽
		and Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil) end
	-- 注册“特殊召唤自身”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 注册“解放对方场上怪兽”的操作信息
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
end
-- 特殊召唤与解放效果的执行函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与连锁相关且未受墓地限制影响，将其特殊召唤并判断是否成功
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。那之后，选对方场上1只怪兽解放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择对方场上1只可解放的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断效果处理，使之后的效果不视为同时处理
			Duel.BreakEffect()
			-- 显示被选为解放对象的动画效果
			Duel.HintSelection(g)
			-- 解放选中的对方怪兽
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
