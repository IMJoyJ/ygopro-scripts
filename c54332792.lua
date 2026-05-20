--ネオ・カイザー・シーホース
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己场上有「青眼白龙」存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：以自己场上1只光属性调整为对象才能发动。那只怪兽的等级上升或下降1星。
-- ③：这张卡从场上送去墓地的场合才能发动。除「新帝王海马」外的1只「青眼」怪兽或者1只有「青眼白龙」的卡名记述的怪兽从卡组送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 将「青眼白龙」的卡名记述在卡片中
	aux.AddCodeList(c,89631139)
	-- ①：自己场上有「青眼白龙」存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以自己场上1只光属性调整为对象才能发动。那只怪兽的等级上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	-- ③：这张卡从场上送去墓地的场合才能发动。除「新帝王海马」外的1只「青眼」怪兽或者1只有「青眼白龙」的卡名记述的怪兽从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"卡组送墓"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的「青眼白龙」
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(89631139)
end
-- 效果①的发动条件：自己场上有「青眼白龙」存在
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「青眼白龙」
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备（检查与设置操作信息）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的特殊召唤处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤条件：自己场上表侧表示、等级1以上的光属性调整怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_TUNER)
end
-- 效果②的发动准备（选择对象）
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查自己场上是否存在可以作为对象的光属性调整怪兽
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只光属性调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的等级变化处理
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) then
		local op=0
		if tc:IsLevel(1) then op=1
		-- 让玩家选择等级上升或下降
		else op=aux.SelectFromOptions(tp,
			{true,aux.Stringid(id,3),1},  --"等级上升"
			{true,aux.Stringid(id,4),-1})  --"等级下降"
		end
		-- 那只怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(op)
		tc:RegisterEffect(e1)
	end
end
-- 效果③的发动条件：这张卡从场上送去墓地
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡组中除「新帝王海马」以外的「青眼」怪兽，或者记述了「青眼白龙」卡名的怪兽
function s.tgfilter(c)
	-- 检查卡片是否属于「青眼」系列或记述了「青眼白龙」卡名，且是除自身以外的、可以送去墓地的怪兽
	return (c:IsSetCard(0xdd) or aux.IsCodeListed(c,89631139)) and c:IsAbleToGrave() and not c:IsCode(id) and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动准备（检查与设置操作信息）
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③的送墓处理
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
