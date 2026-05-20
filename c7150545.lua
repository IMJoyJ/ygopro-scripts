--カッター・シャーク
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：以自己场上1只水属性怪兽为对象才能发动。和那只怪兽是卡名不同并是等级相同的1只鱼族怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：把这张卡在水属性怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或5星使用。
function c7150545.initial_effect(c)
	-- ①：以自己场上1只水属性怪兽为对象才能发动。和那只怪兽是卡名不同并是等级相同的1只鱼族怪兽从卡组守备表示特殊召唤。这个效果特殊召唤的怪兽在这个回合不能把效果发动。这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(7150545,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,7150545)
	e1:SetTarget(c7150545.sptg)
	e1:SetOperation(c7150545.spop)
	c:RegisterEffect(e1)
	-- ②：把这张卡在水属性怪兽的超量召唤使用的场合，可以把这张卡的等级当作3星或5星使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_XYZ_LEVEL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c7150545.xyzlv)
	e2:SetLabel(3)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetLabel(5)
	c:RegisterEffect(e3)
end
-- 过滤作为效果对象的自己场上的表侧表示水属性怪兽
function c7150545.tgfilter(c,e,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(1)
		-- 检查卡组中是否存在满足特殊召唤条件的鱼族怪兽
		and Duel.IsExistingMatchingCard(c7150545.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,c:GetLevel(),c:GetCode())
end
-- 过滤卡组中与目标怪兽等级相同、卡名不同，且可以守备表示特殊召唤的鱼族怪兽
function c7150545.spfilter(c,e,tp,lv,code)
	return c:IsRace(RACE_FISH) and c:IsLevel(lv) and not c:IsCode(code)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①的效果的发动准备与对象选择
function c7150545.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7150545.tgfilter(chkc,e,tp) end
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在满足条件的可作为效果对象的水属性怪兽
		and Duel.IsExistingTarget(c7150545.tgfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7150545.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①的效果的处理
function c7150545.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的那只水属性怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查怪兽区域是否有空位，且对象怪兽在场上表侧表示存在并仍与该效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local lv=tc:GetLevel()
		local code=tc:GetCode()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只与对象怪兽等级相同且卡名不同的鱼族怪兽
		local g=Duel.SelectMatchingCard(tp,c7150545.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,lv,code)
		local tc=g:GetFirst()
		-- 尝试将选择的鱼族怪兽以表侧守备表示特殊召唤
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽在这个回合不能把效果发动。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_TRIGGER)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 完成特殊召唤的后续处理
			Duel.SpecialSummonComplete()
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTarget(c7150545.splimit)
	-- 注册直到回合结束时自己不是超量怪兽不能从额外卡组特殊召唤的玩家限制效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制玩家不能从额外卡组特殊召唤超量怪兽以外的怪兽
function c7150545.splimit(e,c)
	return not c:IsType(TYPE_XYZ) and c:IsLocation(LOCATION_EXTRA)
end
-- 在进行水属性怪兽的超量召唤时，将这张卡的等级当作3星或5星使用的数值判定
function c7150545.xyzlv(e,c,rc)
	if rc:IsAttribute(ATTRIBUTE_WATER) then
		return c:GetLevel()+0x10000*e:GetLabel()
	else
		return c:GetLevel()
	end
end
