--鍵魔人ハミハミハミング
-- 效果：
-- 3星怪兽×2
-- ①：这张卡特殊召唤成功时，以自己墓地1只「魔人」超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把最多2张手卡在那只怪兽下面重叠作为超量素材。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只「魔人」超量怪兽为对象才能发动。这个回合，那只怪兽可以向对方直接攻击。
function c90098780.initial_effect(c)
	-- 设置该卡超量召唤的手续为等级3怪兽2只
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功时，以自己墓地1只「魔人」超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把最多2张手卡在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90098780,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c90098780.sptg)
	e1:SetOperation(c90098780.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只「魔人」超量怪兽为对象才能发动。这个回合，那只怪兽可以向对方直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90098780,1))  --"直接攻击"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCost(c90098780.atkcost)
	e2:SetTarget(c90098780.atktg)
	e2:SetOperation(c90098780.atkop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地中可以特殊召唤的「魔人」超量怪兽
function c90098780.filter(c,e,tp)
	return c:IsSetCard(0x6d) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件判定与对象选择
function c90098780.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c90098780.filter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在符合条件的「魔人」超量怪兽
		and Duel.IsExistingTarget(c90098780.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「魔人」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c90098780.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的具体效果处理（特殊召唤及重叠手牌作为素材）
function c90098780.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合条件，则将其在自己场上表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取自己手牌中可以作为超量素材的卡片组
		local g=Duel.GetMatchingGroup(Card.IsCanOverlay,tp,LOCATION_HAND,0,nil)
		-- 若手牌有可用卡，询问玩家是否要将手牌重叠作为超量素材
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(90098780,2)) then  --"是否要选择手卡在怪兽下面叠放？"
			-- 提示玩家选择要作为超量素材的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local sg=g:Select(tp,1,2,nil)
			-- 将选择的手牌重叠在特殊召唤的怪兽下面作为超量素材
			Duel.Overlay(tc,sg)
		end
	end
end
-- 效果②的发动代价：取除这张卡的1个超量素材
function c90098780.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己场上表侧表示且未获得直接攻击效果的「魔人」超量怪兽
function c90098780.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x6d) and c:IsType(TYPE_XYZ) and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
-- 效果②的发动条件判定与对象选择
function c90098780.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c90098780.atkfilter(chkc) end
	-- 判定自己场上是否存在符合条件的「魔人」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c90098780.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只「魔人」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c90098780.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的具体效果处理（赋予直接攻击能力）
function c90098780.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽可以向对方直接攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
