--堕天使ジェフティ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
-- ②：自己场上有天使族·暗属性的融合怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「堕天使」卡或「禁忌的」速攻魔法卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「堕天使 杰胡提」以外的1只「堕天使」怪兽守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不是天使族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己场上有天使族·暗属性的融合怪兽存在的场合，把墓地的这张卡除外，以自己墓地1张「堕天使」卡或「禁忌的」速攻魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	-- ②效果的Cost：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤从卡组特殊召唤的、非同名「堕天使」怪兽的条件函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xef) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的Target函数，检查可用怪兽区域与是否存在可特召怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组是否存在至少1只可以特殊召唤的符合条件的「堕天使」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤卡组中1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果的Operation函数，特殊召唤「堕天使」怪兽，并在特殊召唤后适用直到回合结束时自己不是天使族怪兽不能特殊召唤的自限
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上仍有可用的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只符合条件的「堕天使」怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 以守备表示特殊召唤选择的「堕天使」怪兽
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	-- 直到回合结束时自己不是天使族怪兽不能特殊召唤的自限效果与回收手牌效果的条件函数及相关函数的定义
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制特殊召唤的玩家效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制自己不能特殊召唤天使族以外的怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_FAIRY)
end
-- 过滤场上表侧表示的天使族·暗属性融合怪兽的条件函数
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_FAIRY) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- ②效果的发动条件：自己场上有天使族·暗属性的融合怪兽存在
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在符合条件的天使族·暗属性融合怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤墓地中可以加入手卡的「堕天使」卡或「禁忌的」速攻魔法卡的条件函数
function s.thfilter(c)
	return (c:IsSetCard(0xef)
		or c:IsSetCard(0x11d) and c:IsType(TYPE_QUICKPLAY))
		and c:IsAbleToHand()
end
-- ②效果的Target函数，选择墓地的对象卡并发动
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地（除此卡外）是否存在符合回收条件的卡片作为对象
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张符合回收条件的卡作为对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 设置将对象卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的Operation函数，将被选择的对象卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查该卡是否仍与该连锁相关，且不受王家长眠之谷的效果影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将被选中的墓地中的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
