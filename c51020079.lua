--サイボーグドクター
-- 效果：
-- 把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。
function c51020079.initial_effect(c)
	-- 效果原文内容：把自己场上存在的1只调整解放发动。和解放怪兽相同属性·等级的1只怪兽从自己墓地特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51020079,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c51020079.sptg)
	e1:SetOperation(c51020079.spop)
	c:RegisterEffect(e1)
end
-- 检索满足条件的调整怪兽，确保其属性与等级在墓地中存在可特殊召唤的怪兽。
function c51020079.rfilter(c,e,tp)
	-- 检查当前选择的调整是否满足后续特殊召唤条件（即墓地中是否存在与其属性和等级相同的怪兽）。
	return c:IsType(TYPE_TUNER) and Duel.IsExistingTarget(c51020079.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,c:GetLevel(),c:GetAttribute())
end
-- 过滤函数：检查墓地中的怪兽是否具有指定等级、属性且可以被特殊召唤。
function c51020079.spfilter(c,e,tp,lv,att)
	return c:IsLevel(lv) and c:IsAttribute(att) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：判断是否满足发动条件，选择解放的调整并检索符合条件的墓地怪兽进行特殊召唤。
function c51020079.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c51020079.spfilter(chkc,e,tp) end
	-- 检测场上是否存在可解放的调整怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c51020079.rfilter,1,nil,e,tp) end
	-- 从场上选择1只满足条件的调整作为解放对象。
	local rg=Duel.SelectReleaseGroup(tp,c51020079.rfilter,1,1,nil,e,tp)
	local r=rg:GetFirst()
	local lv=r:GetLevel()
	local att=r:GetAttribute()
	-- 以解放作为效果代价，将选中的调整从场上解放。
	Duel.Release(rg,REASON_COST)
	-- 提示玩家选择要特殊召唤的墓地怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 在墓地中选择一只与已解放调整属性和等级相同的怪兽作为目标。
	local g=Duel.SelectTarget(tp,c51020079.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,lv,att)
	-- 设置本次连锁操作信息为特殊召唤类别，用于后续效果处理检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果发动后执行的操作：将选中的墓地怪兽特殊召唤到场上。
function c51020079.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
