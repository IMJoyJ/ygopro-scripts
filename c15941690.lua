--先史遺産クリスタル・ボーン
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，可以从自己的手卡·墓地选「先史遗产 水晶骨架」以外的1只名字带有「先史遗产」的怪兽特殊召唤。
function c15941690.initial_effect(c)
	-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15941690.hspcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，可以从自己的手卡·墓地选「先史遗产 水晶骨架」以外的1只名字带有「先史遗产」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15941690,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c15941690.spcon)
	e2:SetTarget(c15941690.sptg)
	e2:SetOperation(c15941690.spop)
	c:RegisterEffect(e2)
end
-- 以特殊召唤规则的形式定义本卡从手卡进行的无种类特殊召唤：当c为空时默认允许规则发动；否则需要满足自方场上无怪兽、对方场上有怪兽且自方主要怪兽区有空位。
function c15941690.hspcon(e,c)
	if c==nil then return true end
	-- 确认这张卡的控制者自己场上没有怪兽。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 确认对方场上有怪兽存在。
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 确认自己主要怪兽区有空位可供这张卡特殊召唤。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 诱发效果的发动条件：这张卡是以自身规则效果（特殊召唤类型为特殊召唤+自身效果值）成功特殊召唤时才能发动。
function c15941690.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 筛选可特殊召唤的怪兽：必须为名字带有「先史遗产」字段的怪兽，不能是「先史遗产 水晶骨架」自身，并且可以被当前效果特殊召唤。
function c15941690.filter(c,e,tp)
	return c:IsSetCard(0x70) and not c:IsCode(15941690) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法判定：自己场上存在空位，并且手卡·墓地中存在满足筛选条件的怪兽。
function c15941690.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自方主要怪兽区是否有空位，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足筛选条件的「先史遗产」怪兽。
		and Duel.IsExistingMatchingCard(c15941690.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统声明本效果预定进行从手卡·墓地特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理部分：先确认空位，然后提示玩家选择要特殊召唤的怪兽，从手卡·墓地选择1只符合条件的怪兽正面攻击表示特殊召唤。
function c15941690.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际处理前再检查一次自方主要怪兽区是否仍有空位，若没有则效果处理失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家弹出选择特殊召唤对象的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只满足条件的「先史遗产」怪兽，且需要排除王家长眠之谷等效果影响。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15941690.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以正面表示特殊召唤到控制者场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
