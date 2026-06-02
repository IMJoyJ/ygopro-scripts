--星辰響手プリクル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合，以「星辰响手 金牛魔」以外的自己墓地1只「星辰」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 初始化卡片效果：注册召唤·特殊召唤成功时发动的效果（特殊召唤墓地怪兽并回手），以及作为融合素材送墓时发动的效果（盖放卡组魔陷）。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合，以「星辰响手 金牛魔」以外的自己墓地1只「星辰」怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己场上1只怪兽回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己墓地「星辰响手 金牛魔」以外的、可以特殊召唤的「星辰」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1c9) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择：检查怪兽区域空位以及墓地是否存在合法的「星辰」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「星辰」怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「星辰」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息：包含特殊召唤选定对象的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置连锁信息：包含将自己场上1只怪兽送回手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_MZONE)
end
-- 效果①的处理：特殊召唤目标怪兽，之后让场上1只怪兽回到手牌。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象是否合法且不受王家之谷影响，并将其以表侧表示特殊召唤。
	if tc and aux.NecroValleyFilter()(tc) and tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续的“回到手牌”处理与“特殊召唤”不视为同时进行。
		Duel.BreakEffect()
		-- 提示玩家选择要返回手牌的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 选择自己场上1只可以回到手牌的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,0,1,1,nil)
		if #g>0 then
			-- 显式示出被选择返回手牌的怪兽。
			Duel.HintSelection(g)
			-- 将选择的怪兽因效果送回持有者手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 效果②的发动条件：这张卡在墓地存在，且作为融合召唤的素材送去墓地。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤条件：卡组中可以盖放的「星辰」魔法·陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动准备：检查卡组中是否存在可盖放的「星辰」魔法·陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「星辰」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的处理：从卡组选择1张「星辰」魔法·陷阱卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足条件的「星辰」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡在自己场上盖放。
		Duel.SSet(tp,g)
	end
end
