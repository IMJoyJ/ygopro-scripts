--馬頭鬼
-- 效果：
-- ①：把墓地的这张卡除外，以自己墓地1只不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。
function c92826944.initial_effect(c)
	-- ①：把墓地的这张卡除外，以自己墓地1只不死族怪兽为对象才能发动。那只不死族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92826944,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	-- 设置发动成本为将墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c92826944.target)
	e1:SetOperation(c92826944.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地的不死族且可以特殊召唤的怪兽
function c92826944.filter(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与对象选择
function c92826944.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c92826944.filter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的不死族怪兽
		and Duel.IsExistingTarget(c92826944.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只不死族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92826944.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置特殊召唤的操作信息（包含对象怪兽和数量1）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤对象怪兽）
function c92826944.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRace(RACE_ZOMBIE) and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
