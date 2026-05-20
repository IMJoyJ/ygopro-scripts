--No.71 リバリアン・シャーク
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，以「No.71 海异鲨」以外的自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡1个超量素材在那只怪兽下面重叠作为超量素材。
-- ②：这张卡被送去墓地的场合才能发动。从卡组选1张「升阶魔法」魔法卡在卡组最上面放置。
function c59479050.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加超量召唤手续：3星怪兽×2
	aux.AddXyzProcedure(c,nil,3,2)
	-- ①：1回合1次，以「No.71 海异鲨」以外的自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽特殊召唤，把这张卡1个超量素材在那只怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59479050,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetCondition(c59479050.spcon)
	e1:SetTarget(c59479050.sptg)
	e1:SetOperation(c59479050.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组选1张「升阶魔法」魔法卡在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59479050,2))  --"卡组检索"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(c59479050.tdtg)
	e2:SetOperation(c59479050.tdop)
	c:RegisterEffect(e2)
end
-- 设定该卡片的「No.」数值为71
aux.xyz_number[59479050]=71
-- 效果①的发动条件：这张卡有超量素材存在
function c59479050.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>0
end
-- 效果①的过滤条件：自己墓地「No.71 海异鲨」以外的「No.」超量怪兽，且可以特殊召唤
function c59479050.spfilter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and not c:IsCode(59479050) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备（检查与选择目标）
function c59479050.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59479050.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「No.」超量怪兽
		and Duel.IsExistingTarget(c59479050.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「No.」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59479050.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的执行函数：特殊召唤目标怪兽，并将这张卡的一个超量素材重叠到该怪兽下
function c59479050.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果对象怪兽仍符合条件，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and c:GetOverlayCount()>0 then
		-- 提示玩家选择这张卡的一个超量素材
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(59479050,1))  --"请选择这张卡的超量素材"
		local mg=c:GetOverlayGroup():Select(tp,1,1,nil)
		local oc=mg:GetFirst():GetOverlayTarget()
		-- 将选中的超量素材重叠到特殊召唤的怪兽下面
		Duel.Overlay(tc,mg)
		-- 触发超量素材被取除的单体时点
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
-- 效果②的过滤条件：「升阶魔法」魔法卡
function c59479050.tdfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x95)
end
-- 效果②的发动准备（检查卡组中是否存在目标卡且卡组数量大于1）
function c59479050.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「升阶魔法」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59479050.tdfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组数量是否大于1
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 效果②的执行函数：洗牌后将选中的「升阶魔法」魔法卡放置在卡组最上面
function c59479050.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要在卡组最上面放置的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(59479050,3))  --"请选择要在卡组最上面放置的卡"
	-- 从卡组中选择1张「升阶魔法」魔法卡
	local g=Duel.SelectMatchingCard(tp,c59479050.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的一张卡
		Duel.ConfirmDecktop(tp,1)
	end
end
