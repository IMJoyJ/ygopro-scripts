--天帝従騎イデア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「天帝从骑 爱迪娅」以外的1只攻击力800/守备力1000的怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合，以自己的除外状态的1张「帝王」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c95457011.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「天帝从骑 爱迪娅」以外的1只攻击力800/守备力1000的怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95457011,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,95457011)
	e1:SetTarget(c95457011.sptg)
	e1:SetOperation(c95457011.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合，以自己的除外状态的1张「帝王」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95457011,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,95457012)
	e3:SetTarget(c95457011.thtg)
	e3:SetOperation(c95457011.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中除「天帝从骑 爱迪娅」以外的攻击力800/守备力1000且可以特殊召唤的怪兽
function c95457011.spfilter(c,e,tp)
	return c:IsAttack(800) and c:IsDefense(1000) and not c:IsCode(95457011) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动准备（检查怪兽区域空位以及卡组中是否存在符合条件的怪兽，并设置特殊召唤的操作信息）
function c95457011.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c95457011.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息为从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的执行（从卡组特殊召唤符合条件的怪兽，并适用直到回合结束时自己不能从额外卡组特殊召唤怪兽的限制）
function c95457011.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只满足过滤条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c95457011.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧守备表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能从额外卡组把怪兽特殊召唤。②：这张卡被送去墓地的场合，以自己的除外状态的1张「帝王」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95457011.splimit)
	-- 注册该限制效果给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽来源为额外卡组
function c95457011.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA)
end
-- 过滤自己除外状态的表侧表示「帝王」魔法·陷阱卡
function c95457011.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的发动准备（检查并选择除外状态的「帝王」魔法·陷阱卡作为对象，并设置加入手卡的操作信息）
function c95457011.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c95457011.thfilter(chkc) end
	-- 检查自己除外状态的卡中是否存在可以成为效果对象的「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c95457011.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家选择1张除外状态的「帝王」魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c95457011.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁处理中的操作信息为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的执行（将作为对象的卡加入手卡）
function c95457011.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
