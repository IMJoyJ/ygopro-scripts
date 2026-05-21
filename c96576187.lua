--ライトロード・デーモン ヴァイス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡让1张其他的「光道」卡回到卡组最上面才能发动。这张卡从手卡特殊召唤。那之后，从自己卡组上面把2张卡送去墓地。
-- ②：这张卡从卡组送去墓地的场合，以「光道恶魔 魏丝」以外的自己墓地1只「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果：注册手卡特召效果与卡组送墓特召效果
function s.initial_effect(c)
	-- ①：从手卡让1张其他的「光道」卡回到卡组最上面才能发动。这张卡从手卡特殊召唤。那之后，从自己卡组上面把2张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从卡组送去墓地的场合，以「光道恶魔 魏丝」以外的自己墓地1只「光道」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从墓地特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的「光道」卡片，且能回到卡组
function s.cfilter(c)
	return c:IsSetCard(0x38) and c:IsAbleToDeckAsCost()
end
-- 效果①的发动代价：从手卡让1张其他的「光道」卡回到卡组最上面
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中除自身以外满足过滤条件的「光道」卡片组
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,e:GetHandler())
	if chk==0 then return cg:GetCount()>0 end
	local g=cg:Select(tp,1,1,nil)
	-- 给对方确认选中的「光道」卡片
	Duel.ConfirmCards(1-tp,g)
	-- 作为代价，将选中的卡片送回持有者卡组的最上面
	Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果①的发动准备与合法性检测（检测怪兽区域空格、自身特召可能性以及卡组是否能送墓2张）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 第一阶段：检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自身是否能特殊召唤，且自己卡组是否能将2张卡送去墓地
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsPlayerCanDiscardDeck(tp,2) end
	-- 设置连锁处理信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置连锁处理信息：从卡组送去墓地2张卡
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- 效果①的效果处理：特殊召唤自身，那之后从卡组上面把2张卡送去墓地
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果关联，则将其以表侧表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续的送墓处理与特殊召唤不视为同时处理
		Duel.BreakEffect()
		-- 作为效果处理，将自己卡组最上面的2张卡送去墓地
		Duel.DiscardDeck(tp,2,REASON_EFFECT)
	end
end
-- 效果②的发动条件：此卡从卡组送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_DECK)
end
-- 过滤条件：自己墓地中除「光道恶魔 魏丝」以外的「光道」怪兽，且能特殊召唤
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x38) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与对象选择（检测怪兽区域空格并选择墓地中的目标怪兽）
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 第一阶段：检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足过滤条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「光道」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理信息：特殊召唤选中的目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
