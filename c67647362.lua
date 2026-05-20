--海造賊－キャプテン黒髭
-- 效果：
-- 包含「海造贼」怪兽的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：以自己场上1只效果怪兽为对象才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，作为对象的自己的效果怪兽当作装备卡使用给那只特殊召唤的怪兽装备。那之后，自己从卡组抽1张。这个效果在对方回合也能发动。
function c67647362.initial_effect(c)
	-- 添加连接召唤手续：需要2只怪兽，且必须包含「海造贼」怪兽
	aux.AddLinkProcedure(c,nil,2,2,c67647362.lcheck)
	c:EnableReviveLimit()
	-- ①：以自己场上1只效果怪兽为对象才能发动。把持有和对方的场上·墓地的怪兽的其中任意种相同属性的1只「海造贼」怪兽从额外卡组特殊召唤，作为对象的自己的效果怪兽当作装备卡使用给那只特殊召唤的怪兽装备。那之后，自己从卡组抽1张。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67647362,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,67647362)
	e1:SetTarget(c67647362.sptg)
	e1:SetOperation(c67647362.spop)
	c:RegisterEffect(e1)
end
-- 过滤连接素材：检查素材组中是否存在至少1只「海造贼」怪兽
function c67647362.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x13f)
end
-- 过滤对方场上或墓地的怪兽：检查其属性是否在额外卡组有对应的「海造贼」怪兽可特殊召唤
function c67647362.cfilter(c,e,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
		-- 检查额外卡组中是否存在与该怪兽属性相同且可以特殊召唤的「海造贼」怪兽
		and Duel.IsExistingMatchingCard(c67647362.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetAttribute())
end
-- 过滤额外卡组中可以特殊召唤的、与指定属性相同且属于「海造贼」系列的怪兽
function c67647362.spfilter(c,e,tp,attr)
	return c:IsSetCard(0x13f) and c:IsAttribute(attr) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外卡组怪兽特殊召唤到场上所需的可用区域是否充足
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 过滤自己场上表侧表示的效果怪兽
function c67647362.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果①的发动准备与合法性检测
function c67647362.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c67647362.tgfilter(chkc) end
	-- 检查自己魔陷区是否有空位以将对象怪兽作为装备卡装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为对象的效果怪兽
		and Duel.IsExistingTarget(c67647362.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上或墓地是否存在满足属性条件的怪兽
		and Duel.IsExistingMatchingCard(c67647362.cfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,e,tp)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的效果怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67647362.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤对方场上表侧表示或对方墓地的怪兽
function c67647362.cfilter2(c)
	return c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)
end
-- 效果①的效果处理
function c67647362.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tgc=Duel.GetFirstTarget()
	-- 获取对方场上表侧表示及对方墓地的所有怪兽
	local g=Duel.GetMatchingGroup(c67647362.cfilter2,tp,0,LOCATION_MZONE+LOCATION_GRAVE,nil)
	local tc=g:GetFirst()
	local attr=0
	while tc do
		attr=attr|tc:GetAttribute()
		tc=g:GetNext()
	end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只持有与上述对方怪兽相同属性的「海造贼」怪兽
	local sg=Duel.SelectMatchingCard(tp,c67647362.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,attr)
	local sc=sg:GetFirst()
	-- 将选中的「海造贼」怪兽在自己场上表侧表示特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 and sc:IsFaceup()
		and tgc:IsRelateToEffect(e) and tgc:IsControler(tp) and tgc:IsFaceup() and tgc:IsType(TYPE_EFFECT) then
		-- 将作为对象的怪兽作为装备卡装备给特殊召唤的「海造贼」怪兽，若装备失败则结束处理
		if not Duel.Equip(tp,tgc,sc,false) then return end
		-- 作为对象的自己的效果怪兽当作装备卡使用给那只特殊召唤的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(sc)
		e1:SetValue(c67647362.eqlimit)
		tgc:RegisterEffect(e1)
		-- 中断当前效果处理，使后续的抽卡处理不与特殊召唤及装备同时处理
		Duel.BreakEffect()
		-- 从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 定义装备限制：该卡只能装备给通过此效果特殊召唤的那只怪兽
function c67647362.eqlimit(e,c)
	return c==e:GetLabelObject()
end
