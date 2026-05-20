--デーモン・イーター
-- 效果：
-- ①：「恶魔食魔兽」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：这张卡在墓地存在的场合，对方结束阶段，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
function c60666820.initial_effect(c)
	c:SetUniqueOnField(1,0,60666820)
	-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c60666820.spcon)
	c:RegisterEffect(e1)
	-- ③：这张卡在墓地存在的场合，对方结束阶段，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60666820,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c60666820.condition)
	e2:SetTarget(c60666820.target)
	e2:SetOperation(c60666820.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的魔法师族怪兽
function c60666820.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 手卡特殊召唤效果的特殊召唤条件
function c60666820.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查自己场上是否存在表侧表示的魔法师族怪兽
		and Duel.IsExistingMatchingCard(c60666820.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
-- 墓地特殊召唤效果的发动条件
function c60666820.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方的回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：自己场上表侧表示的怪兽（若怪兽区已满，则必须选择主要怪兽区域的怪兽以空出格子）
function c60666820.filter(c,ft)
	return c:IsFaceup() and (ft>0 or c:GetSequence()<5)
end
-- 墓地特殊召唤效果的发动准备（选择对象与效果分类声明）
function c60666820.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60666820.filter(chkc,ft) end
	if chk==0 then return ft>-1 and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(c60666820.filter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c60666820.filter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 声明该效果含有破坏该怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 声明该效果含有特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 墓地特殊召唤效果的效果处理
function c60666820.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用该效果，则将其破坏，并在破坏成功且自身仍在墓地时进行后续处理
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将这张卡从墓地表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
