--C－クラッシュ・ワイバーン
-- 效果：
-- ①：1回合1次，可以把1个以下效果发动。
-- ●以自己场上1只机械族·光属性怪兽为对象，把这张卡当作装备魔法卡使用来装备。装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
-- ●装备状态的这张卡特殊召唤。
-- ②：装备怪兽不受对方的陷阱卡的效果影响。
-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只同盟怪兽特殊召唤。
function c3405259.initial_effect(c)
	-- 为这张卡注册同盟怪兽共用基本效果：对应①的‘作为装备魔法给自己场上机械族·光属性怪兽装备’、‘装备怪兽被战斗/效果破坏时代替破坏’以及‘装备状态的这张卡特殊召唤’等同盟通用效果。
	aux.EnableUnionAttribute(c,c3405259.filter)
	-- ②：装备怪兽不受对方的陷阱卡的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c3405259.efilter)
	c:RegisterEffect(e4)
	-- ③：这张卡从场上送去墓地的场合才能发动。从手卡把1只同盟怪兽特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCondition(c3405259.spcon2)
	e5:SetTarget(c3405259.sptg2)
	e5:SetOperation(c3405259.spop2)
	c:RegisterEffect(e5)
end
c3405259.has_text_type=TYPE_UNION
-- 定义同盟装备对象的过滤条件：选择自己场上1只机械族且光属性的怪兽作为装备对象。
function c3405259.filter(c)
	return c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 定义免疫判定条件：该效果是对方玩家发动的、不是这张卡自身的效果，且属于陷阱卡效果时，装备怪兽不受其影响。
function c3405259.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:GetOwner()~=e:GetOwner()
		and te:IsActiveType(TYPE_TRAP)
end
-- 判断③的发动条件：确认这张卡是从场上区域送去墓地，满足‘从场上送去墓地’的场合。
function c3405259.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 定义③可特殊召唤的手卡怪兽过滤条件：必须是同盟怪兽，且可以被当前效果特殊召唤。
function c3405259.spfilter(c,e,tp)
	return c:IsType(TYPE_UNION) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的发动合法检测：自己主要怪兽区有空位，并且手卡中存在至少1只可特殊召唤的同盟怪兽。
function c3405259.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否有可用空格，作为发动③的前提条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足条件的同盟怪兽，作为发动③的前提条件之一。
		and Duel.IsExistingMatchingCard(c3405259.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的操作信息：本效果将把1只怪兽从手卡特殊召唤，供后续检测与连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果处理：在主要怪兽区有空位时，从手卡选择1只同盟怪兽并特殊召唤。
function c3405259.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，若无空位则本次处理不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只满足条件的同盟怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c3405259.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的同盟怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
