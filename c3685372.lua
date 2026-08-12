--CX ギミック・パペット－ファナティクス・マキナ
-- 效果：
-- 9星怪兽×3
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「人偶」陷阱卡加入手卡。
-- ②：把这张卡1个超量素材取除才能发动。从自己或对方的墓地把1只怪兽在对方场上守备表示特殊召唤。
-- ③：对方场上有怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤程序、启用复活限制，并注册三个效果
function s.initial_effect(c)
	-- 设置该卡为9星怪兽×3的XYZ召唤条件
	aux.AddXyzProcedure(c,nil,9,3)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「人偶」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把这张卡1个超量素材取除才能发动。从自己或对方的墓地把1只怪兽在对方场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选双方墓地的怪兽在对方场上特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 注册一个合并的特殊召唤成功事件监听器，用于触发第三个效果
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- ③：对方场上有怪兽特殊召唤的场合，以那之内的1只为对象才能发动。那只怪兽破坏，给与对方那个原本攻击力一半数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"伤害"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(custom_code)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+2*o)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数，筛选「人偶」陷阱卡
function s.thfilter(c)
	return c:IsSetCard(0x83) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标，指定从卡组检索1张「人偶」陷阱卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的处理信息，指定将卡送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理函数，选择并把卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 取除超量素材的处理函数，检查并移除1个超量素材
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 特殊召唤过滤函数，判断怪兽是否可以特殊召唤
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 设置特殊召唤效果的处理目标，检查是否有满足条件的怪兽可特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤条件，检查对方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤条件，检查墓地是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示对方玩家选择效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的处理信息，指定从墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,PLAYER_ALL,LOCATION_GRAVE)
end
-- 特殊召唤效果的处理函数，选择并特殊召唤怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤条件，检查对方场上是否有空位
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到对方场上
		Duel.SpecialSummon(g,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 破坏效果的过滤函数，筛选对方场上的怪兽
function s.desfilter(c,tp,e)
	return c:IsLocation(LOCATION_MZONE) and c:IsControler(1-tp) and c:IsCanBeEffectTarget(e)
end
-- 破坏效果的发动条件函数，判断是否有对方场上的怪兽被特殊召唤
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 设置破坏效果的处理目标，选择要破坏的怪兽并设置伤害信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=eg:Filter(s.desfilter,nil,tp,e)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return #g>0 end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 设置当前处理的连锁对象为选中的怪兽
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要破坏的卡
		Duel.Hint(HINTMSG_DESTROY,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择要破坏的怪兽
		sg=Duel.SelectTarget(tp,aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g)
	end
	-- 设置破坏效果的处理信息，指定破坏怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,1,0,0)
	if sg:GetFirst():IsFaceup() and math.max(0,sg:GetFirst():GetTextAttack())>0 then
		-- 设置伤害效果的处理信息，指定给与对方伤害
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
	end
end
-- 破坏效果的处理函数，破坏目标怪兽并造成伤害
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前处理的连锁对象
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效，是否为怪兽并被破坏
	if tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		local atk=math.max(0,tc:GetTextAttack())
		if atk>0 then
			-- 给与对方原本攻击力一半数值的伤害
			Duel.Damage(1-tp,math.floor(atk/2),REASON_EFFECT)
		end
	end
end
