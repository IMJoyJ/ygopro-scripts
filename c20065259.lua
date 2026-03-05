--銃の忍者－火光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤·反转的场合才能发动。从自己的手卡·墓地选「铳之忍者-火光」以外的1只「忍者」怪兽里侧守备表示特殊召唤。
-- ②：这张卡在墓地存在，只以自己场上的「忍者」卡1张或者里侧守备表示怪兽1只为对象的对方的效果发动时才能发动。这张卡里侧守备表示特殊召唤，那张成为对象的卡回到持有者手卡。
local s,id,o=GetID()
-- 注册卡牌的4个效果：①通常召唤成功时发动、②特殊召唤成功时发动、③反转时发动、④墓地发动的诱发效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤·反转的场合才能发动。从自己的手卡·墓地选「铳之忍者-火光」以外的1只「忍者」怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	-- ②：这张卡在墓地存在，只以自己场上的「忍者」卡1张或者里侧守备表示怪兽1只为对象的对方的效果发动时才能发动。这张卡里侧守备表示特殊召唤，那张成为对象的卡回到持有者手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_MSET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.condition)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
-- 过滤满足「忍者」卡族、可以里侧守备表示特殊召唤、且不是火光自身的怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x2b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
		and not c:IsCode(id)
end
-- 判断是否满足①效果的发动条件：场上存在空位且手牌或墓地存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌或墓地是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理信息：将要特殊召唤1只怪兽，目标为手牌或墓地的任意怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 处理①效果的发动：选择并特殊召唤满足条件的怪兽，确认对方可见
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		-- 将选中的怪兽特殊召唤到场上，里侧守备表示
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方确认特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断②效果是否可以发动：对方发动效果且该效果有目标，且目标为己方场上满足条件的怪兽
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tc=g:GetFirst()
	e:SetLabelObject(tc)
	return tc:IsOnField() and tc:IsControler(tp)
		and (tc:IsFaceup() and tc:IsSetCard(0x2b)
			or tc:IsLocation(LOCATION_MZONE) and tc:IsPosition(POS_FACEDOWN_DEFENSE))
end
-- 判断②效果的发动条件：场上存在空位、自身可以特殊召唤、目标卡可以回手
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 判断场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) and tc and tc:IsAbleToHand() end
	-- 设置连锁处理的目标卡
	Duel.SetTargetCard(tc)
	-- 设置连锁处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置连锁处理信息：将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,tc,1,0,0)
end
-- 处理②效果的发动：将自身特殊召唤，将目标卡送回手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否可以特殊召唤
	if not c:IsRelateToEffect(e) or Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)==0 then return end
	-- 向对方确认特殊召唤的卡
	Duel.ConfirmCards(1-tp,Group.FromCards(c))
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 将目标卡送回手牌
	if tc and tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
