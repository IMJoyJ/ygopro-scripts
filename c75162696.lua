--ウィクトーリア
-- 效果：
-- 1回合1次，可以把对方墓地存在的1只龙族怪兽在自己场上特殊召唤。只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的天使族怪兽作为攻击对象。
function c75162696.initial_effect(c)
	-- 1回合1次，可以把对方墓地存在的1只龙族怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75162696,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c75162696.sptg)
	e1:SetOperation(c75162696.spop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方不能选择表侧表示存在的其他的天使族怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c75162696.tg)
	c:RegisterEffect(e2)
end
-- 定义不能被选择为攻击对象的目标：表侧表示、非自身且是天使族的怪兽
function c75162696.tg(e,c)
	return c:IsFaceup() and c~=e:GetHandler() and c:IsRace(RACE_FAIRY)
end
-- 过滤对方墓地中可以特殊召唤的龙族怪兽
function c75162696.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的对象选择与可行性检查
function c75162696.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c75162696.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在可以作为效果对象的龙族怪兽
		and Duel.IsExistingTarget(c75162696.filter,tp,0,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只符合条件的龙族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c75162696.filter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息，表示该效果包含特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的对方墓地的龙族怪兽在自己场上特殊召唤
function c75162696.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动阶段选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
